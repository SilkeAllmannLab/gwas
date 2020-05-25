############
# Library
############

### Load dependencies
source("scripts/load_library.R")

### Custom functions to create the input objects for the GWAS analysis
source("scripts/vcf2genotypes.R")
source("scripts/vcf2geneticmap.R")


#######################################################################
# 2. Import, convert VCF and extract genotype info for use with RAINBOWR 
#######################################################################

# The first three columns of the genotype file are (1) marker name, (2) chromosome, and (3) position.
# Subsequent columns contain the marker data for each individual in the population.

vcf_file_path <- "data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf"

# extracts genotype information from VCF file 
my_genotypes = vcf2genotypes(vcfFile = vcf_file_path)

###############################################################################
# 3. Import, convert VCF and extract genetic markers info for use with RAINBOWR 
###############################################################################

# Markers physical map info
#  SNP | CHROM | POS
my_genetic_map <- vcf2physicalmap(vcfFile = vcf_file_path)

################################
# 4. Import phenotype data
################################

pheno <- na.omit(read.delim(file = "data/root_data_fid_and_names.tsv", header = TRUE, stringsAsFactors = FALSE))
pheno <- pheno %>% 
  dplyr::select(FID, Ratio) %>% 
  remove_rownames() %>% 
  column_to_rownames(var = "FID")

##################################################################
# 4. Build the data object for RAINBOWR GWAS analysis (single SNP)
##################################################################
modify_data_res <- modify.data(pheno.mat = pheno,
                               geno.mat = my_genotypes)


