# Foci_analysis
Protocols for the study of cytoplasmic foci in GFP transfected cells


This repository contains all files necessary for the analysis of cytoplasmic foci in GFP transfected cells.

Here's a brief description of the main files:

- define_ROIs_manual.ijm --> Fiji macro to record the manually-defined ROIs of the cells to analyze
- measure_ROI_area_intensity.ijm --> Fiji macro to record the area and mean intensity of the ROIs defined previously
- define_mask.ijm --> Fiji macro to define which mask to use to define the foci within the ROIs defined previously
- count_particles_from_mask.ijm --> Fiji macro to count the particles in each ROI using masks
- measure_sphericity_roundness.ijm --> Fiji macro to measure sphericity and roundness of the foci
- measure_soluble_intensity.ijm --> Fiji macro to measure the intensity in the ROIs excluding the foci
- droplet_number_size_data-import-tidyup.R --> R script to import data
- droplet_number_size_EDA.R --> R script to perform exploratory data analysis on the imported data
- droplet_number_size_analysis_counts.R --> R script to analyze counts data
- droplet_number_size_analysis_shape.R -->  R script to analyze foci morphology
- droplet_number_size_analysis_soluble_fraction.R -->  R script to analyze the soluble fraction intensity
