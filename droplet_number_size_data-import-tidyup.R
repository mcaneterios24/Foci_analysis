
## DATA IMPORT AND TIDY UP

####### 15/07/2020 - Manuel Cañete
# Script for analysing the number and size of the droplets formed by each XXX
# I should consider differences arising from a) Cell area and b) GFP intensity
# ROIs <- defined manually with: define_ROIs_manual.ijm
# Area and intensity <- obtained with macro: measure_ROI_area_intensity.ijm
# Counts <- obtained with macro: count_particles_from_mask_min10.ijm

####### 23/07/2020 - Manuel Cañete
# I have incorporated data of the intensity of the "soluble" fractions
# Intensity <- measure_soluble_intensity.ijm

####### 28/07/2020 - Manuel Cañete
# I have changed the minimum for the 3D Object Counter from 5 to 10 units
# This new version yields more bona fide results

####### 28/07/2020 - Manuel Cañete
# I observed that some cells were possible outliers for their intensity
# outliers <- input_data[input_data$Integrated_density_total/input_data$Area >= 500, 2]
# I checked them manually 
# I have removed some of them from the analysis 

# I have also removed a very intense cell: "200602_XXX_GFP_Rep3_XXX_1_Pos015_S001_0"

####### 29/07/2020 - Manuel Cañete
# I have incorporated data of the shape of the droplets
# This data has been obtained with macro:  measure_sphericity_roundness.ijm

# Dependencies ------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(purrr)
library(stringr)

# Main directory and subdirectories ---------------------------------------

main_dir <- ""
setwd(main_dir)

count_directories <- list.files(path = file.path(main_dir, "Count particles results", "Counts"))
shape_directories <- list.files(path = file.path(main_dir, "Count particles results", "Shape"))
area_int_files <- list.files(path = file.path(main_dir, "ROI area and intensity results", "Droplets"))
soluble_int <- "Soluble_fraction_intensity_results.txt"


# Import counts data ------------------------------------------------------

counts_data <- lapply(count_directories, function(x) {
  path = file.path(main_dir, "Count particles results", "Counts", x)
  files <- list.files(path)
  
  list <- lapply(files, function(f) {
    filename = paste0(path, "/", f)
    read.csv(filename, stringsAsFactors = F)

  })
  
  names(list) <- str_remove(files, "_z=[0-9]*\\.csv")
  return(list)
})


# Import Area and total ROI intensity data --------------------------------

area_int_data <- lapply(area_int_files, function(x) {
  filename = file.path(main_dir, "ROI area and intensity results", "Droplets", x)
  read.delim(filename, header = T) %>%
    mutate(Cell = str_replace(str_remove(Cell, "_z=[0-9]*"), "  ", ""))
}) %>%
  bind_rows()



# Import soluble fraction intensity data ----------------------------------

soluble_int_data <- read.delim(file.path(main_dir, "ROI area and intensity results", "Soluble_fraction", soluble_int), header = T) %>%
  mutate(Cell = str_replace(str_remove(Cell, "_z=[0-9]*"), "  ", ""))


# Import shape data -------------------------------------------------------

shape_data <- lapply(shape_directories, function(x) {
  path = file.path(main_dir, "Count particles results", "Shape", x)
  files <- list.files(path)
  
  list <- lapply(files, function(f) {
    filename = paste0(path, "/", f)
    try(read.csv(filename, stringsAsFactors = F))
    
  })
  
  names(list) <- str_remove(files, "_z=[0-9]*\\.csv")
  return(list)
})

all_shape_data <- lapply(shape_data, function(x){
  lapply(x, function(r) {
    
    if (is.data.frame(r)) {
      result <- list()
      
      ## Choose variables to keep
      result[["Mean_circ"]] <- mean(r[,2])
      
      return(result)
    }
    
  }) %>%
    bind_rows(., .id = "Cell")
}) %>%
  bind_rows()

# Join all data except shape ----------------------------------------------

all_data <- lapply(counts_data, function(x){
  lapply(x, function(r) {
    result <- list()
    
    ## Choose variables to keep
    result[["Counts"]] = nrow(r)
    result[["Mean_volume"]] <- mean(r$Volume..micron.3.) ## Calculate mean also?
    result[["Median_volume"]] <- median(r$Volume..micron.3.)
    
    return(result)
  }) %>%
  bind_rows(., .id = "Cell") #%>%
}) %>%
  bind_rows() %>%
  mutate(Replicate = as.factor(str_extract(Cell, "(?<=GFP_).*(?=_XXX[0-9])"))) %>%
  mutate(XXX = as.factor(str_extract(Cell, "XXX[0-9]"))) %>%
  left_join(., area_int_data, by = "Cell") %>% 
  select(Replicate, everything()) %>%
  left_join(., soluble_int_data, suffix = c("_total", "_soluble"), by = "Cell")


# Join all data and shape data --------------------------------------------

final_data <- all_data %>%
  inner_join(., all_shape_data, by = "Cell")

# Remove outliers ---------------------------------------------------------

curation <- read.csv2(file.path(main_dir, "Analysis", "R scripts", "200728_XXX_droplets_intensity_outliers_comments.csv"), stringsAsFactors = F) %>%
  filter(Remove == "Yes")

all_data_curated <- final_data %>%
  filter(!Cell %in% curation$Cell) %>%
  filter(Cell != "200602_XXX_GFP_Rep3_XXX_1_Pos015_S001_0")


# Save tidy data ----------------------------------------------------------

file_name <- paste0(format(Sys.Date(), "%y%m%d"), "_XXX_droplets_analysis.csv")
file_path <- file.path(main_dir, "Analysis", "R scripts", file_name)
write.csv2(all_data_curated, file_path, row.names = F)
