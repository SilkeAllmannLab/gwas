suppressPackageStartupMessages(library("tidyr"))
suppressPackageStartupMessages(library("dplyr"))

creates_marker_matrix_from_vcf <- function(vcf_file){
  
  # converts vcf file to vcfR object
  vcf <- read.vcfR(vcf_file,
                   verbose = TRUE,
                   nrows = -1,
                   convertNA = TRUE,
                   checkFile = TRUE)
  
  # Convert genotypes to a matrix of alleles
  genotypes <- extract.gt(vcf,
                          return.alleles = FALSE,
                          IDtoRowNames = TRUE,
                          convertNA = TRUE) %>%
    t(.) %>%
    as.data.frame() %>%
    rownames_to_column("genotype") 
  
  # add 'SNP_' in front of marker names
  # the first column ('genotype') is not renamed
  colnames(genotypes)[2:ncol(genotypes)] = paste('SNP', 
                                                 colnames(genotypes)[2:ncol(genotypes)], 
                                                 sep = "_")
  
  return(genotypes)
}




