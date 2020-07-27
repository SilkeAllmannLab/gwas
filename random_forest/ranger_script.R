# https://uc-r.github.io/random_forests

###################
# 0. Load libraries
# 0. Set variable values
###################
source("random_forest/load_ranger_rf_dependencies.R")

seed_for_r = 123

n_permutations = 100
n_threads      = 2 
kfolds         = 5


##############################
# Section 1: VCF
# Import VCF file transformed  
# Convert genotypes to alleles
# Generates a `genotypes` R object
##############################

source("random_forest/vcf_to_genotype_matrix.R")

################################
# Section 2: phenotype
# Import phenotype data
# Generates a `pheno` R object
################################
pheno <- na.omit(read.delim(file = "data/root_data_fid_and_names.tsv", 
                            header = TRUE, 
                            stringsAsFactors = FALSE, 
                            colClasses = c("character","numeric","character")
                            )
                 ) %>% 
  dplyr::select(FID, Ratio) %>% 
  remove_rownames() 


# create object ready for random forest
df <- dplyr::inner_join(genotypes, pheno, by = "FID") %>% 
  dplyr::select(- FID)

###################################
# Section 3: Random Forest analysis
###################################
set.seed(seed_for_r)


#####################################################################
# Section 3.1: K-fold cross-validation to estimate model average RMSE 
#####################################################################

# Rsample implementation of cross validation
cv_split <- vfold_cv(data = df, v = kfolds)

# makes two dataframes per fold: one for training and one for testing
cv_data <- cv_split %>% 
  mutate(
    # Extract the train dataframe for each split
    training = map(splits, ~training(.x)), 
    # Extract the validate dataframe for each split
    testing = map(splits, ~testing(.x))
  )


##############################################################
# Section 3.2: create Random Forest model (from original data)
##############################################################

# hyperparameter grid search --> same as above but with increased mtry values
hyper_grid <- expand.grid(
  ntree     = seq(1000, 10000, by = 500),
  OOB_RMSE  = 0
)

# perform grid search
for(i in 1:nrow(hyper_grid)) {
  
  # train model
  rf_model <- ranger(
    dependent.variable.name = "Ratio",
    data                    = train_data, 
    sample.fraction         = 1, # take all data
    num.trees               = hyper_grid$ntree[i],
    seed                    = seed_for_r,
    importance = "permutation"
  )
  
  # add OOB Root Mean Squared Error to grid
  hyper_grid$OOB_RMSE[i] <- sqrt(rf_model$prediction.error)
}

# extract the best parameters
best_params <- hyper_grid[which.min(hyper_grid$OOB_RMSE),]

rf_optimised_model <- ranger(
  dependent.variable.name        = "Ratio",
  data                           = df,
  num.trees                      = best_params$ntree,
  mtry                           = best_params$mtry,
  min.node.size                  = best_params$node_size,
  sample.fraction                = best_params$sample_size,
  seed                           = seed_for_r,
  importance                    = "permutation",
  write.forest                  = TRUE,
  num.threads                   = n_threads
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
  labs(x = "SNP identifier", y = "SNP importance") +
  ggtitle("Top 25 important variables")


##############################################################
# Calculate optimised Random Forest p-value using permutations
##############################################################

# generate N permuted dataframes on the phenotype column

# run the optimised Random Forest model on each permuted dataframe

# gather the RMSE metric and compare the original RMSE to the distribution of permuted RMSE

###########################################
# Calculate SNP p-values using permutations
###########################################

snp_pvalues <- importance_pvalues(
  x                = rf_optimised_model, 
  method           = "altmann",
  formula          = Ratio ~ .,
  data             = df,
  num.permutations = n_permutations,
  num.threads      = n_threads
  )




