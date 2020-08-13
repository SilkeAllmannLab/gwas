FROM ubuntu:18.04

LABEL author="m.galland@uva.nl" \
      description="A Docker image used to build a container usable for a k-mers GWAS analysis to find SNPs related to a phenotype" \
      usage="docker run --name kmers gwas/kmers:latest" \
      url="https://github.com/voichek/kmersGWAS" 


ENV DEBIAN_FRONTEND=noninteractive

# installation of both R and Python2.7
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    r-base r-cran-mass\
    python2.7 python-pip python-setuptools python-dev

# R dependencies
RUN R -e "install.packages('mvnpermute')" \
    && R -e "install.packages('matrixcalc')" \
    && R -e "install.packages('mvnpermute')" 

WORKDIR /kmers

COPY ./bin/ /kmers/bin/ 
COPY ./src/ /kmers/src/ 
COPY ./build/ /kmers/build/ 
COPY ./external_programs/ /kmers/external_programs/
COPY ./include/ /kmers/include/ 
COPY kmers_gwas.py /kmers/


CMD ["python2", "kmers_gwas.py"]