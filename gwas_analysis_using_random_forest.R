##############################
# Section 0: load libraries
##############################
source("scripts/load_muvr_dependencies.R")

########################################
# Section 0: load user-chosen parameters
########################################
params <- read_yaml("config.yml")

# vcfR
max_ram = params$ram   # max RAM to use to read the VCF file
n_snps = params$snps   # number of rows to read. 

# MUVR
n_cores = params$n_cores
n_repetitions = params$n_repetitions                     # Number of MUVR repetitions
n_outer = params$n_outer                                 # Number of outer cross-validation segments
n_inner = params$n_inner                                 # Number of inner cross-validation segments 
ratio_of_variables_maintained = params$variable_ratio    # Proportion of variables kept per iteration 



##############################
# Section 0: make cluster
##############################
cl=makeCluster(n_cores) 
registerDoParallel(cl)

##############################
# Section 1: VCF
# Import VCF file transformed  
# Convert genotypes to alleles
# Generates a `genotypes` R object
##############################
source("scripts/vcf2genotypes.R")

vcf <- read.vcfR("data/Arabidopsis_2029_Maf001_Filter80.ten_thousand_lines.vcf.gz", 
          verbose = TRUE,
          limit = max_ram,
          nrows = n_snps,
          convertNA = TRUE, 
          checkFile = TRUE)

genotypes <- convert_vcf_to_genotypes(
  vcf_object = vcf,
  return_alleles = FALSE,
  convert_dot_to_na = TRUE)

#######################
# Section 2: phenotypes
# Import phenotype file   
#######################

phenotypes <- read.delim("data/root_data_fid_and_names.tsv", header = TRUE) %>% 
  select(id, phenotype) %>% 
  mutate(id = as.character(id))

phenotypes = na.omit(phenotypes)

#######################
# Section 3: MUVR Random Forest
# Import phenotype file   
#######################

df <- inner_join(genotypes, phenotypes, by = "id") 

X = df %>% dplyr::select(- id, - phenotype)  
Y = df$phenotype

rf_model <- MUVR(X = X, 
                 Y = Y,
                 ID = df$id,
                 nRep = n_repetitions,
                 nOuter = n_outer,
                 nInner = n_inner,
                 varRatio = ratio_of_variables_maintained,
                 scale = FALSE, 
                 DA = FALSE, 
                 fitness = "RMSEP", 
                 method = "RF", 
                 parallel = TRUE)

plotVAL(rf_model)

plotMV(rf_model)
