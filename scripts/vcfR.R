library(vcfR)


vcf <- read.vcfR("data/chr01_7000SNPs_vcf.gz", 
                 verbose = TRUE,
                 limit = 1e+09, 
                 convertNA = TRUE,
                 nrows = -1)



# import phenotypes



# Timing
#system.time(vcf <- read.vcfR("data/Arabidopsis_2029_Maf001_Filter80.vcf.gz", verbose = TRUE,nrows = 1000))  # 1 second
