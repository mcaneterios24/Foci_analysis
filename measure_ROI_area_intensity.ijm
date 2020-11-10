//// Macro to measure cell area and mean intensity using the ROIs defined manually

// Batch mode?
setBatchMode(true);

// Select lif file of interest

path = File.openDialog("Select the lif file"); // choose a .lif file
name = File.getName(path);

// Select ROI directory
roi_dir_name = replace(name, ".lif", "_RoiSet/");
roi_dir = "" + roi_dir_name;
roi_list = getFileList(roi_dir);

// Select results filename

filename = File.openDialog("Choose the results file"); // choose a file in which save your results
f = File.open(filename); // display file open dialog
print(f, "Cell" + "\t" + "Area" + "\t" + "Mean_intensity" + "\t" + "Median_intensity" + "\t" + "Integrated_density"); // columns 


// Open lif file and import ROIs

run("Bio-Formats Macro Extensions");
	
	Ext.setId(path);
	Ext.getCurrentFile(file);
	Ext.getSeriesCount(NbSeries);

for(j = 0; j < NbSeries; j++) {

	print("* Processing series " + j+1 + "...");
	
	run("Bio-Formats", "open=["+path+"] autoscale color_mode=Default crop specify_range view=Hyperstack stack_order=XYCZT series_"+d2s(j+1,0));

	// Filter ROIs to import --> only import those of the current stack

	Imagename = getTitle(); // to get the image name
	roi = replace(Imagename, ".lif - ", "_");
	roi = replace(roi, "/", "_");
	roi = replace(roi, "-", "_");
	
	for (i = 0; i < roi_list.length ; i++) {
		
		if (startsWith(roi_list[i], roi)) { // only import ROIs of the current image

			output_name = replace(roi_list[i], ".roi", "");

			// For each ROI
			
			// Open and select it
			// Duplicate original file
			// Remove pixels outside the ROI
			// Do Z-stack  (SUM slices)
			// Measure intensities and area

			
			roiManager("Open", roi_dir + roi_list[i]); 
			run("Duplicate...", "duplicate channels=1");
			run("Z Project...", "projection=[Sum Slices]");
			roiManager("Select", 0);
			run("Clear Outside", "stack");
			run("Clear Results");
			run("Set Measurements...", "area mean integrated median redirect=None decimal=2");
			run("Measure");

			Mean_intensity = getResult("Mean", 0);
			Median_intensity = getResult("Median", 0);
			Integrated_density = getResult("IntDen", 0);
			Area = getResult("Area", 0);

			print(f, output_name + "\t" + Area + "\t" + Mean_intensity + "\t" + Median_intensity + "\t" + Integrated_density);
			
			roiManager("reset");
			selectWindow(Imagename);
		}
	}

	run("Close All");

	print("    Series " + j+1 + " completed\n");
	
}

print("*** Macro completed successfully");
exit();

