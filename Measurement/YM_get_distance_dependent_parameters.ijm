// This script has been written for analysis of 4-channel microscopy data in which two channels were of interest.
// The data were acquired on tissue sections that showed a significant large-scale, but uninteresting, structure. 
// Channel 1 showed nerve fibers (AF647, bright), channel 2 a certain cell type (Cy3, dimmer).
// The question here was "How does the morphology or brightness of cells change with distance from the nerve fibers?"
// The basic strategy is to segment structures in both channels, and save tables containing
// 1. Brightness statistics derived from a background-subtracted version of the cells
// 2. Distance statistics on how far from the closest nerve fiber the cell is
// These are saved as two .csv sheets that can be joined (and aggregated over many raw images) using the Python script YM_Summarize_data.py


// These are parameters one can change in processing.
// The filter parameters all refer to filter widths.
// A single set of parameters is applied to all images in the chosen folder.


// These parameters relate to the subtraction of background/coarse features.
// The median filters create an image that discards the high-resolution features 
coarseMedianFilterCh1 = 50;  
coarseMedianFilterCh2 = 30;
// Contrast is weaker in channel 2, here and additional Max filter helps close gaps
maximumFilterCh2 = 2;

// The user can perform an additional denoising after background removal. 
// The radius should be very small, 1 or 2 at most.
// The same radius is used for both channels.
// This is not super-important though and can be set to 0 for negligible change
denoiseMedianFilter = 1;

// The algorithm used for auto-thresholding on each of the channels. 
// One can set different ones for the two channels.
// Any of the ImageJ built-ins can be chosen, simply by pasting their name here.
thresholdMethodCh1 = "Shanbhag";
thresholdMethodCh2 = "Minimum";

// Minimum number of pixels for a channel 1 particle to be considered a real cell
minParticleSize = 3;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DO NOT CHANGE BEYOND THIS LINE UNLESS YOU WANT TO CHANGE THE SCRIPT ITSELF
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Parameter setup
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display redirect=None decimal=3");
setOption("BlackBackground", true);


input_folder = getDirectory("Choose a Directory");
file_list = getFileList(input_folder);

