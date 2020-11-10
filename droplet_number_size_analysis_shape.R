
## DATA ANALYSIS - SHAPE

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

####### 28/07/2020 - Manuel Cañete
# I observed that some cells were possible outliers for their intensity
# outliers <- input_data[input_data$Integrated_density_total/input_data$Area >= 500, 2]
# I checked them manually --> "200728_XXX1-4_droplets_intensity_outliers_comments.csv"
# I have removed some of them from the analysis 

# I have also removed a very intense cell: "200602_XXXX_GFP_Rep3_XXX3_1_Pos015_S001_0"

####### 29/07/2020 - Manuel Cañete
# I have incorporated data of the shape of the droplets
# This data has been obtained with macro:  measure_sphericity_roundness.ijm

# Dependencies ------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(purrr)
library(tidyr)


# Set working directory ---------------------------------------------------

working_dir <- ""
setwd(working_dir)

# Import data -------------------------------------------------------------

input_file <- "200729_XXX1-4_droplets_analysis.csv"
input_data <- read.csv2(input_file, stringsAsFactors = F)

# Overview of shapes ------------------------------------------------------
# Irrespective of intensity levels

input_data %>%
  ggplot(aes(x = XXX, y = Mean_circ, fill = XXX)) +
  geom_boxplot() +
  theme(panel.border = element_rect(fill = NA),
        panel.grid.minor.y = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        axis.title.x = element_blank(),
        aspect.ratio = 2)

# With the intensity levels

input_data %>%
  ggplot(aes(x = Integrated_density_total/Area, y = Mean_circ, color = XXX)) +
  geom_density_2d(alpha = 0.5) +
  geom_point(size = 0.5) +
  theme(panel.border = element_rect(fill = NA),
        panel.grid.minor.y = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        axis.title.x = element_blank(),
        aspect.ratio = 2) +
  facet_wrap(~XXX, ncol = 4)
