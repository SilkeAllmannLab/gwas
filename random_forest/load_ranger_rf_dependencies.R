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

if ("rsample" %in% installed.packages()){
  library("rsample")
} else {
  devtools::install_version('rsample', version = '0.0.6', upgrade = "never") 
}
