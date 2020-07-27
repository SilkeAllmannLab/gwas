# load dependencies for MUVR analysis
if ("MUVR" %in% installed.packages()){
  library("MUVR")
} else {
  library("devtools")
  install_git("https://gitlab.com/CarlBrunius/MUVR.git")
  library("MUVR")
}

if ("doParallel" %in% installed.packages()){
  library("doParallel")
} else {
  library("devtools")
  install_version("devtools", version = "1.0.14")
  library("doParallel")
}

if ("tidyverse" %in% installed.packages()){
  library("tidyverse")
} else {
  library("devtools")
  install_version("tidyverse", version = "1.2.0")
  library("tidyverse")
}

library("vcfR")