FROM rocker/verse:3.6.3

LABEL author="m.galland@uva.nl" \
      description="A Docker image used to build a container usable for a GWAS analysis to find SNPs related to a phenotype" \
      usage="docker run allmann/gwas:latest" \
      url="https://github.com/SilkeAllmannLab/gwas" \
      rversion="3.6.3"

# package units (for RAINBOWR)
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libudunits2-dev \
  apt-utils \
  libmagick++-dev \
  libglu1-mesa-dev  \
  libgdal-dev

# R packages. 
RUN R -e "install.packages('vcfR')" \
 && R -e "install.packages('optparse')" \
 && R -e "install.packages('BiocManager')" \
 && R -e "BiocManager::install('ggtree')" \
 && R -e "devtools::install_github('KosukeHamazaki/RAINBOWR')" 


      
WORKDIR /home/
COPY ["./rainbowr_gwas.R",  "/home/"]
COPY ["./scripts/vcf2genotypes.R", "/home/"]

ENTRYPOINT ["Rscript", "/home/rainbowr_gwas.R"]