#!/usr/bin/env Rscript

##############################
# Section 0: load libraries
##############################
source("load_dependencies.R")

# create parser 
option_list = list(
  make_option(c("--vcf"), 
              type = "character", 
              default = NULL, 
              help="Path to VCF file (gzipped or not)", 
              metavar="character"),
  make_option(c("-f", "--phenotype"),
              type = "character", 
              default = NULL,
              metavar = "character",
              help = "Phenotype input tab-separated file (2 columns: id and pheno value)"),
  make_option(c("-d", "--outdir"), 
              type="character", 
              default="gwas_results/", 
              help="output directory where to store results [default= %default]", 
              metavar="character"),
  make_option(c("-s", "--n_snps"), 
              type="integer", 
              default=-1, 
              help="Number of SNPs to consider in input VCF file (default to -1 for all SNPs)",
              metavar="integer"),
  make_option(c("-p", "--n_cores"), 
              type="integer", 
              default = 1, 
              help="Number of cores/CPUs to use (parallel execution) [default= %default]",
              metavar="integer"),
  make_option(c("-n", "--n_reps"), 
              type = "integer", 
              default = 5, 
              help="Number of repetitions to perform (set to >= 100 for real runs) [default= %default]",
              metavar="integer"),
  make_option(c("-o", "--n_outer"), 
              type = "integer", 
              default=7, 
              help="Number of outer test segments to perform [default= %default]",
              metavar="integer"),
  make_option(c("-i", "--n_inner"), 
              type = "integer", 
              default = 4, 
              help="Number of inner test segments to perform [default= %default]",
              metavar="integer"),
  make_option(c("-m", "--model"), 
              type="character", 
              default = "min", 
              help="Model choice ('min', 'mid' or 'max') [default= %default]"),
  make_option(c("-r1", "--start_variable_ratio"), 
              type="double", 
              default=0.6, 
              help="Starting point for best ratio of variables search [default= %default]"),
  make_option(c("-r2", "--stop_variable_ratio"), 
              type="double", 
              default=0.9, 
              help="End point for best ratio of variables search [default= %default]"),
  make_option(c("-r3", "--step_variable_ratio"), 
              type="double", 
              default=0.1, 
              help="Step size for best ratio of variables search [default= %default]"),
  make_option(c("-k", "--n_permutations"), 
              type = "integer", 
              default=100,
              metavar = "integer",
              help="Number of permutations [default= %default]")
) 
opt_parser = OptionParser(option_list=option_list,
                          description = "\n A program to perform GWAS analysis using the Random Forest ML algorithm",
                          epilogue = "Please visit https://github.com/SilkeAllmannLab/gwas for additional information");
args = parse_args(opt_parser)


#############################
# Section 0: make cluster
#############################
cl = makeCluster(args$n_cores)
registerDoParallel(cl)

##############################
# Section 1: VCF
# Import VCF file transformed
# Convert genotypes to alleles
# Generates a `genotypes` R object
##############################
source("vcf2genotypes.R")

vcf <- read.vcfR(args$vcf,
                 verbose = TRUE,
                 nrows = args$n_snps,
                 convertNA = TRUE,
                 checkFile = TRUE)

cat("\nCreating genotype matrix\n")
genotypes <- convert_vcf_to_genotypes(vcf)

#######################
# Section 2: phenotypes
# Import phenotype file   
#######################

phenotypes <- read.delim(args$phenotype, header = TRUE) %>% 
  select(id, phenotype) %>% 
  mutate(id = as.character(id))

phenotypes = na.omit(phenotypes)

################################
# Section 3: prepare data for RF
################################

df <- inner_join(genotypes, phenotypes, by = "id") 
X = df %>% dplyr::select(- id, - phenotype)  
Y = df$phenotype
IDs = df$id

############################
# hyperparameter grid search
###########################

# grid search params
start_ratio <- args$start_variable_ratio
end_ratio <-   args$stop_variable_ratio
step_ratio <-  args$step_variable_ratio

hyper_grid <- expand.grid(
  ratio     = seq(from = start_ratio, 
                  to   = end_ratio, 
                  by   = step_ratio),
  q2     = 0 # will be used to collect the Q2 metric for each RF model
)

