vcf2MyGM <-function(vcfFile){
  ### Function includes functions from the R package vcfR
  # https://cran.r-project.org/web/packages/vcfR/vignettes/intro_to_vcfR.html
  # read vcf
  vcf <- read.vcfR(vcfFile)
  
  # get fixed data (CHROM, POS, ID, REF, ALT, QUAL, FILTER)
  FixedDataColumns <- getFIX(vcf)
  
  # make GM table from fixed data columns
  MyGM <- FixedDataColumns[ , c("ID", "CHROM", "POS")]
  
  return(MyGM)
}