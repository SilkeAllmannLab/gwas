vcf2genotypes <- function(vcfFile){
  ### this function is derived from the VariantAnnotation readVcf function
  # see https://bioconductor.org/packages/release/bioc/vignettes/VariantAnnotation/inst/doc/VariantAnnotation.pdf
  vcf = readVcf(vcfFile)
  
  # Conversion of the genotype info 'GT' of the FORMAT field into a snpMatrix
  snp.matrix <- genotypeToSnpMatrix(vcf, uncertain = FALSE)$genotypes
  
  # numeric transforms:
    # ref homozogous into 0
    # ref homozygous into 2
    # heterozygous into 1
  snp.matrix = as(snp.matrix, "numeric") 
  
  return(snp.matrix)
}

