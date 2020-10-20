#!/usr/bin/env python
# coding: utf-8
# Usage: python add_gene.py chrom_pos_marker.tsv chr01_start_end_gene.tsv chr01_genes_with_marker.tsv

# In[1]:

import sys
import pandas as pd


# file with chromosome position marker id
chrom_pos_marker_id_file_path = sys.argv[1]

# file with chrom start end gene
chrom_start_end_gene_file_path = sys.argv[2] 

# out file
outfile = sys.argv[3]


# In[2]:
chrom_pos_marker = pd.read_csv(chrom_pos_marker_id_file_path,
    sep="\t",
    names=["chrom","pos","marker_id"])


# In[3]:
genes = pd.read_csv(chrom_start_end_gene_file_path,
    sep="\t",
    names=["chrom","start","end","gene"])



# to collect gene as key and marker as values
gene_to_marker_dict = {}

# two loops
# outer loop iterates over each Arabidopsis gene
# inner loop iterates over each marker
n_genes = genes.shape[0]

for i in range(0,n_genes,1): 
    # collect the chromosome + positions of gene number i
    row = genes.iloc[i,:]
    chrom_gene = row["chrom"]
    start_gene = row["start"]
    end_gene   = row["end"]
    gene       = row["gene"]
    
    print("working on gene:",gene)
    
    # find chromosome of gene and filter the chrom_pos_marker dataframe
    chrom_pos_marker_filtered = chrom_pos_marker.query('chrom == @chrom_gene')
    
    # is the SNP marker position between start and end position of the gene number i?    
    for j in range(0,chrom_pos_marker_filtered.shape[0],1):
        marker_j = chrom_pos_marker_filtered.iloc[j,:]
        if start_gene <= marker_j["pos"] <= end_gene:
            gene_to_marker_dict[gene] = marker_j["marker_id"]


# In[ ]:


genes_with_marker = pd.DataFrame.from_dict(gene_to_marker_dict, orient = "index",columns=["marker_id"])
genes_with_marker.reset_index(level = 0, inplace = True)
genes_with_marker = genes_with_marker.rename(columns={"index":"gene"})


# In[ ]:
genes_with_marker.to_csv(outfile, sep = "\t")



