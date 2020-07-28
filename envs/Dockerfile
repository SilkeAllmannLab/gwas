FROM rocker/tidyverse:3.6.3

LABEL author="m.galland@uva.nl" \
      description="A Docker image used to build a container usable for a Random Forest analysis to find SNPs related to a phenotype" \
      usage="docker run -e PASSWORD=mypasswd -p 8787:8787 scienceparkstudygroup/master-gls:openr-latest" \
      url="https://github.com/SilkeAllmannLab/gwas" \
      rversion="3.6.3"


WORKDIR /home/gwas/

# add R scripts 
COPY ["gwas.R", "load_muvr_dependencies.R",  "vcf2genotypes.R", "./"]


 # R packages. Specific versions are used here
RUN R -e "devtools::install_version('yaml', version = '2.2.0')" \
      && R -e "devtools::install_version('doParallel', version = '1.0.14')" \
      && R -e "devtools::install_version('tidyverse', version = '1.2.0')" \
      && R -e "devtools::install_version('vcfR', version = '1.11.0')"


