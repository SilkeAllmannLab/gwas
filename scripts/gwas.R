############
# Library
############

# all package dependencies
source("scripts/load_library.R")

# custom functions to create the input objects for GAPIT
source("scripts/vcf2genotypes.R")
source("scripts/vcf2MyGM.R")

##########################################
# 1. Import and convert VCF data for GAPIT
##########################################

vcf_file_path <- "data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf"

# extracts genotype information from VCF file 
my_GD = vcf2genotypes(vcfFile = vcf_file_path)

# Markers physical map info
#  SNP | CHROM | POS
my_GM <- vcf2physicalmap(vcfFile = vcf_file_path)

##########################
# 2. Import phenotype data
##########################
my_Y = read.csv(file = "data/MyY.csv", 
                stringsAsFactors = F, 
                header = TRUE, 
                colClasses = c("character","numeric"))

source("http://www.zzlab.net/GAPIT/GAPIT.library.R")
source("http://www.zzlab.net/GAPIT/gapit_functions.txt")

myGAPIT_GLM <- GAPIT(
  GM = my_GM,
  GD = my_subset_GD,
  Y = my_Y[,c(1,2)],
  file.output = FALSE
)


