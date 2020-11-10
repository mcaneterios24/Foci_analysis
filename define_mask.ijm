// 21/07/20 - Manuel Cañete
//// Macro to define the mask used for counting the particles

output_dir_image = getDirectory("Select directory for storing images");

// Batch mode?
setBatchMode(false);

// Select lif file of interest

path = File.openDialog("Choose a File"); // choose a .lif file
name = File.getName(path);

// Select ROI directory
roi_dir_name = replace(name, ".lif", "_RoiSet/");
roi_dir = "" + roi_dir_name;
roi_list = getFileList(roi_dir);


// Open lif file and import ROIs

run("Bio-Formats Macro Extensions");
	
	Ext.setId(path);
	Ext.getCurrentFile(file);
	Ext.getSeriesCount(NbSeries);

// On every .lif, start at desired series

	Dialog.create("Define start: "); // In case we wanted to start over, but not from 0
	Dialog.addSlider("Start", 1, NbSeries, 1);
	Dialog.show();
	start = Dialog.getNumber();
	Dialog.create("Define end: "); // In case we wanted to end before Nbseries
								   // Random errors pop up, this is why I prefer saving data in groups of 20 images
	Dialog.addSlider("End", 1, NbSeries, 1);
	Dialog.show();
	end = Dialog.getNumber();

for(j = start - 1; j < end; j++) {

	print("* Processing series " + j+1 + "...");
	
	run("Bio-Formats", "open=["+path+"] autoscale color_mode=Default crop specify_range view=Hyperstack stack_order=XYCZT series_"+d2s(j+1,0));

	// Filter ROIs to import --> only import those of the current stack

	Imagename = getTitle(); // to get the image name
	roi = replace(Imagename, ".lif - ", "_");
	roi = replace(roi, "/", "_");
	roi = replace(roi, "-", "_");
	
	for (i = 0; i < roi_list.length ; i++) {
		
		if (startsWith(roi_list[i], roi)) { // only import ROIs of the current image

			// For each ROI

			// Get z-stack of interest (from ROI file name)
			z = substring(roi_list[i], indexOf(roi_list[i], "=")+1, indexOf(roi_list[i], ".roi")); // Value of the stack used as reference for thresholding
			
			output_name = replace(roi_list[i], ".roi", ""); // output csv file

			// Open and select it
			// Duplicate original file
			// Remove pixels outside the ROI
			// Substract background
			// Use reference z-stack for thresholding using Renyi Entropy
			
			roiManager("Open", roi_dir + roi_list[i]); 
			run("Duplicate...", "duplicate channels=1");
			roiManager("Select", 0);
			run("Clear Outside", "stack");
			run("Subtract Background...", "rolling=50 stack");
			run("Duplicate...", "duplicate range=" + z + "-" + z + " use");
			rename("dummy");
			setAutoThreshold("RenyiEntropy dark");
			getThreshold(lower, upper);

			// Close z-stack
			
			selectWindow("dummy");
			close();

			// Apply threshold and mask to the whole stack
			
			selectWindow(Imagename + "-1");
			setThreshold(lower, upper);
			setOption("BlackBackground", false);
			run("Convert to Mask", "method=RenyiEntropy background=Dark");
			run("Watershed", "stack"); // Watershed is applied to better segment particles

			// Ask user whether threshold is OK --> sometimes it doesn't work very well

			waitForUser("Check the autothreshold values");
			
			Dialog.create("Are you OK with the threshold? "); // In case we wanted to start over, but not from 0
			choices = newArray("Yes", "No", "Skip"); 
			Dialog.addChoice("OK?", choices, "Yes");
			Dialog.show();
			
			ok_threshold = Dialog.getChoice();

			if (ok_threshold == "No") { // If not OK, re-define it manually
				selectWindow(Imagename + "-1");
				close();
				selectWindow(Imagename);
				run("Duplicate...", "duplicate channels=1");
				roiManager("Select", 0);
				run("Clear Outside", "stack");
				run("Subtract Background...", "rolling=50 stack");
				run("Threshold...");
				waitForUser("Define new threshold values\nUse Renyi-Entropy"); // Make sure to re-select Renyi-Entropy
				getThreshold(lower, upper);
				setThreshold(lower, upper);
				setOption("BlackBackground", false);
				run("Convert to Mask", "method=RenyiEntropy background=Dark");
				run("Watershed", "stack");
				
			}

			if (ok_threshold != "Skip") { // Skip images if pattern is difuse, weird, too much aggregated...

			selectWindow(Imagename + "-1");
			saveAs("Tiff", output_dir_image + output_name + ".tiff");
			
			}
			
			roiManager("reset");
			selectWindow(Imagename);
			
		}
	}

	run("Close All");

	print("    Series " + j+1 + " completed\n");
	
}

print("*** Macro completed successfully");
exit();

