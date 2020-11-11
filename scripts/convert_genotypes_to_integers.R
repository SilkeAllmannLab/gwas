convert_genotypes_to_integers <- function(filtered_marker_matrix.){
  
  
  # convert to matrix
  # get unique elements
  m = filtered_marker_matrix. %>% 
    dplyr::select(- genotype) %>% 
    as.matrix()
  m = as.vector(m)
  cat("Here are the unique elements:\n")
  cat(unique(m))
  
  # replace alleles in original marker matrix by integers
  marker_matrix_ready_for_statgen = filtered_marker_matrix.
  
  marker_matrix_ready_for_statgen[marker_matrix_ready_for_statgen == "0|0"] <- "0"
  marker_matrix_ready_for_statgen[marker_matrix_ready_for_statgen == "1|1"] <- "2"
  marker_matrix_ready_for_statgen[marker_matrix_ready_for_statgen == "1|0"] <- "1"
  marker_matrix_ready_for_statgen[marker_matrix_ready_for_statgen == "0|1"] <- "1"
  
  # place individual names into row names for createGData() function
  marker_matrix_ready_for_statgen = 
    marker_matrix_ready_for_statgen %>% 
    column_to_rownames(var = "genotype")
  
  return(marker_matrix_ready_for_statgen)
}