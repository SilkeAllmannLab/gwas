convert_vcf_to_genotypes <- function(vcf_object = vcf,
                                     return_alleles = FALSE,
                                     id_to_rownames = TRUE,
                                     convert_dot_to_na = TRUE
){
  
  # Convert genotypes to a matrix of alleles
  genotypes <- extract.gt(vcf,
                          return.alleles = return_alleles,
                          IDtoRowNames = id_to_rownames,
                          convertNA = convert_dot_to_na) %>%
    t(.) %>%
    as.data.frame() %>%
    rownames_to_column("id") 
  
  # create a new vector of SNP names compatible with MUVR 
  # No single number as variable identifier
  snp_names = as.vector(
    sapply(
      names(genotypes[2:length(names(genotypes))]),
      function(x){paste("SNP",x,sep = "_")})
  )
  colnames(genotypes) = c("id", snp_names)
  
  # convert factor-encoded alleles to character
  genotypes = genotypes %>% 
    pivot_longer(cols = - id, 
                 names_to = "SNP", 
                 values_to = "alleles") %>% 
    mutate(alleles = as.character(alleles)) %>% 
    pivot_wider(id_cols = "id", 
                names_from = "SNP", 
                values_from = "alleles", )
  
  # remove NAs as they are not accepted by MUVR
  genotypes = na.omit(genotypes)
  
  
  # convert factor-encoded alleles to character
  genotypes = genotypes %>% 
    pivot_longer(cols = - id, 
                 names_to = "SNP", 
                 values_to = "alleles") %>% 
    mutate(alleles = as.character(alleles)) %>% 
    pivot_wider(id_cols = "id", 
                names_from = "SNP", 
                values_from = "alleles", )
  
  # remove NAs as they are not accepted by MUVR
  genotypes = na.omit(genotypes)
  
  # get unique values
  # convert to numbers
  genotypes[genotypes == "0|0"] <- 0
  genotypes[genotypes == "1|1"] <- 2
  genotypes[genotypes == "1|0"] <- 1
  genotypes[genotypes == "0|1"] <- 1
  
  return(genotypes)
}