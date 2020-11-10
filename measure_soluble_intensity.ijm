/// 23/07/20 - Manuel Cañete
///// Macro for calculating the intensity in the negative of the mask --> soluble fraction

// Stablish the working directory
working_dir = "";

// Select input files
input_dir = "";
input_list = getFileList(input_dir);

// Select masks
mask_dir = working_dir + "Count particles results/Masks/";
mask_list = getFileList(mask_dir);

// Select ROIs
roi_dir = working_dir + "Manual ROIs/";
roi_list = getFileList(roi_dir);

// Select results filename

filename = File.openDialog("Choose the results file"); // choose a file in which save your results
f = File.open(filename); // display file open dialog
print(f, "Cell" + "\t" + "Mean_intensity" + "\t" + "Median_intensity" + "\t" + "Integrated_density"); // columns 

// batchmode
setBatchMode(true);

// Operate on each lif file:

for (i = 0; i < input_list.length; i++) { 

    input_path = input_dir + input_list[i]; // path to read each lif file
	mask_path = mask_dir + mask_list[i];
	roi_path = roi_dir + roi_list[i];

	print("Processing lif file: " + input_list[i]);
	print("    Using mask directory: " + mask_list[i]);
	print("    Using roi directory: " + roi_list[i] + "\n");

	// List of masks and rois
	masks = getFileList(mask_path);
	rois = getFileList(roi_path);

	run("Bio-Formats Macro Extensions");
	
		Ext.setId(input_path);
		Ext.getCurrentFile(file);
		Ext.getSeriesCount(NbSeries);

	// Operate on each series of the lif file

	for (j = 0; j < NbSeries; j++) {

		print("    * Processing series " + j+1 + "...");

		// Open image and duplicate the GFP channel
	
		run("Bio-Formats", "open=["+input_path+"] autoscale color_mode=Default crop specify_range view=Hyperstack stack_order=XYCZT series_"+d2s(j+1,0));

			Imagename = getTitle();
		
		run("Duplicate...", "duplicate channels=1");

		roi = replace(Imagename, ".lif - ", "_");
		roi = replace(roi, "/", "_");
		roi = replace(roi, "-", "_");


		// Operate on each ROI, and select the corresponding of each series

		for (h = 0; h < rois.length ; h++) {


			if (startsWith(rois[h], roi)) {

				// Prepare image for calculation
				// Clear outside

				roiManager("Open", roi_path + rois[h]); 
				roiManager("Select", 0);
				run("Clear Outside", "stack");
				rename("Original");

				// Only if there is mask, procede

				mask_name = replace(rois[h], ".roi", ".tiff");

				if (File.exists(mask_path + mask_name)) {

					// Now open the mask file
				
				open(mask_path + mask_name);
				rename("Mask");

				// Substract the images
				imageCalculator("Subtract stack", "Original", "Mask");
				run("Z Project...", "projection=[Sum Slices]");
				rename("Substraction");

				// Calculate now intensity data
				selectWindow("Substraction");
				roiManager("Select", 0);
				run("Clear Results");
				run("Set Measurements...", "area mean integrated median redirect=None decimal=2");
				run("Measure");

				// Save Measurements
				Mean_intensity = getResult("Mean", 0);
				Median_intensity = getResult("Median", 0);
				Integrated_density = getResult("IntDen", 0);

				output_name = replace(rois[h], ".roi", "");

				print(f, output_name + "\t" + Mean_intensity + "\t" + Median_intensity + "\t" + Integrated_density);
					
				}

				// Reset ROI Manager
				roiManager("reset");
				selectWindow(Imagename);
				close("\\Others");
				run("Duplicate...", "duplicate channels=1"); 
				
			}
			
		}

		run("Close All");

		print("    Series " + j+1 + " completed\n");

	}

}

showMessage("Macro completed successfully");