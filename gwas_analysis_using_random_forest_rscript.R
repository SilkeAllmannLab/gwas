#!/usr/bin/env Rscript

##############################
# Section 0: load libraries
##############################
source("scripts/load_muvr_dependencies.R")

# create parser list
option_list <- list(
  make_option(c("-v", "--vcf"), 
              default = NULL, 
              type = "character",
              action = "store",
              metavar = "character",
              help="Path to VCF file (gzipped or not)"),
  make_option(c("-p", "--phenotype"), 
              default=NULL, 
              type="character",
              action = "store",
              metavar = "character",
              help="Phenotype input file")
)

opt_parser <- optparse::OptionParser(option_list = option_list)
args <- optparse::parse_args(opt_parser)


option_list = list(
  make_option(c("-v", "--vcf"), 
              type = "character", 
              default = NULL, 
              help="Path to VCF file (gzipped or not)", 
              metavar="character"),
  make_option(c("-f", "--phenotype"),
              type = "character", 
              default = NULL,
              metavar = "character",
              help = "Phenotype input tab-separated file (2 columns: id and pheno value)"),
  make_option(c("-d", "--outdir"), 
              type="character", 
              default="gwas_results/", 
              help="output directory where to store results [default= %default]", 
              metavar="character"),
  make_option(c("-s", "--n_snps"), 
              type="integer", 
              default=-1, 
              help="Number of SNPs to consider in input VCF file (default to -1 for all SNPs)",
              metavar="integer"),
  make_option(c("-p", "--n_cores"), 
              type="integer", 
              default = 1, 
              help="Number of cores/CPUs to use (parallel execution) [default= %default]",
              metavar="integer"),
  make_option(c("-r", "--n_reps"), 
              type = "integer", 
              default = 100, 
              help="Number of repetitions to perform [default= %default]",
              metavar="integer"),
  make_option(c("-o", "--n_outer"), 
              type = "integer", 
              default=7, 
              help="Number of outer test segments to perform [default= %default]",
              metavar="integer"),
  make_option(c("-i", "--n_inner"), 
              type = "integer", 
              default=4, 
              help="Number of inner test segments to perform [default= %default]",
              metavar="integer"),
  make_option(c("-m", "--model"), 
              type="character", 
              default="min", 
              help="Model choice ('min', 'mid' or 'max') [default= %default]"),
  make_option(c("-r", "--variable_ratio"), 
              type="double", 
              default=0.8, 
              help="Ratio of variables kept per iteration [default= %default]"),
  make_option(c("-z", "--n_permutations"), 
              type = "integer", 
              default=100,
              help="Number of permutations [default= %default]")
) 
opt_parser = OptionParser(option_list=option_list, 
                          epilogue = "A program to perform GWAS analysis using the Random Forest ML algorithm");
args = parse_args(opt_parser)

#############################
Section 0: make cluster
#############################
cl = makeCluster(args$n_cores)
registerDoParallel(cl)

##############################
# Section 1: VCF
# Import VCF file transformed
# Convert genotypes to alleles
# Generates a `genotypes` R object
##############################
source("scripts/vcf2genotypes.R")

vcf <- read.vcfR(args$vcf,
                 verbose = TRUE,
                 nrows = args$n_snps,
                 convertNA = TRUE,
                 checkFile = TRUE)

genotypes <- convert_vcf_to_genotypes(
  vcf_object = vcf,
  return_alleles = FALSE,
  convert_dot_to_na = TRUE)

#######################
# Section 2: phenotypes
# Import phenotype file   
#######################

phenotypes <- read.delim(args$phenotype, header = TRUE) %>% 
  select(id, phenotype) %>% 
  mutate(id = as.character(id))

phenotypes = na.omit(phenotypes)

#######################
# Section 3: MUVR Random Forest
# Import phenotype file   
#######################

df <- inner_join(genotypes, phenotypes, by = "id") 

X = df %>% dplyr::select(- id, - phenotype)  
Y = df$phenotype

rf_model <- MUVR(X = X, 
                 Y = Y,
                 ID = df$id,
                 nRep = args$n_reps,
                 nOuter = args$n_outer,
                 nInner = args$n_inner,
                 varRatio = args$variable_ratio,
                 scale = FALSE, 
                 DA = FALSE, 
                 fitness = "RMSEP", 
                 method = "RF", 
                 parallel = TRUE)

####################################
# Section 4: save RF model and plots
####################################
png(filename = file.path(args$outdir, "plot1_metric_vs_number_of_variables.png"))
plotVAL(rf_model)
dev.off()

png(filename = file.path(args$outdir, "plot2_predicted_vs_test_original.png"))
plotMV(rf_model)
dev.off()

write.table(rf_model$VIP)

save(rf_model, 
     file = file.path(args$outdir, "rf_model.RData"),
     compress = "gzip")
