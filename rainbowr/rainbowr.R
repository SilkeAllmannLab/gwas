suppressPackageStartupMessages(library("tibble"))
suppressPackageStartupMessages(library("vcfR"))
suppressPackageStartupMessages(library("tidyr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("rrBLUP"))


#######################
# Section 1: phenotypes
# Import phenotype file   
#######################

phenotypes <- read.delim("data/root_data_fid_and_names.tsv", header = TRUE) %>% 
  select(id, phenotype) %>% 
  na.omit() %>% 
  mutate(id = as.character(id)) %>% 
  column_to_rownames(., "id")

#####################################
# Section 2: VCF
# Import VCF file transformed
# Creates the marker genotype matrix
# Creates the physical map of markers
#####################################

source("rainbowr/vcf2genotypes_for_rainbowr.R")

vcf <- read.vcfR("data/Arabidopsis_2029_Maf001_Filter80.test30_SNPs.vcf.gz",
                 verbose = TRUE,
                 nrows = -1,
                 convertNA = TRUE,
                 checkFile = TRUE)

# genotype marker matrix
geno_score <- convert_vcf_to_genotypes(vcf)

# physical map
# marker | chrom | pos
geno_map = vcf@fix %>% 
  as.data.frame() %>% 
  dplyr::select(ID, CHROM, POS) %>% 
  mutate(ID = as.character(ID),
         CHROM = as.numeric(CHROM),
         POS = as.numeric(POS))


#####################################
# Section 3: GWAS-ready formatting
#####################################

gwas_ready_df <- modify.data(pheno.mat = phenotypes,
                             geno.mat = geno_score,
                             map = geno_map,
                             return.ZETA = TRUE, 
                             return.GWAS.format = TRUE)

pheno_ready_for_gwas <- gwas_ready_df$pheno.GWAS
geno_ready_for_gwas <- gwas_ready_df$geno.GWAS
zeta_matrix <- gwas_ready_df$ZETA

gwas_results <- RGWAS.normal(
  pheno = pheno_ready_for_gwas, 
  geno = geno_ready_for_gwas,
  ZETA = zeta_matrix)

