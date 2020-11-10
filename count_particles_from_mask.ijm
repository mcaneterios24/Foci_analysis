// 21/07/20
//// Macro to count particles using the ROIs and masks defined previously

// This version has been deprecated, min set at 10

dir_input_files = getDirectory("Choose folder with masks");
list = getFileList(dir_input_files);

dir_count = getDirectory("Select directory for storing count results");

// Select ROI directory
dir_ROI = getDirectory("Define directory with ROIs");
roi_list = getFileList(dir_ROI);

run("Bio-Formats Macro Extensions");
setBatchMode(true);
roiManager("reset");

	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], ".tiff")) {
			
			// Define and open working file
			path = dir_input_files + list[i];
			open(path);

			Imagename = getTitle(); // to get the image name
			roi = replace(Imagename, ".tiff", "");
	
			for (j = 0; j < roi_list.length ; j++) {
		
				if (startsWith(roi_list[j], roi)) { // only import ROIs of the current image

				// For each ROI
				
				output_name = replace(roi_list[j], ".roi", ""); // output csv file

				roiManager("Open", dir_ROI + roi_list[j]);
				roiManager("Select", 0);

				// Apply 3D Object Counter, using a minimum of particle --> 5 units
			
				run("3D Objects Counter", "threshold=128 slice=15 min.=5 max.=19922944 statistics");

				// Store results 
				saveAs("Results", dir_count + output_name + ".csv");
				
				// Clear the working space
				roiManager("reset");
				run("Clear Results");
				run("Close All");

				}
			}
		}
	}

showMessage("Macro completed successfully")