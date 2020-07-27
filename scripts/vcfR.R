checkpoint::checkpoint("2020-06-01")
library(vcfR)


vcf <- read.vcfR("data/chr01.header.Arabidopsis_2029_Maf001_Filter80.vcf.gz", verbose = FALSE, nrows = 10000)

# Timing
# 1000 to 1M SNPs
system.time(vcf <- read.vcfR("data/Arabidopsis_2029_Maf001_Filter80.vcf.gz", verbose = TRUE,nrows = 1000))  # 1 second
system.time(vcf <- read.vcfR("data/Arabidopsis_2029_Maf001_Filter80.vcf.gz", verbose = TRUE,nrows = 10000)) # 10 seconds
system.time(vcf <- read.vcfR("data/Arabidopsis_2029_Maf001_Filter80.vcf.gz", verbose = TRUE,nrows = 100000)) # 169 seconds
#system.time(vcf <- read.vcfR("data/chr01.header.Arabidopsis_2029_Maf001_Filter80.vcf.gz", verbose = TRUE)) # XX seconds 15min

# Extract genotype information
genotypes <- extract.gt(vcf, 
                        return.alleles = TRUE, IDtoRowNames = TRUE, convertNA = TRUE)

# import phenotypes
