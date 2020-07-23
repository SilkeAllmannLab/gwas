# https://uc-r.github.io/random_forests

if ("devtools" %in% installed.packages()){
  library("devtools")
  } else {
    install.packages("devtools")
  }

if ("vcfR" %in% installed.packages()){
  library("vcfR")
} else {
  devtools::install_version('vcfR', version = '1.10.0', upgrade = "never" )
}

if ("ranger" %in% installed.packages()){
  library("ranger")
} else {
  devtools::install_version('ranger', version = '0.12.0', upgrade = "never") 
}

if ("tidyverse" %in% installed.packages()){
  library("tidyverse")
} else {
  devtools::install_version('tidyverse', version = '1.2.0', upgrade = "never") 
}


#checkpoint::checkpoint("2020-06-01")
#library(rsample)      # data splitting 
#library(randomForest) # basic implementation
#library(ranger)       # a faster implementation of randomForest
#library(caret)        # an aggregator package for performing many machine learning models
#library(tibble)


#library(dplyr)

##############################
# Import VCF file transformed  
# Convert genotypes to alleles
##############################

vcf <- read.vcfR("data/chr01.header.Arabidopsis_2029_Maf001_Filter80.vcf.gz", 
                 verbose = FALSE, 
                 nrows = 1000, 
                 convertNA = TRUE, 
                 checkFile = TRUE)

# Extract genotype information
# Rows: individuals
# Columns: SNPs
genotypes <- extract.gt(vcf, 
                        return.alleles = TRUE, 
                        IDtoRowNames = TRUE, 
                        convertNA = TRUE) %>% 
  t(.) %>%                            
  as.data.frame() %>% 
  rownames_to_column("FID")

################################
# Import phenotype data
################################
pheno <- na.omit(read.delim(file = "data/root_data_fid_and_names.tsv", 
                            header = TRUE, 
                            stringsAsFactors = FALSE, 
                            colClasses = c("character","numeric","character")
                            )
                 ) %>% 
  dplyr::select(FID, Ratio) %>% 
  remove_rownames() 

#######################################
# Create object ready for Random Forest
#######################################

df <- dplyr::inner_join(genotypes, pheno, by = "FID") 

# to ensure compatibility with formula (numbers not allowed for columns)
names(df) <- make.names(names(df), allow_ = FALSE) 


######################
# Ranger Random Forest
######################
# hyperparameter grid search --> same as above but with increased mtry values
hyper_grid <- expand.grid(
  ntree     = seq(1000, 10000, by = 1000),
  #mtry       = seq(50, 200, by = 25),
  #node_size  = seq(3, 9, by = 2),
  sample_size = c(.60, .70, .80),
  OOB_RMSE  = 0
)

# perform grid search
for(i in 1:nrow(hyper_grid)) {
  
  # train model
  rf_model <- ranger(
    dependent.variable.name = "Ratio",
    data                    = df, 
    num.trees               = hyper_grid$ntree[i],
    #mtry                    = hyper_grid$mtry[i],
    #min.node.size           = hyper_grid$node_size[i],
    sample.fraction         = hyper_grid$sample_size[i],
    seed                    = 123
  )
  
  # add OOB error to grid
  hyper_grid$OOB_RMSE[i] <- sqrt(rf_model$prediction.error)
}

# extract the best parameters
best_params <- hyper_grid[which.min(hyper_grid$OOB_RMSE),]

rf_optimised_model <- ranger(
  dependent.variable.name = "Ratio",
  data = df,
  num.trees = best_params$ntree,
  mtry = best_params$mtry,
  min.node.size = best_params$node_size,
  sample.fraction = best_params$sample_size,
  seed = 123,
  importance = "permutation",
  write.forest = FALSE,
  num.threads = 2
)

rf_optimised_model$variable.importance %>% 
  as.data.frame() %>% 
  rename("var_imp" = ".") %>% 
  rownames_to_column("snp") %>% 
  dplyr::arrange(desc(var_imp)) %>%
  dplyr::top_n(25) %>%
  ggplot(aes(reorder(snp, var_imp), var_imp)) +
  geom_col() +
  coord_flip() +
  ggtitle("Top 25 important variables")