for (i = 0; i < file_list.length; i++)
{
	in_path = input_folder + file_list[i];
	if (endsWith(in_path, ".czi")) 
	{

		// Prepare a "clean slate" before processing of each file
		if (roiManager("Count") > 0){
			roiManager("Delete"); 
		} // If needed, clear ROI manager to avoid pile-up chaos
		close("Results");
		close("Log");

		// Open file, skipping BioFormats import wizard pop-up
		s = "open=[" + in_path + "] autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
		run("Bio-Formats Importer", s);
		
		// Set up where to save stuff
		originalImageName = getTitle();
		originalDir = getDirectory("image");	//getting base directory from image
		originalImageNameNoSuffix = substring(originalImageName,0,lengthOf(originalImageName)-4);
		outputDirName = originalDir + originalImageNameNoSuffix + "_analysis" + File.separator;
		File.makeDirectory(outputDirName);

		// Channel splitting - we need channels 1 and 2, channels 3 and 4 are closed immediately
		run("Split Channels");
		close("C3-" + originalImageName);
		close("C4-" + originalImageName);
		
		// Remove low-frequency information (background) from channel 1
		selectImage("C1-" + originalImageName);
		rename("00_c1_raw");
		run("Duplicate...", "title=01_c1_Coarse_Median");
		run("Median...", "radius=" + coarseMedianFilterCh1);
		imageCalculator("Subtract create", "00_c1_raw", "01_c1_Coarse_Median");
		rename("02_c1_High_Freq");
		selectImage("01_c1_Coarse_Median");
	    saveAs("Tiff", outputDirName + "01_c1_Coarse_Median.tif");
		close("01_c1_Coarse_Median.tif");
		
		// For channel 2, we proceed slightly more complex due to overall lower contrast
		selectImage("C2-" + originalImageName);
		rename("00_c2_raw");
		run("Duplicate...", "title=01_c2_Coarse_Median");
		selectImage("01_c2_Coarse_Median");
		run("Median...", "radius=" + coarseMedianFilterCh2);
		selectImage("00_c2_raw");
		run("Duplicate...", "title=01_c2_Maximum");
		selectImage("01_c2_Maximum");
		run("Maximum...", "radius=" + maximumFilterCh2);
		imageCalculator("Subtract create", "01_c2_Maximum", "01_c2_Coarse_Median");
		rename("02_c2_High_Freq");
		selectImage("01_c2_Coarse_Median");
	    saveAs("Tiff", outputDirName + "01_c2_Coarse_Median.tif");
		close("01_c2_Coarse_Median.tif");
		selectImage("01_c2_Maximum");
	    saveAs("Tiff", outputDirName + "01_c2_Maximum.tif");
		close("01_c2_Maximum.tif");
				
		// Denoise the high-frequency images
		selectImage("02_c1_High_Freq");
		run("Duplicate...", "title=03_c1_Denoise");
		selectImage("03_c1_Denoise");
		run("Median...", "radius=" + denoiseMedianFilter);
		selectImage("02_c1_High_Freq");
	    saveAs("Tiff", outputDirName + "02_c1_High_Freq.tif");
		close("02_c1_High_Freq.tif");
		
		selectImage("02_c2_High_Freq");
		run("Duplicate...", "title=03_c2_Denoise");
		selectImage("03_c2_Denoise");
		run("Median...", "radius=" + denoiseMedianFilter);

		
		// Threshold
		selectImage("03_c1_Denoise");
		run("Duplicate...", "title=04_c1_Threshold");
		selectImage("04_c1_Threshold");
		resetMinAndMax;
		run("Enhance Contrast", "saturated=0.35");
		setAutoThreshold(thresholdMethodCh1 + " dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		selectImage("03_c1_Denoise");
	    saveAs("Tiff", outputDirName + "03_c1_Denoise.tif");
		close("03_c1_Denoise.tif");
		
		selectImage("03_c2_Denoise");
		run("Duplicate...", "title=04_c2_Threshold");
		selectImage("04_c2_Threshold");
		resetMinAndMax;
		run("Enhance Contrast", "saturated=0.35");
		setAutoThreshold(thresholdMethodCh2 + " dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		selectImage("03_c2_Denoise");
	    saveAs("Tiff", outputDirName + "03_c2_Denoise.tif");
		close("03_c2_Denoise.tif");
		
		// Distance transform from channel 1 particles (nerve fibers)
		selectImage("04_c1_Threshold");
		run("Duplicate...", "title=05_c1_DistTraFo");
		run("Invert");
		run("Distance Map");
		selectImage("04_c1_Threshold");
	    saveAs("Tiff", outputDirName + "04_c1_Threshold.tif");
		close("04_c1_Threshold.tif");

		// Detect particles in channel 2 (cells)
		selectImage("04_c2_Threshold");
		run("Duplicate...", "title=05_c2_Particle_detection");
		selectImage("05_c2_Particle_detection");
		run("Analyze Particles...", "size=" + minParticleSize + "-Infinity clear overlay add composite");
		numberOfRois = roiManager("count");
		selectImage("04_c2_Threshold");
	    saveAs("Tiff", outputDirName + "04_c2_Threshold.tif");
		close("04_c2_Threshold.tif");
		
		// Get parameters of particles in background-subtracted channel 2 (cells) and save results table
		selectImage("02_c2_High_Freq");
		for (roi = 0; roi < numberOfRois; roi++) {
			roiManager("Select", roi);
			run("Measure");
			}
		roiManager("Deselect");
		saveAs("Results", input_folder + originalImageNameNoSuffix + "_Brightness.csv");
		close("Results"); // Reset results table
		selectImage("02_c2_High_Freq");
		resetMinAndMax;
	    saveAs("Tiff", outputDirName + "02_c2_High_Freq.tif");
		close("02_c2_High_Freq.tif");

		
		// Get parameters of particles in distance transform and save results table
		selectImage("05_c1_DistTraFo");
		for (roi = 0; roi < numberOfRois; roi++) {
			roiManager("Select", roi);
			run("Measure");
			}
		roiManager("Deselect");
		saveAs("Results", originalDir + originalImageNameNoSuffix + "_Distance.csv");
		close("Results"); // Reset results table
		selectImage("05_c1_DistTraFo");
	    saveAs("Tiff", outputDirName + "05_c1_DistTraFo.tif");
		close("05_c1_DistTraFo.tif");

		// Save and close remaining images 
		selectImage("00_c1_raw");
	    saveAs("Tiff", outputDirName + "00_c1_raw.tif");
		close("00_c1_raw.tif");
		selectImage("00_c2_raw");
	    saveAs("Tiff", outputDirName + "00_c2_raw.tif");
		close("00_c2_raw.tif");
		selectImage("05_c2_Particle_detection");
	    saveAs("PNG", outputDirName + "05_c2_Particle_detection.png");
	    close("05_c2_Particle_detection.png");
		
    } // END if (endsWith(in_path, ".czi"))
} // END for (i = 0; i < file_list.length; i++)

showMessage("Job done.");
beep();