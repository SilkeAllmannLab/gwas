############
# Library
############

# all package dependencies
source("scripts/load_library.R")

# custom functions to create the input objects for the GWAS analysis
source("scripts/vcf2genotypes.R")
source("scripts/vcf2MyGM.R")

##########################
# 1. Import phenotype data
##########################


################################
# 2. Import and convert VCF data 
################################

# The first three columns of the genotype file are (1) marker name, (2) chromosome, and (3) position.
# Subsequent columns contain the marker data for each individual in the population.

vcf_file_path <- "data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf"

# extracts genotype information from VCF file 
my_GD = vcf2genotypes(vcfFile = vcf_file_path)

# Markers physical map info
#  SNP | CHROM | POS
my_GM <- vcf2physicalmap(vcfFile = vcf_file_path)



