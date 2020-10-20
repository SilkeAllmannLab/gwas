FROM rocker/tidyverse:3.6.3

LABEL author="m.galland@uva.nl" \
      description="A Docker image used to build a container usable for a GWAS analysis to find SNPs related to a phenotype" \
      usage="docker run allmann/gwas:latest" \
      url="https://github.com/SilkeAllmannLab/gwas" \
      rversion="3.6.3"

# package units (for RAINBOWR)
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libglu1-mesa-dev \
    r-cran-rgl 


# R packages. 
RUN R -e "install.packages('rgl')" \
 && R -e "install.packages('vcfR')" \
 && R -e "install.packages('optparse')" \
 && R -e "install.packages('BiocManager')" \
 && R -e "BiocManager::install('ggtree')" \
 && R -e "install.packages('RAINBOWR')" 


      
WORKDIR /rainbowr/
COPY ["./rainbowr_gwas.R",  "/rainbowr/"]
COPY ["./scripts/vcf2genotypes.R", "/rainbowr/"]

CMD ["Rscript", "/rainbowr/rainbowr_gwas.R", "--help"]