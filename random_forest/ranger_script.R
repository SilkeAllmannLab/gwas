# https://uc-r.github.io/random_forests

source("random_forest/load_random_forest_dependencies.R")


###################################
# Transform VCF file into genotypes 
# Converts alleles to binary data (0, 1, 2)
###########################################
vcf_file_path <- "data/Arabidopsis_2029_Maf001_Filter80.1000lines.vcf"

# extracts genotype information from VCF file 
my_genotypes = vcf2genotypes(vcfFile = vcf_file_path) %>% 
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
                 )
pheno <- pheno %>% 
  dplyr::select(FID, Ratio) %>% 
  remove_rownames() 

#######################################
# Create object ready for Random Forest
#######################################

df <- dplyr::inner_join(my_genotypes, pheno, by = "FID") %>% 
  select(- FID)

# to ensure compatibility with formula (numbers not allowed for columns)
names(df) <- make.names(names(df), allow_ = FALSE) 

# hyperparameter grid search --> same as above but with increased mtry values
hyper_grid <- expand.grid(
  ntree     = seq(500, 1000, by = 100),
  mtry       = seq(50, 200, by = 25),
  node_size  = seq(3, 9, by = 2),
  sample_size = c(.55, .632, .70, .80),
  OOB_RMSE  = 0
)

# perform grid search
for(i in 1:nrow(hyper_grid)) {
  
  # train model
  rf_model <- ranger(
    formula         = Ratio ~ ., 
    data            = df, 
    num.trees       = hyper_grid$ntree[i],
    mtry            = hyper_grid$mtry[i],
    min.node.size   = hyper_grid$node_size[i],
    sample.fraction = hyper_grid$sample_size[i],
    seed            = 123
  )
  
  # add OOB error to grid
  hyper_grid$OOB_RMSE[i] <- sqrt(rf_model$prediction.error)
}


best_params <- hyper_grid[which.min(hyper_grid$OOB_RMSE),]

rf_optimised_model <- ranger(
  formula = Ratio ~ .,
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
  rownames_to_column("snp")
  dplyr::arrange(desc(var_imp)) %>%
  dplyr::top_n(25) %>%
  ggplot(aes(reorder(names, var_imp), var_imp)) +
  geom_col() +
  coord_flip() +
  ggtitle("Top 25 important variables")
