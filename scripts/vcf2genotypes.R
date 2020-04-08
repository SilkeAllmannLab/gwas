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
 
  # transpose matrix for compatibility with GWASpoly
  t_snp_matrix = t(snp_matrix)
  
  # to prepare the merge with the marker map info
  t_snp_matrix_df = as.data.frame(t_snp_matrix)
  
  return(t_snp_matrix_df)
}

