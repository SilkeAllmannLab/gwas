# Genome-Wide Association Study (GWAS) pipeline based on GAPIT and the Snakemake workflow manager

[![Snakemake](https://img.shields.io/badge/snakemake-≥5.4.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/snakemake-workflows/gwas.svg?branch=master)](https://travis-ci.org/snakemake-workflows/gwas)

A Snakemake pipeline to perform a Genome Wide Analysis (GWAS) using _Arabidopsis thaliana_ genetic variant information and phenotyping information.

Running this pipeline will generate a (i) Manhattan plot and a table of SNP associated with the phenotype of interest. 

 

<!-- MarkdownTOC autolink="true" levels="1,2" -->

- [1. Output](#1-output)
	- [1.1 Manhattan plot](#11-manhattan-plot)
- [2. Datasets](#2-datasets)
	- [2.1 VCF dataset](#21-vcf-dataset)
	- [2.2 Phenotypes](#22-phenotypes)
- [2. Installation](#2-installation)
	- [2.1 Install RStudio](#21-install-rstudio)
	- [2.1 Clone the repository](#21-clone-the-repository)
	- [2.2 Run the gwas.R script](#22-run-the-gwasr-script)
- [3. References](#3-references)
	- [:writing\_hand: Authors](#writing_hand-authors)
	- [VariantR](#variantr)
	- [RainbowR](#rainbowr)

<!-- /MarkdownTOC -->

# 1. Output

This pipeline will generate several GWAS output such as:

## 1.1 Manhattan plot
<img src="./img/manhattan_plot.png" width="600px" alt="Manhattan plot"> 


# 2. Datasets

All input data are to be found in `data/`.

## 2.1 VCF dataset
The VCF data from a study from [Arouisse et al. 2019](https://onlinelibrary.wiley.com/doi/full/10.1111/tpj.14659).

The VCF file itself can be downloaded directly from [FigShare (file is called "Arabidopsis_2029_Maf001_Filter80")](https://figshare.com/projects/Imputation_of_3_million_SNPs_in_the_Arabidopsis_regional_mapping_population/72887).

_Test file_: a small subset of the massive initial VCF file is available for testing purposes. It can be found at 


## 2.2 Phenotypes
Describe origin of phenotype data here...



# 2. Installation 

## 2.1 Install RStudio
If not already done, install [R](https://www.r-project.org/) and [RStudio](https://rstudio.com/) for your Operating System. 

## 2.1 Clone the repository
1. Open RStudio. 
2. Select "File > New Project". 
3. 


## 2.2 Run the gwas.R script
Open RStudio and the `gwas.R` script located in `scripts/`.

# 3. References 

## :writing\_hand: Authors

* Marc Galland (@mgalland)
* Martha van Os (@MvanOs)
* Machiel Clige (@BertusMuscari)

## VariantR

## RainbowR
The [RAINBOWR R](https://doi.org/10.1371/journal.pcbi.1007663) package was used to perform GWAS analysis.  

