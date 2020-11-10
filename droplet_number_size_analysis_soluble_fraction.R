
## DATA ANALYSIS - SOLUBLE FRACTION

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


# Dependencies ------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(purrr)
library(ggpubr)


# Set working directory ---------------------------------------------------

working_dir <- ""
setwd(working_dir)

# Import data -------------------------------------------------------------

input_file <- "200728_XXX1-4_droplets_analysis.csv"
input_data <- read.csv2(input_file, stringsAsFactors = F)


# Total intensity comparison ----------------------------------------------
# In general, we have selected more intense cells for XXX234, possibly since there is an important soluble fraction

input_data %>%
  ggplot(aes(x = XXX, y = Integrated_density_total/Area, col = XXX)) +
  geom_boxplot() +
  facet_wrap(~Replicate)


# Ratio soluble vs total --------------------------------------------------

## Observing the images we acquired we noticed that XXX1-GFP cells had less signal
## coming from the soluble fraction. We want to provide quantitative data on this regard.

input_data %>%
  ggplot(aes(x = XXX, y = (Integrated_density_total - Integrated_density_soluble)/Integrated_density_total, fill = XXX)) +
  geom_boxplot() +
  ylab(expression((I[total]~-~I[soluble])/I[total])) +
  theme(panel.border = element_rect(fill = NA),
        panel.grid.minor.y = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        axis.title.x = element_blank(),
        aspect.ratio = 2)

input_data %>%
  ggplot(aes(x = Integrated_density_total/Area, y = (Integrated_density_total - Integrated_density_soluble)/Integrated_density_total, col = XXX)) +
  geom_point() +
  geom_smooth(method = "lm") +
  xlab(expression(I[total]/Area)) +
  ylab(expression((I[total]~-~I[soluble])/I[total])) +
  theme(panel.border = element_rect(fill = NA),
        panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        aspect.ratio = 2) +
  facet_wrap(~XXX, ncol = 4)


# Checking possible outliers ----------------------------------------------

outliers <- input_data[input_data$Integrated_density_total/input_data$Area >= 500, 2]

curation <- read.csv2("200728_XXX1-4_droplets_intensity_outliers_comments.csv", stringsAsFactors = F) %>%
  filter(Remove == "Yes")


# Analysis with curated data ----------------------------------------------

input_data_curated <- input_data %>%
  filter(!Cell %in% curation$Cell)

input_data_curated %>%
  ggplot(aes(x = XXX, y = (Integrated_density_total - Integrated_density_soluble)/Integrated_density_total, fill = XXX)) +
  geom_boxplot() +
  ylab(expression((I[total]~-~I[soluble])/I[total])) +
  theme(panel.border = element_rect(fill = NA),
        panel.grid.minor.y = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        axis.title.x = element_blank(),
        aspect.ratio = 2)

input_data_curated %>%
  ggplot(aes(x = Integrated_density_total/Area, y = (Integrated_density_total - Integrated_density_soluble)/Integrated_density_total, col = XXX)) +
  geom_point() +
  #geom_smooth(method = "lm") +
  xlab(expression(I[total]/Area)) +
  ylab(expression((I[total]~-~I[soluble])/I[total])) +
  theme(panel.border = element_rect(fill = NA),
        panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        aspect.ratio = 2) +
  facet_wrap(~XXX, ncol = 4)

# Statistical analysis - Regression model
# I'm not sure to do a regression, since I don't know which is the fitting (linear, exponential...)
# I will just do an ANOVA (or Kruskal-Wallis) without considering total intensity as an explanatory variable

input_test <- input_data_curated %>%
  mutate(Fraction = (Integrated_density_total - Integrated_density_soluble)/Integrated_density_total) %>%
  mutate(XXX = as.factor(XXX))

compare_means(Fraction ~ XXX,  data = input_test, p.adjust.method = "bonferroni")
my_comparisons <- list(c("XXX1", "XXX2"), c("XXX1", "XXX3"), c("XXX1", "XXX4"), c("XXX2", "XXX3"), c("XXX2", "XXX4"), c("XXX3", "XXX4"))

input_test %>%
  ggviolin(x = "XXX", y = "Fraction", fill = "XXX",  
           palette = "jco", add = "boxplot", add.params = list(fill = "white"), legend = "none") +
          ylab(expression((I[total]~-~I[soluble])/I[total])) +
          theme(panel.border = element_rect(fill = NA),
                panel.grid.minor.y = element_blank(),
                legend.position = "right",
                legend.title = element_blank(),
                axis.title.x = element_blank(),
                aspect.ratio = 2) +
          stat_compare_means(label.x = 1.75, label.y = 0.8) +
          stat_compare_means(comparisons = my_comparisons, label = "p.signif", label.y = c(0.6, 0.65, 0.70, 0.5, 0.55, 0.5))

# Is there a Csat? --------------------------------------------------------
# It looks like there isn't

input_data_curated %>%
  ggplot(aes(x = Mean_intensity_total, y = Mean_intensity_soluble, col = XXX)) +
  geom_point() +
  geom_smooth(method = "lm") +
  xlab(expression(mean~I[total])) +
  ylab(expression(mean~I[soluble])) +
  theme(panel.border = element_rect(fill = NA),
        panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        aspect.ratio = 2) +
  facet_wrap(~XXX, ncol = 4)

