vcf2physicalmap <-function(vcfFile){
  ### this function is derived from the VariantAnnotation readVcf function
  ### Functions to extract info are from the GRanges package
  # VariantAnnotation: see https://bioconductor.org/packages/release/bioc/vignettes/VariantAnnotation/inst/doc/VariantAnnotation.pdf
  # Genomic Ranges: see https://www.bioconductor.org/packages/release/bioc/html/GenomicRanges.html 
  
  vcf = readVcf(vcfFile)
  
  # Extract fields one by one
  snp_ids = as.vector(row.names(DataFrame(ranges(vcf))),mode = "character")
  chromosomes = as.vector(seqnames(vcf),mode = "integer")
  positions = start(ranges(vcf))

  # rebuild the physical marker dataframe
  myGM <- data.frame(taxa = snp_ids, 
                     chrom = chromosomes,
                     pos = positions)
    
  return(myGM)
}