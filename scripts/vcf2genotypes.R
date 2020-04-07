vcf2genotypes <- function(vcfFile){
  ### this function is derived from the VariantAnnotation readVcf function
  # see https://bioconductor.org/packages/release/bioc/vignettes/VariantAnnotation/inst/doc/VariantAnnotation.pdf
  vcf = readVcf(vcfFile)
  
  # Conversion of the genotype info 'GT' of the FORMAT field into a snpMatrix
  snp_matrix <- genotypeToSnpMatrix(vcf, uncertain = FALSE)$genotypes
  
  # numeric transforms:
    # ref homozogous into 0
    # ref homozygous into 2
    # heterozygous into 1
  snp_matrix = as(snp_matrix, "numeric") 
  
  # write genotype ids in a new column for GAPIT compatibility
  snp_df = as.data.frame(snp_matrix)
  my_gd_ready_for_gapit = bind_cols(taxa = row.names(snp_df), # genotype ids
                                    snp_df[,-1])                  # allelic info  
                      
  
  return(my_gd_ready_for_gapit)
}