for (i in 1:nrow(hyper_grid)){
  print(paste0("testing combination ", i, " out of ", nrow(hyper_grid)))
  
  rf_model <- MUVR(X = X, 
                   Y = Y,
                   ID = IDs,
                   nRep = args$n_reps,
                   nOuter = args$n_outer,
                   nInner = args$n_inner,
                   varRatio = hyper_grid$ratio[i],
                   scale = FALSE, 
                   DA = FALSE, 
                   fitness = "RMSEP", 
                   method = "RF", 
                   parallel = TRUE)
  
  hyper_grid$q2[i] <- rf_model$fitMetric$Q2[1] # min model
}

# plot evolution of Q2 against parameters
optimization_plot <- hyper_grid %>% 
  mutate(ratio = as.factor(ratio)) %>% 
  rownames_to_column("combination") %>% 
  mutate(combination = as.numeric(combination)) %>% 
  ggplot(., aes(combination, y = q2)) + 
  geom_point() + 
  scale_y_continuous(limits = c(0,1))

# extract the best parameters
best_params <- hyper_grid[which.max(hyper_grid$q2),]

################################################
# Section 3: MUVR Random Forest with best params
################################################


rf_model <- MUVR(X = X, 
                 Y = Y,
                 ID = IDs,
                 nRep = args$n_reps,
                 nOuter = args$n_outer,
                 nInner = args$n_inner,
                 varRatio = best_params$ratio,
                 scale = FALSE, 
                 DA = FALSE, 
                 fitness = "RMSEP", 
                 method = "RF", 
                 parallel = TRUE)

#######################
# Permutation analysis
#######################

### Part 1: permutations ###
# compute permuted models 
# collect Q2 from permutations
perm_fit = numeric(args$n_permutations)

# computed permuted models
# collect permuted feature importances
features_permuted_pvalues_matrix <- matrix(0, 
                                           nrow = ncol(X), # One row = one feature
                                           ncol = args$n_permutations)

rownames(features_permuted_pvalues_matrix) = colnames(X)
colnames(features_permuted_pvalues_matrix) = paste0("permutation",seq(1:args$n_permutations))

# permutations
cat("\nStarting permutations")
for (p in 1:args$n_permutations) {
  cat('\nPermutation',p,'of', args$n_permutations)
  YPerm = sample(Y)
  
  perm = MUVR(X         = X, 
              Y         = YPerm,
              ID =        df$id,
              nRep      = args$n_reps,
              nOuter    = args$n_outer,
              varRatio  = best_params$ratio,
              scale     = FALSE, 
              DA        = FALSE, 
              fitness   = "RMSEP", 
              method    = "RF", 
              parallel  = TRUE)
  # for model
  perm_fit[p] = perm$fitMetric$Q2
  
  # for each variable
  features_permuted_pvalues_matrix[,p] = as.vector(perm$VIP[,"min"])
}

### Part 2: plot of RF model (actual fit vs permuted fits) ###
cat("\nCreating permutation plot for Random Forest model")
# actual (original RF mode)
actual_fit <- rf_model$fitMetric$Q2[1] #(1 = "min model")

# Parametric (Student’s) permutation test significance
pvalue <- pPerm(actual = actual_fit, 
                h0 = perm_fit,
                side = "greater",
                type = "t")

plotPerm(actual = actual_fit, 
         xlab = "Q2 metric",
         h0 = perm_fit) 


perm_fit_df = data.frame(permutation = seq(1:length(perm_fit)), 
                         q2 = perm_fit) 

model_permutation_plot <- ggplot(perm_fit_df, aes(x = q2)) + 
  geom_histogram(bins = 10) + 
  geom_vline(xintercept = actual_fit, col = "blue") + 
  labs(x = "Q2 metric", y = "Frequency") +
  ggtitle(paste("Distribution of Q2 p-values based on \n",
                args$n_permutations,
                "permutations of the Y variable \n p-value = ",
                format(pvalue,digits = 3, decimal.mark = "."),sep = " "
  ))


### Part 3: extract significant p-values for each variable ###



####################################
# Section 4: save RF model and plots
####################################

save(df,
     X,
     Y,
     args,
     rf_model,
     hyper_grid,
     best_params,
     optimization_plot,
     model_permutation_plot,
     features_permuted_pvalues_matrix,
     file = file.path(args$outdir,"rf_analysis.RData"),
     compress = "gzip",
     compression_level = 6)


cat("\nSuccessful run\n")
cat("\n##############\n")
cat("\n","Data saved to",file.path(args$outdir,"rf_analysis.RData"),"\n")