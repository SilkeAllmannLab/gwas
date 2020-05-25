# change line identifier number in VCF file by its unique name
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))

###############################################################
# 1. Extract Arabidopsis ecotype numbers to name correspondence 
###############################################################

# Supplemental table 3 from Arouisse et al 2020 (PMID: 31856318 DOI: 10.1111/tpj.14659) 
suppl3 <- read.csv("info/Supplementary_table_3.csv", stringsAsFactors = FALSE)
suppl3_ids_and_names <- suppl3[,c("FID","name")]

#######################################
# 2. Add FID number to phenotyping data
#######################################
pheno <- read.csv(file = "data/Root_data_2020.csv", header = TRUE, stringsAsFactors = FALSE)
pheno <- pheno %>% 
  dplyr::select(name, Ratio) %>% 
  left_join(., suppl3_ids_and_names, by = "name") 
  
# save to file
write.table(pheno, file = "data/root_data_fid_and_names.tsv", 
            sep = "\t", 
            quote = FALSE, 
            row.names = FALSE)