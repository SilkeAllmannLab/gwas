library("patchwork")

pheno_df <- na.omit(read.csv(file = "data/Root_data_2020.csv", 
                            header = TRUE, 
                            stringsAsFactors = FALSE))

control_vs_hexanal_plot = 
  pheno_df %>% 
  select(native_name, Mean_Length_C, Mean_Length_E) %>% 
  pivot_longer(- native_name, names_to = "condition", values_to = "length") %>% 
  ggplot(., aes(x = length)) +
    geom_density() +
    facet_wrap(~ condition)

ratio_plot = pheno_df %>% 
  select(native_name, Ratio) %>% 
  pivot_longer(- native_name, names_to = "condition", values_to = "length") %>% 
  ggplot(., aes(x = length)) +
  geom_density() +
  ggtitle("Distribution of Control/Hexanal ratios")

control_vs_hexanal_plot / ratio_plot
