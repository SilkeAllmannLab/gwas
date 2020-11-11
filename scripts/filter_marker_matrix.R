library("testit")

filter_genotypes_and_convert_alleles_to_characters <- function(marker_matrix., phenotypes.){
  # genotype identifier columns have to match in both marker_matrix and phenotypes matrix
  assert("First column in phenotype data file should be called 'genotype'", 
         colnames(phenotypes)[1] == "genotype")
 
  
  # Keep only genotypes with phenotypic data
  filtered_marker_matrix <- dplyr::filter(.data = marker_matrix.,
                                          genotype %in% as.character(phenotypes.$genotype))           
  # convert factor-encoded alleles to character
  
  genotypes = filtered_marker_matrix %>% 
  tidyr::pivot_longer(cols = - genotype, 
                      names_to = "SNP", 
                      values_to = "alleles") %>% 
  mutate(alleles = as.character(alleles)) %>% 
  tidyr::pivot_wider(id_cols = "genotype", 
                     names_from = "SNP", 
                     values_from = "alleles", )

  # remove NAs as they are not accepted
  genotypes = na.omit(genotypes)

}