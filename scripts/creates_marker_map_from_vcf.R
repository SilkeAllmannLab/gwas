suppressPackageStartupMessages("vcfR")
suppressPackageStartupMessages("dplyr")

creates_marker_map_from_vcf <- function(vcf_file){
  
  # converts vcf file to vcfR object
  vcf <- read.vcfR(vcf_file,
                   verbose = FALSE,
                   nrows = -1,
                   convertNA = TRUE,
                   checkFile = TRUE)
  
  # extract fix region that contains variant info common for all samples
  map <- vcf@fix %>% 
    as.data.frame() %>% 
    dplyr::select(CHROM, POS, ID, REF, ALT)
  
  # build SNP id in the same way as for the marker matrix (e.g. SNP + "_" + original variant id)
  map_with_fixed_snp_names <- map %>% 
    mutate(new_id = paste("SNP", ID, sep = "_")) %>% 
    dplyr::select(- ID) %>% 
    column_to_rownames("new_id")
  
  # rename CHROM and POS for compatibility with statgenGWAS createGData function
  map_with_fixed_snp_names_and_renamed_cols = dplyr::rename(map_with_fixed_snp_names,
                                           chr = CHROM,
                                           pos = POS, 
                                           ref = REF, 
                                           alt = ALT) 
    
  # convert pos to numeric (factor originally)
  map_with_fixed_snp_names_and_renamed_cols$pos <- with(map_with_fixed_snp_names_and_renamed_cols,
                                                        as.numeric(as.character(pos))
                                                        )
  
  return(map_with_fixed_snp_names_and_renamed_cols)

}

