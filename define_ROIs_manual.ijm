//// Macro to define manually the ROIs and to save them for downstream analyses
// This macro also defines the Z-stack (plane) that will be used for thresholding.
// As a recommendation, select the Z-stack with higher intensity values for each ROI

output_dir = getDirectory("Select the output directory");


// Batch mode?
setBatchMode(false);

// Select file of interest

path = File.openDialog("Choose a File"); // choose a .lif file

if (endsWith(path, ".lif")) { // Check a .lif file is being used
	print("Correct input file format\n");
	print("Started processing...\n");
	
} else { // If not, abort macro
	exit("Wrong input file format");
}

// Use file name for naming the output file

split_name = split(path, "/");
chunk_name = split_name[lengthOf(split_name)-1];
filename = replace(chunk_name, ".lif", "");

// Open lif file and check whether all images have 3 channels

run("Bio-Formats Macro Extensions");
	name = File.getName(path);
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
	getDimensions(width, height, channels, slices, frames); // to get the number of channels
	Imagename = getTitle(); // to get the image name
	roi = replace(Imagename, ".lif - ", "_");
	roi = replace(roi, "/", "_");
	roi = replace(roi, "-", "_");
	
	if (channels != 3) {
		exit("    Image does not have 3 channels");
		}  else {
			print("    Number of channels OK...");
		}

	print("    Draw ROIs manually...");

	// Now draw the ROIs manually and rename them with the file's name

	run("ROI Manager...");
	run("Duplicate...", "duplicate");
	selectWindow(Imagename + "-1");
	run("Make Composite");
	run("Z Project...", "projection=[Max Intensity]");
	

	waitForUser("Drawing ROIS manually");

	print("    Renaming recently added ROIs...");
	
	nROIs = roiManager("count");
	
	for (i = 0; i < nROIs; i++) {

		roiManager("select", i);
		selectWindow(Imagename + "-1");
		waitForUser("Check the desired Z stacks");
		
		Dialog.create("Define reference Z stack for thresholding "); // In case we wanted to start over, but not from 0
		Dialog.addSlider("Start", 1, nSlices, 1);
		Dialog.show();
		z = Dialog.getNumber();

		roiname = roi + "_" + i + "_z=" + z;
		roiManager("rename", roiname);
		roiManager("Save", output_dir + roiname + ".roi");

		}

	roiManager("reset");
	selectWindow(Imagename);
	close();
	selectWindow(Imagename + "-1");
	close();
	selectWindow("MAX_" + Imagename + "-1");
	close();

	print("    Image correctly processed\n");
	
	}


print("Macro finished successfully");
exit();


