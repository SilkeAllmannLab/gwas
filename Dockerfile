FROM rocker/tidyverse:3.6.3

LABEL author="m.galland@uva.nl" \
      description="A Docker image used to build a container usable for a GWAS analysis to find SNPs related to a phenotype" \
      usage="docker run allmann/gwas:latest" \
      url="https://github.com/SilkeAllmannLab/gwas" \
      rversion="3.6.3"

# R packages. 
RUN R -e "install.packages('vcfR')" \
 && R -e "install.packages('optparse')" \
 && R -e "install.packages('statgenGWAS')" 



# add GWAS scripts     
COPY ["./scripts/vcf2genotypes.R", "/rainbowr/scripts/"]
COPY ["./rainbowr_gwas.R",  "/rainbowr/"]

# Make the main script executable
#RUN chmod +x /rainbowr/rainbowr_gwas.R

# ENTRYPOINT specifies the default command (will always run)
ENTRYPOINT ["Rscript", "/rainbowr/rainbowr_gwas.R"]
# CMD can be overwritten e.g. by passing --vcf and --phenotype arguments
CMD ["--help"]