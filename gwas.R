suppressPackageStartupMessages(library("tibble"))
suppressPackageStartupMessages(library("vcfR"))
suppressPackageStartupMessages(library("tidyr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("statgenGWAS"))
suppressPackageStartupMessages(library("ggplot2"))
suppressPackageStartupMessages(library("optparse"))
library("testit")


source("scripts/creates_marker_matrix_from_vcf.R")
source("scripts/filter_marker_matrix.R")
source("scripts/convert_genotypes_to_integers.R")
source("scripts/creates_marker_map_from_vcf.R")

########################
# Command line arguments
########################

option_list = list(
  make_option(c("-v", "--vcf"), 
              type = "character", 
              default = "data/vcf/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf.gz", 
              help="Path to VCF file. Can be gzipped (.gz)", 
              metavar="filename"),
  make_option(c("-p", "--phenotype"), 
              type = "character", 
              default = "data/phenotype/hexanal_response/hexanal_ratio_phenotype.tsv", 
              help="Path to the phenotype file. One column that has to be called 'genotype' (individual identifier) and one or more columns with phenotypic value. Tab-separated.", 
              metavar="filename"),
  make_option(c("-o", "--outdir"), 
              type="character", 
              default="gwas_results", 
              help="output directory where to store results [default= %default]", 
              metavar="character"),
  make_option(c("-m", "--maf"), 
              type="numeric", 
              default="0.05", 
              help="Minor Allele Frequency (MAF). Value should be between 0 and 1. [default= %default]", 
              ),
  make_option(c("-g", "--n_miss_geno"), 
              type = "numeric", 
              default = 1,
              help = "A numerical value between 0 and 1. Genotypes with a fraction of missing values higher than nMissGeno will be removed. Genotypes with only missing values will always be removed."
              ),
  make_option(c("-s", "--n_miss_snps"), 
              type = "numeric", 
              default = 1,
              help = "A numerical value between 0 and 1. SNPs with a fraction of missing values higher than nMiss will be removed. SNPs with only missing values will always be removed."
              )
) 
opt_parser = OptionParser(option_list=option_list,
                          description = "\n A program to perform a GWAS analysis based on the statgenGWAS package for R",
                          epilogue = "Please visit https://cran.r-project.org/web/packages/statgenGWAS/index.html and https://github.com/SilkeAllmannLab/gwas for additional information");
args = parse_args(opt_parser)

#######################
# Section 1: phenotypes
# Import phenotype file   
#######################

phenotypes <- read.delim(args$phenotype, header = TRUE) %>% 
  mutate(genotype = as.character(genotype)) 


#####################################
# Section 2: VCF
# Import VCF file transformed
# Creates the marker genotype matrix
#####################################

# Convert the VCF file to a marker matrix file
# genotype | SNP_1 | SNP_2 | etc.
# |--------|-------|-------|
# A3       | 0|0     | 0|0 |
# B22      | 0|0     | 2|2 |
# etc.
marker_matrix <- creates_marker_matrix_from_vcf(vcf_file = args$vcf)

# Filter marker_matrix to keep only individuals with a phenotypic value
# genotype |SNP_73_1| SNP_92_1 | SNP_110_1 | SNP_125_1|
# |--------|--------|----------|-----------|----------|
#  116       0|0       1|1       0|0       0|0      
#  242       0|0       0|0       0|0       0|0      
# etc.  
filtered_marker_matrix <- filter_genotypes_and_convert_alleles_to_characters(
                             marker_matrix = marker_matrix,
                             phenotypes = phenotypes)

# Transform X|X allele notation into X (integer)
marker_matrix_ready_for_statgen <- convert_genotypes_to_integers(filtered_marker_matrix)

#####################################
# Section 3: VCF to physical markers
# Creates the physical map of markers
#####################################

# physical map
# marker (row names) | chrom | pos | ref | alt
marker_map = creates_marker_map_from_vcf(vcf_file = args$vcf)


###############################################
# Section 4: create the gData GWAS-ready object
###############################################
## Create a gData object containing map and marker information.
my_gdata <- createGData(geno = marker_matrix_ready_for_statgen, 
                        map = marker_map, 
                        pheno = phenotypes)

###############################################################
# Section 5: filter SNP data create the gData GWAS-ready object
###############################################################

my_gdata_snpfiltered <- codeMarkers(my_gdata, 
                               nMiss = args$n_miss_snps, 
                               MAF = args$maf,
                               nMissGeno = args$n_miss_geno, 
                               impute = FALSE,
                               verbose = TRUE) 

#########################
# Section 6: perform GWAS
#########################
gwas_results <- runSingleTraitGwas(gData = my_gdata_snpfiltered,
                                traits = c("hexanal_ratio"))

##############################
# Section 7: save GWAS results
##############################

save(gwas_results, 
     file = file.path(args$outdir, "gwas_results.RData")
     )