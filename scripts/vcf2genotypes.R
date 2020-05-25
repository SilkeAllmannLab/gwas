vcf2genotypes <- function(vcfFile){
  ### this function is derived from the VariantAnnotation readVcf function
  # see https://bioconductor.org/packages/release/bioc/vignettes/VariantAnnotation/inst/doc/VariantAnnotation.pdf
  vcf = readVcf(vcfFile)
  
  # Conversion of the genotype info 'GT' of the FORMAT field into a snpMatrix
  # https://www.rdocumentation.org/packages/VariantAnnotation/versions/1.18.5/topics/genotypeToSnpMatrix
  snp_matrix <- genotypeToSnpMatrix(vcf, uncertain = FALSE)$genotypes
  
  # numeric transforms:
    # ref homozogous to ref allele into 0
    # ref homozygous to alt allele into 2
    # heterozygous into 1
    #snp_matrix = as(snp_matrix, "numeric")
  
  # conversion
  # A/A becomes -1 (homozygous of the reference allele)
  # B/B becomes 1 (homozygous of the alternative allele) 
  # A/B becomes 0 (heterozygous of the reference and alternative alleles).
  snp_matrix = as(snp_matrix, "character")
  snp_matrix[snp_matrix == "A/A"] <- -1
  snp_matrix[snp_matrix == "B/B"] <-  1
  snp_matrix[snp_matrix == "A/B"] <-  0
  
  # for downstream compatibility with modify.data from RainbowR
  class(snp_matrix) <- "numeric"
  
  return(snp_matrix)
}

