FROM rocker/tidyverse:3.6.3

LABEL author="m.galland@uva.nl" \
      description="A Docker image used to build a container usable for a Random Forest analysis to find SNPs related to a phenotype" \
      usage="docker run -e PASSWORD=mypasswd -p 8787:8787 scienceparkstudygroup/master-gls:openr-latest" \
      url="https://github.com/SilkeAllmannLab/gwas" \
      rversion="3.6.3"


WORKDIR /home/gwas/

# add R scripts 
COPY ["./gwas.R",  "./load_dependencies.R", "./vcf2genotypes.R", "/home/gwas/"]

# R packages. Specific versions are used here
RUN R -e "install.packages('devtools')" \
    && R -e "install.packages('tidyr')" 
      

RUN R -e "devtools::install_version('yaml', version = '2.2.0')" \
      && R -e "devtools::install_version('doParallel', version = '1.0.14')" \
      && R -e "install.packages('vcfR')" \
      && R -e "devtools::install_git('https://gitlab.com/CarlBrunius/MUVR.git')" 


      # && R -e "devtools::install_version('tibble', version = '3.0.0')" \
      # && R -e "devtools::install_version('dplyr', version = '0.8.5')" \
      # && R -e "devtools::install_version('ggplot2', version = '3.3.0')"
      

# if no arguments are provided, will print help and exit
# additional arguments will be appended to the command
ENTRYPOINT ["Rscript gwas.R"]


