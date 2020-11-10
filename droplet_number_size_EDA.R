
## EXPLORATORY DATA ANALYSIS & QC

####### 15/07/2020 - Manuel Cañete
# Script for analysing the number and size of the droplets formed by each XXX
# I should consider differences arising from a) Cell area and b) GFP intensity
# ROIs <- defined manually with: define_ROIs_manual.ijm
# Area and intensity <- obtained with macro: measure_ROI_area_intensity.ijm
# Counts <- obtained with macro: count_particles_from_mask.ijm

####### 23/07/2020 - Manuel Cañete
# I have incorporated data of the intensity of the "soluble" fractions
# Intensity <- measure_soluble_intensity.ijm

####### 28/07/2020 - Manuel Cañete
# I have changed the minimum for the 3D Object Counter from 5 to 10 units
# This new version yields more bona fide results

####### 24/07/2020 - Manuel Cañete - CONCLUSION
# More or less all replicates seem comparable
# The most dissimilar is replicate 2, which has affected XXX specially
# We can procede


# Dependencies ------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(purrr)


# Set working directory ---------------------------------------------------

working_dir <- ""
setwd(working_dir)

# Import data -------------------------------------------------------------

input_file <- "200728_XXX1-4_droplets_analysis.csv"
input_data <- read.csv2(input_file, stringsAsFactors = F)


# Compare replicates ------------------------------------------------------

# Boxplots

variables <- c("Integrated_density_total", "Integrated_density_soluble", "Mean_intensity_total", "Mean_intensity_soluble", "Counts", "Mean_volume", "Median_volume", "Area")

lapply(variables, function(var){
  input_data %>%
    ggplot(aes(x = Replicate, y = !!sym(var), fill = Replicate)) +
      geom_boxplot() +
      facet_wrap(~XXX) +
      ggtitle(paste(var, "across replicates"))
})

# PCA

PC_values <- input_data %>%
  select(Counts, Mean_volume, Area, Mean_intensity_total, Mean_intensity_soluble, Integrated_density_total, Integrated_density_soluble) %>%
  prcomp(center = T, scale = T)

summary(PC_values)

PCA_data <- as.data.frame(PC_values$x[,1:3]) %>%
  cbind(XXX = input_data$XXX) %>%
  cbind(Replicate = input_data$Replicate)

PCA_data %>%
  ggplot(aes(x = PC1, y = PC2, col = Replicate)) +
    geom_point() +
    facet_wrap(~XXX)
  