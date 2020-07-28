##############################
# Section 0: load libraries
##############################
source("scripts/load_muvr_dependencies.R")


library("argparser")

# create parser object
p <- arg_parser("Parser for Random Forest GWAS analysis")

# specify our desired options 
# by default ArgumentParser will add an help option 
p$add_argument(p, "--vcf", default=NULL, type = "character", flag = TRUE,
                    help="Path to VCF file (gzipped or not)")
p$add_argument(p, "--phenotype", default=NULL, type="character", 
                    help="Phenotype input file")
p$add_argument(p, "--outdir", default="./gwas_results/", type="character",
                    help="Directory where to results will be saved. If it does not exist, will be created")
p$add_argument(p, "--n_snps", type="integer", default=-1, 
                    help="Number of SNPs to consider in input file",
                    metavar="number")
p$add_argument(p, "--n_cores", type="integer", default=1, 
                    help="Number of cores/CPUs to use (parallel execution)",
                    metavar="number")
p$add_argument(p, "--n_reps", type="integer", default=100, 
                    help="Number of repetitions to perform",
                    metavar="number")
p$add_argument(p, "--n_outer", type="integer", default=7, 
                    help="Number of outer test segments to perform",
                    metavar="number")
p$add_argument(p, "--n_inner", type="integer", default=7, 
                    help="Number of inner test segments to perform",
                    metavar="number")
p$add_argument(p, "--model", type="character", default="min", 
                    help="Model choice ('min', 'mid' or 'max')")
p$add_argument(p, "--variable_ratio", type="double", default=0.8, 
                    help="Ratio of variables maintained in the data per iteration during variable elimination")
p$add_argument(p, "--n_permutations", type="integer", default=100,
                    help="Number of permutations")


# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults, 
args <- parse_args(p)

##############################
# Section 0: make cluster
##############################
# cl = makeCluster(args$n_cores) 
# registerDoParallel(cl)
# 
# ##############################
# # Section 1: VCF
# # Import VCF file transformed  
# # Convert genotypes to alleles
# # Generates a `genotypes` R object
# ##############################
# source("scripts/vcf2genotypes.R")
# 
# vcf <- read.vcfR(args$vcf, 
#                  verbose = TRUE,
#                  nrows = args$n_snps,
#                  convertNA = TRUE, 
#                  checkFile = TRUE)

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
