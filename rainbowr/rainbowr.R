suppressPackageStartupMessages(library("tibble"))
suppressPackageStartupMessages(library("vcfR"))
suppressPackageStartupMessages(library("tidyr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("rrBLUP"))
suppressPackageStartupMessages(library("RAINBOWR"))
suppressPackageStartupMessages(library("ggplot2"))


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

vcf_file_path <- "data/chr05.66k_SNPs.vcf.gz"

vcf <- read.vcfR(vcf_file_path,
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
         CHROM = as.numeric(as.character(CHROM)), 
         POS = as.numeric(as.character(POS)))


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
  ZETA = zeta_matrix, 
  plot.qq = FALSE, 
  plot.Manhattan = FALSE, 
  method.thres = "Bonferroni",
  min.MAF = 0.05)

##################
# Section 4: plots
##################
title4plot <- strsplit(x = basename(vcf_file_path),
                       split = ".vcf.gz")

### custom Manhattan plot
fdr_threshold <- gwas_results$thres
gwas_results <- gwas_results$D

points_to_label = 
  gwas_results %>% 
  filter(phenotype > fdr_threshold) 

p <- gwas_results %>% 
  ggplot(., aes(x = pos, y = phenotype)) +
  geom_point() +
  geom_hline(yintercept = fdr_threshold, color = "blue") +
  ggtitle(title4plot) +
  labs(x = "position", y = "-log10(p-value)") +
  ggrepel::geom_label_repel(data = points_to_label, 
                            aes(x = pos, 
                                y = phenotype, 
                                label = marker))

ggsave(filename = paste("results/",title4plot,".png", sep = ""), plot = p)
ggsave(filename = paste("results/",title4plot,".pdf", sep = ""), plot = p)

##########################
# Section 5: table of SNPs
##########################
gwas_results %>% 
  filter(phenotype > fdr_threshold) %>% 
  write.table(., 
              file = paste("results/",title4plot,".tsv", sep = ""), 
              quote = F, 
              sep = "\t", 
              row.names = F)
