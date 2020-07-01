Notes for a Random Forest analysis of SNPs to dara

# To do:

## Part one = VCFtools
1. Convert the big VCF file into a 012 matrix using vcftools:
  - `vcftools --gzvcf Arabidopsis_2029_Maf001_Filter80.vcf.gz --012 --out vcf_parsed/Arabidopsis_2029_Maf001_Filter80.vcf`.
  - Some options for filtering can be used = `-minQ` for quality  and `--min-meanDP` for depth
  - Do not include indels `--remove-indels`
  
2. Add back the individual names stored in the `.indv` file 
3. It creates a big table with individuals in rows and SNPs in columns

## Part two = adding the phenotyping values
Add the Ratio to the SNP file checking the order of the individuals. Might need to do this with Shell bash (big SNP matrix file)

## Part three = Random Forest in R using ranger