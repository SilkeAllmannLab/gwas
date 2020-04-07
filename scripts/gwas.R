############
# Library
############

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
suppressPackageStartupMessages(library(dplyr))

# other packages come from Bioconductor
# BiocManager is the package installer for Bioconductor releases
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

##########################################
# 1. Import and convert VCF data for GAPIT
##########################################

vcf_file_path <- "data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf"

# extracts genotype information from VCF file 
myGD = vcf2genotypes(vcfFile = vcf_file_path)

# Markers physical map info
# myGM = ID | CHROM | POS
myGM <- vcf2physicalmap(vcfFile = vcf_file_path)

##########################
# 2. Import phenotype data
##########################
myY = read.csv(file = "data/MyY.csv", stringsAsFactors = F, header = TRUE)


source("http://www.zzlab.net/GAPIT/GAPIT.library.R")
source("http://www.zzlab.net/GAPIT/gapit_functions.txt")

myGAPIT_GLM <- GAPIT(
  Y=myY,
  GD=myGD,
  GM=myGM,
  model="GLM",
  PCA.total=5,
  file.output=T
)


