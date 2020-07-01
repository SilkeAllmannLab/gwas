### Source = MRAN checkpoint
### To enhance script reproducibility use of checkpoint library
### https://mran.microsoft.com/documents/rro/reproducibility/

checkpoint::checkpoint("2020-06-01")

library(rsample)      # data splitting 
library(randomForest) # basic implementation
library(ranger)       # a faster implementation of randomForest
library(caret)        # an aggregator package for performing many machine learning models
library(tibble)


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

### Custom functions to create the input objects for the GWAS analysis
source("scripts/vcf2genotypes.R")
source("scripts/vcf2geneticmap.R")