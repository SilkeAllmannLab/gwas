if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = "3.10", ask = F, update = F)

if(!require(gplots)) install.packages("gplots")
if(!require(LDheatmap)) install.packages("LDheatmap")
if(!require(genetics)) install.packages("genetics")
if(!require(ape)) install.packages("ape")
if(!require(compiler)) install.packages("compiler")

if(!require(EMMREML)) install.packages("EMMREML")
if(!require(scatterplot3d)) install.packages("scatterplot3d")

if(!'multtest'%in% installed.packages()[,"Package"]){
  BiocManager::install("multtest", ask = F, update = F)
  BiocManager::install("snpStats", ask = F, update = F)
}


rm(list=ls())
# loading packages for GAPIT and GAPIT functions
#source("http://www.zzlab.net/GAPIT/GAPIT.library.R")
source("http://www.zzlab.net/GAPIT/gapit_functions.txt")


# loading data set
myY=read.table(file="http://zzlab.net/GAPIT/data/mdp_traits.txt", head = TRUE)
myGD=read.table("http://zzlab.net/GAPIT/data/mdp_numeric.txt",head=T)
myGM=read.table("http://zzlab.net/GAPIT/data/mdp_SNP_information.txt",head=T)

# performing simulation phenotype
set.seed(198521)
Para=list(h2=0.7,NQTN=20)
mysimulation<-GAPIT(Para=Para,GD=myGD,GM=myGM)
myY=mysimulation$Y

# MLM model
myGAPIT_MLM <- GAPIT(
  Y = myY[,c(1,2)],
  GD = myGD,
  GM = myGM,
  model = "MLM",
  PCA.total = 5,
  file.output = TRUE
)
