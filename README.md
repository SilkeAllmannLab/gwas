# Genome-Wide Association Study (GWAS) pipeline based on GAPIT and the Snakemake workflow manager

[![Snakemake](https://img.shields.io/badge/snakemake-≥5.4.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/snakemake-workflows/gwas.svg?branch=master)](https://travis-ci.org/snakemake-workflows/gwas)

A Snakemake pipeline to perform a GWAS analysis based on the GAPIT R program. 

## :writing\_hand: Authors

* Marc Galland (@mgalland)
* Martha van Os (@MvanOs)
* Machiel Clige (@BertusMuscari)


# Input data

All input data are to be found in `data/`.

## VCF dataset
The complete VCF file called `1001genomes_snp-short-indel_only_ACGTN_v3.1.snpeff.garys.final.vcf.gz` comes from 2016 publication from the 1001 Genomes Consortium:       
1,135 Genomes Reveal the Global Pattern of Polymorphism in Arabidopsis thaliana. The 1001 Genomes Consortium (2016). Cell, 166:(2):481-491. https://doi.org/10.1016/j.cell.2016.05.063.   
This file can be downloaded from the EBI ENA archive: https://www.ebi.ac.uk/ena/data/view/PRJNA273563

The VCF dataset was filtered using a list of accessions (available [here](data/180_accessions_Nordborg.tsv) using `bcftools` 1.7 and the following command: `bcftools view -S 180_accessions_list.txt 1001genomes_snp-short-indel_only_ACGTN_v3.1.snpeff.garys.final.vcf > filtered.vcf`  
The 

## Phenotypes
Describe origin of phenotype data here...

# Usage


# Reference

## Authors

* Marc Galland (@mgalland)
* Martha van Os (@MvanOs)
* Machiel Clige (@BertusMuscari)

## Citation
How to cite this pipeline.

## References
* GAPIT
* Snakemake
