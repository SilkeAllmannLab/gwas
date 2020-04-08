##########################
# Source = MRAN checkpoint
##########################

# To enhance script reproducibility use of checkpoint library
# https://mran.microsoft.com/documents/rro/reproducibility/
if (! "checkpoint" %in% installed.packages()){
  install.packages("checkpoint")
}
library("checkpoint")
checkpoint("2020-01-01") 

# these libraries will be managed by the checkpoint package
library("rrBLUP")
library("corrplot")
library("dplyr")
library("BiocManager")



#######################
# Source = Bioconductor
#######################

# Used to build our custom vcf2genotypes functions
if ("VariantAnnotation" %in% installed.packages() && "snpStats" %in% installed.packages()){
  suppressMessages(library("VariantAnnotation"))
  suppressMessages(library("snpStats"))
} else {
  BiocManager::install("VariantAnnotation",update = FALSE, version = "3.9")
  BiocManager::install('snpStats',update = FALSE)
  suppressMessages(library("VariantAnnotation"))
}


################
# Source = other
################
# custom library to install from source
# Reference: https://potatobreeding.cals.wisc.edu/software/
# doi:10.3835/plantgenome2015.08.0073
if (! "GWASpoly" %in% installed.packages()){
  install.packages("rrblup/gwas_poly/GWASpoly_1.3.tar.gz", repos = NULL, type = "source")
}
library("GWASpoly")
