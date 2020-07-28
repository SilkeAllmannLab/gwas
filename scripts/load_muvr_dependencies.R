# load dependencies for MUVR analysis
if ("optparse" %in% installed.packages()){
  library("optparse")
} else {
  library("devtools")
  install_version(package = "optparse", version = "1.6.0")
  library("optparse")
}

if ("yaml" %in% installed.packages()){
  library("yaml")
} else {
  library("devtools")
  install_version(package = "yaml", version = "2.2.0")
  library("yaml")
}


if ("MUVR" %in% installed.packages()){
  library("MUVR")
} else {
  library("devtools")
  install_git("https://gitlab.com/CarlBrunius/MUVR.git")
  library("MUVR")
}

if ("doParallel" %in% installed.packages()){
  suppressPackageStartupMessages(library("doParallel"))
} else {
  library("devtools")
  install_version("devtools", version = "1.0.14")
  suppressPackageStartupMessages(library("doParallel"))
}

if ("tidyverse" %in% installed.packages()){
  suppressPackageStartupMessages(library("tidyverse"))
} else {
  library("devtools")
  install_version("tidyverse", version = "1.2.0")
  suppressPackageStartupMessages(library("tidyverse"))
}

if ("vcfR" %in% installed.packages()){
  suppressPackageStartupMessages(library("vcfR"))
} else {
  library("devtools")
  install_version("vcfR", version = "1.11.0")
  suppressPackageStartupMessages(library("vcfR"))
}