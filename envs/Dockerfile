FROM rocker/tidyverse:3.6.0

LABEL author="m.galland@uva.nl" \
      description="A Docker image used to build a container usable for a Random Forest analysis to find SNPs related to a phenotype" \
      usage="docker run allmann/gwas:latest" \
      url="https://github.com/SilkeAllmannLab/gwas" \
      rversion="3.6.0"


WORKDIR /home/gwas/

# add R scripts 
COPY ["./gwas.R",  "./load_dependencies.R", "./vcf2genotypes.R", "/home/gwas/"]

# R packages. 
RUN R -e "install.packages('yaml')" \
      && R -e "install.packages('doParallel', version = '1.0.14')" \
      && R -e "install.packages('vcfR')" \
      && R -e "devtools::install_git('https://gitlab.com/CarlBrunius/MUVR.git')" 
      

# if no arguments are provided, will print help and exit
# additional arguments will be appended to the command
ENV PATH="/home/gwas/:$PATH"

#ENTRYPOINT ["Rscript gwas.R"]


