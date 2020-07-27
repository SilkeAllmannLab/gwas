if ("MUVR" %in% installed.packages()){
  library("MUVR")
} else {
  library("devtools")
  install_git("https://gitlab.com/CarlBrunius/MUVR.git")
  library("MUVR")
}

library("doParallel")


# Set method parameters
nCore = detectCores()-1   # Number of processor threads to use
nRep = 5                  # Number of MUVR repetitions
nOuter= 8                 # Number of outer cross-validation segments
varRatio = 0.8            # Proportion of variables kept per iteration 
method = 'RF'             # Selected core modelling algorithm
nPerm=2                  # Number of permutations (here set to 25 for illustration; normally set to ≥100) 
permFit=numeric(nPerm)   # Allocate vector for permutation fitness

########################
# classification
########################
cl=makeCluster(nCore)   
registerDoParallel(cl)


# data import
data("mosquito")

# Perform modelling
classModel = MUVR(X=Xotu, 
                  Y=Yotu, 
                  nRep=nRep, 
                  nOuter=nOuter, 
                  varRatio=varRatio, 
                  method=method)
# Stop parallel processing
stopCluster(cl)


################
# regression
################
cl=makeCluster(nCore)   
registerDoParallel(cl)

data("freelive")

regrModel <- MUVR(X = XRVIP, 
                  Y = YR, 
                  ID = IDR, 
                  nRep = 5, 
                  nOuter = 6, 
                  varRatio = 0.8, 
                  method = "RF")
  
# Stop parallel processing
stopCluster(cl)


##############
# permutaitons
##############

cl=makeCluster(nCore)
registerDoParallel(cl)
actual = MUVR(X = Xotu,
              Y = Yotu,
              nRep = nRep,
              nOuter = nOuter,
              varRatio = varRatio,
              method = method) 
actualFit=actual$miss["min"]

for (p in 1:nPerm) {
  cat('\nPermutation',p,'of',nPerm)
  YPerm=sample(Yotu)
  perm=MUVR(X=Xotu,Y=YPerm,nRep=nRep,nOuter=nOuter,varRatio=varRatio,method=method)
  permFit[p]=perm$miss["min"]
}


stopCluster(cl)