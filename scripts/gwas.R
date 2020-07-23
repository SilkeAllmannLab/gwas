############
# Library
############

### Load dependencies
source("scripts/load_library.R")

### Custom functions to create the input objects for the GWAS analysis
source("scripts/vcf2genotypes.R")
source("scripts/vcf2geneticmap.R")


########################################################################
# 2. Import, convert VCF and extract genotype info for use with RAINBOWR 
########################################################################

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
                               geno.mat = my_genotypes, 
                               return.ZETA = TRUE, 
                               return.GWAS.format = TRUE)

# Extract phenotype info
pheno_for_gwas <- as.data.frame(modify_data_res$pheno.modi)
pheno_for_gwas = data.frame(samples = row.names(pheno_for_gwas), ratio = pheno_for_gwas$Ratio)
row.names(pheno_for_gwas) = pheno_for_gwas$samples

# Extract genotype info
geno_for_gwas <- as.data.frame(t(modify_data_res$geno.modi))
geno_for_gwas <- cbind.data.frame(my_genetic_map, geno_for_gwas) 

# Extract population structure info
zeta <- modify_data_res$ZETA

#####################
# 5. Perform the GWAS
#####################
normal_gwas_res <- RGWAS.normal(pheno = pheno_for_gwas,
                                geno = geno_for_gwas,
                                ZETA = zeta,
                                n.PC = 0,
                                sig.level = 0.05,
                                thres = TRUE,
                                P3D = TRUE,
                                plot.Manhattan = TRUE,
                                saveName = "plot.png",
                                plot.qq = TRUE)







