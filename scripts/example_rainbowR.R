require(RAINBOWR)
#> Loading required package: RAINBOWR

### Load example datasets
data("Rice_Zhao_etal")
Rice_geno_score <- Rice_Zhao_etal$genoScore
Rice_geno_map <- Rice_Zhao_etal$genoMap
Rice_pheno <- Rice_Zhao_etal$pheno


trait.name <- "Flowering.time.at.Arkansas"
y <- Rice_pheno[, trait.name, drop = FALSE]

x.0 <- t(Rice_geno_score)
MAF.cut.res <- MAF.cut(x.0 = x.0, map.0 = Rice_geno_map)
x <- MAF.cut.res$x
map <- MAF.cut.res$map

# prepare data for GWAS
modify.data.res <- modify.data(pheno.mat = y, 
                               geno.mat = x, 
                               map = map,
                               return.ZETA = TRUE, 
                               return.GWAS.format = TRUE)

pheno.GWAS <- modify.data.res$pheno.GWAS
geno.GWAS <- modify.data.res$geno.GWAS
ZETA <- modify.data.res$ZETA

# GWAS analysis
normal.res <- RGWAS.normal(pheno = pheno.GWAS, 
                           geno = geno.GWAS,
                           plot.qq = FALSE, 
                           plot.Manhattan = FALSE,
                           ZETA = ZETA, 
                           n.PC = 4, 
                           P3D = TRUE, 
                           count = FALSE)