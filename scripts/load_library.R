
### Source = MRAN checkpoint
### To enhance script reproducibility use of checkpoint library
### https://mran.microsoft.com/documents/rro/reproducibility/
if (! "checkpoint" %in% installed.packages()){
  install.packages("checkpoint")
}
library("checkpoint")
checkpoint("2020-01-01", checkpointLocation = "./mran/") # specify this location in the same project folder to maintain pipeline portability
library("RAINBOWR") # https://github.com/KosukeHamazaki/RAINBOWR
library("dplyr")
library("tibble")
library("tidyr")


### Source = Bioconductor
### VariantAnnotation is used to build our custom vcf2genotypes functions
if ("VariantAnnotation" %in% installed.packages() && "snpStats" %in% installed.packages()){
  suppressMessages(library("VariantAnnotation"))
  suppressMessages(library("snpStats"))
} else {
  BiocManager::install("VariantAnnotation",update = FALSE, version = "3.10")
  BiocManager::install('snpStats',update = FALSE)
  suppressMessages(library("VariantAnnotation"))
}



