# From SNPs to phenotype using Random Forest 

A pipeline to relate Single Nucleotide Polymorphisms (SNPs) to a continuous phenotype using a Random Forest approach from the `MUVR` package. It is meant to perform a similar analysis as Genome Wide Analysis (GWAS) using genetic variant (Variant Call Format) and phenotype information. Yet, it brings the power and accuracy of the Machine Learning Random Forest approach. 

 
<!-- MarkdownTOC autolink="true" levels="1,2" -->

- [Inputs and outputs](#inputs-and-outputs)
	- [Inputs](#inputs)
	- [Outputs](#outputs)
- [Example datasets](#example-datasets)
	- [2.1 VCF dataset](#21-vcf-dataset)
	- [2.2 Phenotypes](#22-phenotypes)
- [Installation](#installation)
	- [Install RStudio](#install-rstudio)
	- [Clone the repository](#clone-the-repository)
	- [Run the random_forest_gwas.R script](#run-the-random_forest_gwasr-script)
- [References](#references)
	- [:writing\_hand: Authors](#writing_hand-authors)
	- [vcfR](#vcfr)
	- [MUVR](#muvr)

<!-- /MarkdownTOC -->

# Inputs and outputs

## Inputs

### VCF file 
A [Variant Call Format (VCF)](https://en.wikipedia.org/wiki/Variant_Call_Format) file that contains the nucleotidic variations is needed. The VCF file has to be of version 4.0 and higher. It will be converted to a genotype matrix using [vcfR](https://knausb.github.io/vcfR_documentation/index.html) where genotypes are represented by:
- "0" for genome positions homozygous for the reference allele.
- "2" for genome positions homozygous for the alternative allele.
- "1" for genome positions heterozygous (one reference allele, one alternative allele).


### Phenotype file
A tabulated separated file containing two columns:
1. The identifier for each individual. Column name should be `id`.
2. A phenotype column that contains the phenotypic values. Column name should be `phenotype` 


## Outputs

1. A table of the most important SNPs related to the phenotype along with their p-values.
2. A plot of the model Q2 metric compared to a distribution of random Q2 values obtained using N permutations (e.g. N = 100).

# Example datasets

All input data are to be found in `data/`.

## 2.1 VCF dataset
The VCF data from a study from [Arouisse et al. 2019](https://onlinelibrary.wiley.com/doi/full/10.1111/tpj.14659).

The VCF file itself can be downloaded directly from [FigShare (file is called "Arabidopsis_2029_Maf001_Filter80")](https://figshare.com/projects/Imputation_of_3_million_SNPs_in_the_Arabidopsis_regional_mapping_population/72887).

_Test file_: a small subset of the massive initial VCF file is available for testing purposes. It can be found at `data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf`.


## 2.2 Phenotypes
Arabidopsis ecotypes were treated with 2-E-hexanal and their main root length measured. A response ratio was then calculated for each of the ecotypes by comparing the 2-E-hexanal treatment with a mock (methanol).


# Installation 

## Install RStudio
If not already done, install [R (version >= 3.5)](https://www.r-project.org/) and [RStudio](https://rstudio.com/) for your Operating System. 

## Clone the repository
In the Shell, type `git clone https://github.com/SilkeAllmannLab/gwas.git`

## Run the random_forest_gwas.R script
- Open RStudio.
- In RStudio, select "File > New Project". 
- Open the `random_forest_gwas.R` script. 
- Run the script.  

# References 

## :writing\_hand: Authors

* Marc Galland (@mgalland)
* Martha van Os (@MvanOs)
* Machiel Clige (@BertusMuscari)

## vcfR
The R package vcfR is heavily described [here](https://knausb.github.io/vcfR_documentation/index.html).

## MUVR
The MUVR package for R is described [here](https://gitlab.com/CarlBrunius/MUVR).


