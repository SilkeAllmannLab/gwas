FROM allmann/gwas-base:3.6

LABEL author="m.galland@uva.nl" \
      description="A Docker image used to build a container usable for a Random Forest analysis to find SNPs related to a phenotype" \
      usage="docker run allmann/gwas:latest" \
      url="https://github.com/SilkeAllmannLab/gwas" \
      rversion="3.6.0"      


# add R scripts 
WORKDIR /home/
COPY ["./gwas.R",  "/home/"]
COPY ["./vcf2genotypes.R", "/home/"]

ENTRYPOINT ["Rscript", "/home/gwas.R"]


