#!/bin/bash

# Usage: bash vcf_to_binary_matrix.sh <gzipped vcf_file> <transformed gzipped vcf_file>

vcftools --vcf $1 --012 --out $2