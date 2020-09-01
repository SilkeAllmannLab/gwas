FROM rocker/r-ver:3.6.3

LABEL author="m.galland@uva.nl" \
      description="A Docker image used to build a container usable for a Random Forest analysis to find SNPs related to a phenotype" \
      usage="docker run allmann/gwas:latest" \
      url="https://github.com/SilkeAllmannLab/gwas" \
      rversion="3.6.3"

# install devtools first
RUN R -e "install.packages('devtools', dependencies=TRUE)" 

# R packages. 
RUN R -e "install.packages('doParallel', version = '1.0.14')" \
      && R -e "install.packages('vcfR')" \
      && R -e "install.packages('optparse')" \
      && R -e "devtools::install_git('https://gitlab.com/CarlBrunius/MUVR.git')" \
      && R -e "install.packages('RAINBOWR')"   

      
WORKDIR /home/
COPY ["./rainbowr_gwas.R",  "/home/"]
COPY ["./scripts/vcf2genotypes.R", "/home/"]

ENTRYPOINT ["Rscript", "/home/rainbowr_gwas.R"]