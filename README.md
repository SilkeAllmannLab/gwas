# From SNPs to phenotype using Random Forest 

A pipeline to relate Single Nucleotide Polymorphisms (SNPs) to a continuous phenotype using a Random Forest approach from the `MUVR` package. It is meant to perform a similar analysis as Genome Wide Analysis (GWAS) using genetic variant (Variant Call Format) and phenotype information. Yet, it brings the power and accuracy of the Machine Learning Random Forest approach. 

 
<!-- MarkdownTOC autolink="true" levels="1,2,3" -->

- [1. Inputs and outputs](#1-inputs-and-outputs)
	- [Inputs](#inputs)
		- [VCF file](#vcf-file)
		- [Phenotype file](#phenotype-file)
	- [Outputs](#outputs)
		- [Table of most important SNPs](#table-of-most-important-snps)
		- [Plot of the model Q2](#plot-of-the-model-q2)
- [2. Installation](#2-installation)
	- [Install RStudio](#install-rstudio)
	- [Clone the repository](#clone-the-repository)
- [3. Test](#3-test)
	- [Example datasets](#example-datasets)
		- [VCF dataset](#vcf-dataset)
		- [Phenotypes](#phenotypes)
	- [Test run](#test-run)
	- [Run the random_forest_gwas.R script](#run-the-random_forest_gwasr-script)
- [4. References](#4-references)
	- [:writing\_hand: Authors](#writing_hand-authors)
	- [vcfR](#vcfr)
	- [MUVR](#muvr)
- [5. Troubleshooting](#5-troubleshooting)
	- [RAINBOWR package](#rainbowr-package)

<!-- /MarkdownTOC -->

# 1. Inputs and outputs

## Inputs

### VCF file 
A [Variant Call Format (VCF)](https://en.wikipedia.org/wiki/Variant_Call_Format) file that contains the nucleotidic variations is needed. The VCF file has to be of version 4.0 and higher. It will be converted to a genotype matrix using [vcfR](https://knausb.github.io/vcfR_documentation/index.html) where genotypes are represented by:
- "0" for genome positions homozygous for the reference allele.
- "2" for genome positions homozygous for the alternative allele.
- "1" for genome positions heterozygous (one reference allele, one alternative allele).

Some useful tools to work with VCF files:
- [vcflib](https://github.com/vcflib/vcflib)
- [VCFtools](https://vcftools.github.io/man_latest.html)

VCFtools can be used to select split the VCF file into chromosomes: `vcftools --gzvcf <input_file.vcf.gz> --chr 1`


### Phenotype file
A tabulated separated file containing two columns:
1. The identifier for each individual. Column name should be `id`.
2. A phenotype column that contains the phenotypic values. Column name should be `phenotype` 


## Outputs

### Table of most important SNPs
A table of the most important SNPs related to the phenotype along with their p-values.

### Plot of the model Q2
A plot of the model Q2 metric compared to a distribution of random Q2 values obtained using N permutations (e.g. N = 100).


# 2. Installation 

## Install RStudio
If not already done, install [R (version >= 3.5)](https://www.r-project.org/) and [RStudio](https://rstudio.com/) for your Operating System. 

## Clone the repository
In the Shell, type `git clone https://github.com/SilkeAllmannLab/gwas.git`

:tada: :confetti_ball:  That's it! :tada: :confetti_ball:

# 3. Test

## Example datasets

All input data are to be found in `data/`.

### VCF dataset
The VCF data from a study from [Arouisse et al. 2019](https://onlinelibrary.wiley.com/doi/full/10.1111/tpj.14659).  
The VCF file itself can be downloaded directly from [FigShare (file is called "Arabidopsis_2029_Maf001_Filter80")](https://figshare.com/projects/Imputation_of_3_million_SNPs_in_the_Arabidopsis_regional_mapping_population/72887).

Number of SNPs per chromosome:

| chrom | # of SNPs |
|-------|-----------|
| chr01 | 734,401   |
| chr02 | 513,750   |
| chr03 | 616,986   |
| chr04 | 496,272   |
| chr05 | 661,335   |

Several files were then generated from this initial big VCF file:
- __Chromosome VCF files__: for instance, for chromosome 1,`chr01.Arabidopsis_2029_Maf001_Filter80.vcf.gz`
- __Randomly subsampled chromosome VCF files__: 10% or more of the initial SNPs were subsampled and extracted on a per-chromosome basis. For instance, for chromosome 1,`chr01.subsampled_10_percent.Arabidopsis_2029_Maf001_Filter80.vcf.gz`
- __Test file__: a small subset available for testing purposes. It can be found at `data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf`.


__Examples of code used:__    

To subsample 10% of the original chr01 VCF file (from \~700,000 variants to 7000)  
```
gzip -c -d chr01.Arabidopsis_2029_Maf001_Filter80.vcf.gz |vcfrandomsample -r 0.01 -p 31 > chr01.subsampled_1_percent.Arabidopsis_2029_Maf001_Filter80.vcf
```

To create one VCF file for each Arabidopsis chromosome:  
```
for i in {1..5}; 
  do echo "working on chromosome $i";
  vcftools  --gzvcf Arabidopsis_2029_Maf001_Filter80.vcf.gz  --chr $i  --recode --recode-INFO-all --out  VCF_chr0$i; 
done
```

### Phenotypes
A `root_data_fid_and_names.tsv` file contains the genotype line identifier and the phenotypic values. Arabidopsis ecotypes were treated with 2-E-hexanal and their main root length measured. A response ratio was then calculated for each of the ecotypes by comparing the 2-E-hexanal treatment with a mock (methanol).


## Test run

## Run the random_forest_gwas.R script
- Open RStudio.
- In RStudio, select "File > New Project". 
- Open the `gwas.R` script. 
- Run the script.  


# 4. References 

## :writing\_hand: Authors

* Marc Galland (@mgalland)
* Martha van Os (@MvanOs)
* Machiel Clige (@BertusMuscari)

## vcfR
The R package vcfR is heavily described [here](https://knausb.github.io/vcfR_documentation/index.html).

## MUVR
The MUVR package for R is described [here](https://gitlab.com/CarlBrunius/MUVR).

# 5. Troubleshooting

## RAINBOWR package
Sometimes, you might have issues with the installation of the `Rccp` package which is a dependency of `RAINBOWR`.

In the Shell, try: `apt-get install r-base-dev`



