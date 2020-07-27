import_vcf_file <- function(vcf_file_path, n_lines = 1000, verb = TRUE){
  read.vcfR(vcf_file_path, 
            verbose = verb, 
            convertNA = TRUE, 
            checkFile = TRUE)
  
  
}


# vcf <- read.vcfR("data/chr01.header.Arabidopsis_2029_Maf001_Filter80.vcf.gz", 
#                  verbose = FALSE, 
#                  nrows = 1000, 
#                  convertNA = TRUE, 
#                  checkFile = TRUE)
# 
# # Extract genotype information
# # Rows: individuals
# # Columns: SNPs
# genotypes <- extract.gt(vcf, 
#                         return.alleles = TRUE, 
#                         IDtoRowNames = TRUE, 
#                         convertNA = TRUE) %>% 
#   t(.) %>%                            
#   as.data.frame() %>% 
#   rownames_to_column("id")
# 
# snp_names = as.vector(
#   sapply(
#     names(genotypes[2:length(names(genotypes))]), 
#     function(x){paste("SNP",x,sep = "_")})
# )
# 
# colnames(genotypes) = c("id", snp_names)
