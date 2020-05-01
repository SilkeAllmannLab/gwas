# Genome-Wide Association Study (GWAS) pipeline based on GAPIT and the Snakemake workflow manager

[![Snakemake](https://img.shields.io/badge/snakemake-≥5.4.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/snakemake-workflows/gwas.svg?branch=master)](https://travis-ci.org/snakemake-workflows/gwas)

This is the template for a new Snakemake workflow. Replace this text with a comprehensive description covering the purpose and domain.
Insert your code into the respective folders, i.e. `scripts`, `rules`, and `envs`. Define the entry point of the workflow in the `Snakefile` and the main configuration in the `config.yaml` file.

## Authors

* Marc Galland (@mgalland)
* Martha van Os (@MvanOs)
* Machiel XX (@BertusMuscari)

1. [VCF dataset](#vcf-dataset)
2. [VCF dataset](#vcf-dataset)
3. [VCF dataset](#vcf-dataset)
4. [VCF dataset](#vcf-dataset)

## VCF dataset
The complete VCF file called `1001genomes_snp-short-indel_only_ACGTN_v3.1.snpeff.garys.final.vcf.gz` comes from 2016 publication from the 1001 Genomes Consortium:       
1,135 Genomes Reveal the Global Pattern of Polymorphism in Arabidopsis thaliana. The 1001 Genomes Consortium (2016). Cell, 166:(2):481-491. https://doi.org/10.1016/j.cell.2016.05.063.   
This file can be downloaded from the EBI ENA archive: https://www.ebi.ac.uk/ena/data/view/PRJNA273563

The VCF dataset was filtered using a list of accessions (available [here](data/180_accessions_Nordborg.tsv) using `bcftools` 1.7 and the following command: `bcftools view -S 180_accessions_list.txt 1001genomes_snp-short-indel_only_ACGTN_v3.1.snpeff.garys.final.vcf > filtered.vcf`  
The 

## Usage

### Simple

#### Step 1: Install workflow

If you simply want to use this workflow, download and extract the [latest release](https://github.com/snakemake-workflows/gwas/releases).
If you intend to modify and further extend this workflow or want to work under version control, fork this repository as outlined in [Advanced](#advanced). The latter way is recommended.

In any case, if you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repository and, if available, its DOI (see above).

#### Step 2: Configure workflow

Configure the workflow according to your needs via editing the file `config.yaml`.

#### Step 3: Execute workflow

Test your configuration by performing a dry-run via

    snakemake --use-conda -n

Execute the workflow locally via

    snakemake --use-conda --cores $N

using `$N` cores or run it in a cluster environment via

    snakemake --use-conda --cluster qsub --jobs 100

or

    snakemake --use-conda --drmaa --jobs 100

If you not only want to fix the software stack but also the underlying OS, use

    snakemake --use-conda --use-singularity

in combination with any of the modes above.
See the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/executable.html) for further details.

# Step 4: Investigate results

After successful execution, you can create a self-contained interactive HTML report with all results via:

    snakemake --report report.html

This report can, e.g., be forwarded to your collaborators.

### Advanced

The following recipe provides established best practices for running and extending this workflow in a reproducible way.

1. [Fork](https://help.github.com/en/articles/fork-a-repo) the repo to a personal or lab account.
2. [Clone](https://help.github.com/en/articles/cloning-a-repository) the fork to the desired working directory for the concrete project/run on your machine.
3. [Create a new branch](https://git-scm.com/docs/gittutorial#_managing_branches) (the project-branch) within the clone and switch to it. The branch will contain any project-specific modifications (e.g. to configuration, but also to code).
4. Modify the config, and any necessary sheets (and probably the workflow) as needed.
5. Commit any changes and push the project-branch to your fork on github.
6. Run the analysis.
7. Optional: Merge back any valuable and generalizable changes to the [upstream repo](https://github.com/snakemake-workflows/gwas) via a [**pull request**](https://help.github.com/en/articles/creating-a-pull-request). This would be **greatly appreciated**.
8. Optional: Push results (plots/tables) to the remote branch on your fork.
9. Optional: Create a self-contained workflow archive for publication along with the paper (snakemake --archive).
10. Optional: Delete the local clone/workdir to free space.


## Testing

Tests cases are in the subfolder `.test`. They are automtically executed via continuous integration with Travis CI.

