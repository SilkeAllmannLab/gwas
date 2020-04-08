############
# Library
############

# all package dependencies
source("scripts/load_library.R")

# custom functions to create the input objects for the GWAS analysis
source("scripts/vcf2genotypes.R")
source("scripts/vcf2MyGM.R")

###############################################
# 2. Import, convert VCF and save file for GWAS 
###############################################

# The first three columns of the genotype file are (1) marker name, (2) chromosome, and (3) position.
# Subsequent columns contain the marker data for each individual in the population.

vcf_file_path <- "data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf"

# extracts genotype information from VCF file 
my_GD = vcf2genotypes(vcfFile = vcf_file_path)

# Markers physical map info
#  SNP | CHROM | POS
my_GM <- vcf2physicalmap(vcfFile = vcf_file_path)

genotype_info = bind_cols(my_GM, my_GD)

write.csv(x = genotype_info, file = "data/genotype_info.csv",quote = F,row.names = F)

################################
# 3. Load data into the GWASpoly class
################################

data_for_gwas <- read.GWASpoly(ploidy = 2,
                               pheno.file = "data/MyY.csv", 
                               geno.file = "data/genotype_info.csv",
                               format = "numeric",
                               n.traits = ncol(my_Y[-1]),
                               delim = ","
                               )
  
  
  
  
  
  

