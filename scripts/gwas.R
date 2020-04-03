############
# Library
############

## Include package vcfR as well, needed for the GM table
library(vcfR)

# To enhance script reproducibility use of checkpoint library
# https://mran.microsoft.com/documents/rro/reproducibility/
if (! "checkpoint" %in% installed.packages()){
  install.packages("checkpoint")
}
library("checkpoint")
checkpoint("2020-01-01") 

# these libraries will be managed by the checkpoint package
suppressPackageStartupMessages(library(gplots))
suppressPackageStartupMessages(library(LDheatmap))
suppressPackageStartupMessages(library(genetics))
suppressPackageStartupMessages(library(ape))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(EMMREML))
suppressPackageStartupMessages(library(scatterplot3d))

# other packages come from Bioconductor
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
# install correct version of BiocManager?
# BiocManager::install(version = "3.9", ask = FALSE)

if(!'multtest'%in% installed.packages()[,"Package"]){
  BiocManager::install("multtest", update = FALSE, ask = FALSE)
  BiocManager::install("snpStats", update = FALSE, ask = FALSE)
}

if ("VariantAnnotation" %in% installed.packages() && "snpStats" %in% installed.packages()){
  suppressMessages(library("VariantAnnotation"))
  suppressMessages(library("snpStats"))
} else {
  BiocManager::install("VariantAnnotation",update = FALSE, version = "3.9")
  BiocManager::install('snpStats',update = FALSE)
  suppressMessages(library("VariantAnnotation"))
}

# custom function to help
source("scripts/vcf2genotypes.R")
source("scripts/vcf2MyGM.R")

#################################
# Converts VCF into genotype data
#################################

# extracts genotype information from VCF file (using a custom function built around Variant Annotation package)
genotypes = vcf2genotypes("data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf")
MyGM <- vcf2MyGM("data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf")

# a peek at the first lines / columns
genotypes[1:5, 1:5]
MyGM[1:5, 1:5]

