suppressPackageStartupMessages(library("tibble"))
suppressPackageStartupMessages(library("vcfR"))
suppressPackageStartupMessages(library("tidyr"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("RAINBOWR"))
suppressPackageStartupMessages(library("ggplot2"))
suppressPackageStartupMessages(library("optparse"))


########################
# Command line arguments
########################

option_list = list(
  make_option(c("-v", "--vcf"), 
              type = "character", 
              default = "data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf", 
              help="Path to VCF file. Can be gzipped (.gz)", 
              metavar="filename"),
  make_option(c("-p", "--phenotype"), 
              type = "character", 
              default = "data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf", 
              help="Path to the phenotype file. One column with line identifier and one with phenotypic value. Tab-separated.", 
              metavar="filename"),
  make_option(c("-o", "--outdir"), 
              type="character", 
              default="gwas_results", 
              help="output directory where to store results [default= %default]", 
              metavar="character")
) 
opt_parser = OptionParser(option_list=option_list,
                          description = "\n A program to perform a GWAS analysis based on the RAINBOWR package for R",
                          epilogue = "Please visit https://cran.r-project.org/web/packages/RAINBOWR/index.html and https://github.com/SilkeAllmannLab/gwas for additional information");
args = parse_args(opt_parser)

#######################
# Section 1: phenotypes
# Import phenotype file   
#######################

phenotypes <- read.delim(args$phenotype, header = TRUE) %>% 
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

source("scripts/vcf2genotypes.R")

vcf_file_path <- args$vcf

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

if (nrow(points_to_label) == 0){
  cat("no signficant SNPs related to the phenotype detected.")
} else {
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
  
  ggsave(filename = paste(args$outdir, title4plot, ".png", sep = ""), plot = p, width = 10, height = 7)
  ggsave(filename = paste(args$outdir, title4plot, ".pdf", sep = ""), plot = p, width = 10, height = 7)
}


##########################
# Section 5: table of SNPs
##########################
if (nrow(points_to_label) == 0){
  file_connection <- file(paste(args$outdir, title4plot, ".tsv", sep = ""))
  writeLines(text = "no signficant SNPs related to the phenotype detected.",
             con = file_connection)
  close(file_connection)
} else {
  gwas_results %>% 
  filter(phenotype > fdr_threshold) %>% 
  write.table(., 
              file = paste(args$outdir, title4plot, ".tsv", sep = ""), 
              quote = F, 
              sep = "\t", 
              row.names = F)
}


