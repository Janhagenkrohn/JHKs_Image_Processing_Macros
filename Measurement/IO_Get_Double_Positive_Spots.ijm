

// These parameters relate to the subtraction of background/coarse features.
medianFilterCh1 = 3;  
rollingBallCh1 = 10;
medianFilterCh2 = 3;  
rollingBallCh2 = 10;
medianFilterCh3 = 5;

// The algorithm used for auto-thresholding. 
// One can set different ones for each of the channels.
// Any of the ImageJ built-ins can be chosen, simply by pasting their name here.
thresholdMethodCh1 = "Shanbhag";
thresholdMethodCh2 = "Intermodes";
thresholdMethodCh3 = "Otsu";

// To strongly smooth out nuclei segmentation, 
// we perform a number of erode and dilate operations. 
// This is the number of iterations.
n_ED = 20;

// Minimum number of pixels for a particle to be considered a real cell
minParticleSize = 10;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DO NOT CHANGE BEYOND THIS LINE UNLESS YOU WANT TO CHANGE THE SCRIPT ITSELF
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Parameter setup
run("Close All");
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
		originalImageNameNoSuffix = substring(file_list[i],0,lengthOf(file_list[i])-4);
		outputDirName = input_folder + originalImageNameNoSuffix + "_analysis" + File.separator;
		File.makeDirectory(outputDirName);
		
		// Channel splitting - we need channels 1 and 2, channels 3 and 4 are closed immediately
		run("Split Channels");
		
		// Remove low-frequency information (background) from channel 1
		selectImage("C1-" + originalImageName);
		rename("00_c1_raw");
		run("Duplicate...", "title=01_c1_Median");
		selectImage("01_c1_Median");
		run("Median...", "radius=" + medianFilterCh1);
		run("Duplicate...", "title=02_c1_Background");
		selectImage("02_c1_Background");
		run("Subtract Background...", "rolling=" + rollingBallCh1 + " create sliding");
		imageCalculator("Subtract create 32-bit", "01_c1_Median","02_c1_Background");
		rename("03_c1_median_background_removed");
		imageCalculator("Subtract create 32-bit", "00_c1_raw","02_c1_Background");
		rename("04_c1_background_removed");
		
		// Save and close images no longer required
		selectImage("00_c1_raw");
	    saveAs("Tiff", outputDirName + "00_c1_raw.tif");
		close("00_c1_raw.tif");
		selectImage("01_c1_Median");
	    saveAs("Tiff", outputDirName + "01_c1_Median.tif");
		close("01_c1_Median.tif");
		selectImage("02_c1_Background");
	    saveAs("Tiff", outputDirName + "02_c1_Background.tif");
		close("02_c1_Background.tif");
		
		// Remove low-frequency information (background) from channel 2
		selectImage("C2-" + originalImageName);
		rename("00_c2_raw");
		run("Duplicate...", "title=01_c2_Median");
		selectImage("01_c2_Median");
		run("Median...", "radius=" + medianFilterCh2);
		run("Duplicate...", "title=02_c2_Background");
		selectImage("02_c2_Background");
		run("Subtract Background...", "rolling=" + rollingBallCh2 + " create sliding");
		imageCalculator("Subtract create 32-bit", "01_c2_Median","02_c2_Background");
		rename("03_c2_median_background_removed");
		imageCalculator("Subtract create 32-bit", "00_c2_raw","02_c2_Background");
		rename("04_c2_background_removed");
		
		// Save and close images no longer required
		selectImage("00_c2_raw");
	    saveAs("Tiff", outputDirName + "00_c2_raw.tif");
		close("00_c2_raw.tif");
		selectImage("01_c2_Median");
	    saveAs("Tiff", outputDirName + "01_c2_Median.tif");
		close("01_c2_Median.tif");
		selectImage("02_c2_Background");
	    saveAs("Tiff", outputDirName + "02_c2_Background.tif");
		close("02_c2_Background.tif");
		
		// Threshold channel 1
		selectImage("03_c1_median_background_removed");
		run("Duplicate...", "title=05_c1_Threshold");
		selectImage("05_c1_Threshold");
		resetMinAndMax;
		run("Enhance Contrast", "saturated=0.35");
		setAutoThreshold(thresholdMethodCh1 + " dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		
		// Save and close images no longer required
		selectImage("03_c1_median_background_removed");
	    saveAs("Tiff", outputDirName + "03_c1_median_background_removed.tif");
		close("03_c1_median_background_removed.tif");
		
		// Threshold channel 2
		selectImage("03_c2_median_background_removed");
		run("Duplicate...", "title=05_c2_Threshold");
		selectImage("05_c2_Threshold");
		resetMinAndMax;
		run("Enhance Contrast", "saturated=0.35");
		setAutoThreshold(thresholdMethodCh2 + " dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		
		// Save and close images no longer required
		selectImage("03_c2_median_background_removed");
	    saveAs("Tiff", outputDirName + "03_c2_median_background_removed.tif");
		close("03_c2_median_background_removed.tif");
		
		// Merge channel-wise masks into a global one, and perform some binary operations to get better particle masks
		imageCalculator("OR create", "05_c1_Threshold","05_c2_Threshold");
		rename("06_c1c2_particle_mask");
		run("Dilate");
		run("Erode");
		run("Erode");
		run("Dilate");
		run("Watershed");

		// Save and close images no longer required
		selectImage("05_c1_Threshold");
	    saveAs("Tiff", outputDirName + "05_c1_Threshold.tif");
		close("05_c1_Threshold.tif");
		selectImage("05_c2_Threshold");
	    saveAs("Tiff", outputDirName + "05_c2_Threshold.tif");
		close("05_c2_Threshold.tif");
		
		
		
		// Get ROIs from particle mask
		selectImage("06_c1c2_particle_mask");
		run("Duplicate...", "title=07_c1c2_Particle_detection");
		selectImage("07_c1c2_Particle_detection");
		run("Analyze Particles...", "size=" + minParticleSize + "-Infinity pixel clear overlay add composite");
		numberOfRois = roiManager("count");
		
		// Save and close images no longer required
		selectImage("06_c1c2_particle_mask");
	    saveAs("Tiff", outputDirName + "06_c1c2_particle_mask.tif");
		close("06_c1c2_particle_mask.tif");
		selectImage("07_c1c2_Particle_detection");
	    saveAs("PNG ", outputDirName + "07_c1c2_Particle_detection.png"); // This one as PNG to include the labels
		close("07_c1c2_Particle_detection.png");
				
				
		// Get parameters of particles in background-subtracted channel 1 and save results table
		selectImage("04_c1_background_removed");
		table_row = 0;
		for (roi = 0; roi < numberOfRois; roi++) {
			// Measure particle
			roiManager("Select", roi);
			run("Measure");
			Table.set("Particle_No", table_row, roi);
			Table.set("Channel", table_row, 1);
			Table.set("Measurement_mode", table_row, "Particle");
			table_row = table_row + 1;
			
			// Measure particle and some surroundings
			RoiManager.scale(2, 2, true);
			roiManager("Select", roi);
			run("Measure");
			Table.set("Particle_No", table_row, roi);
			Table.set("Channel", table_row, 1);
			Table.set("Measurement_mode", table_row, "Inflated");
			RoiManager.scale(0.5, 0.5, true);
			table_row = table_row + 1;
			}
		roiManager("Deselect");

		// Save and close images no longer required
		selectImage("04_c1_background_removed");
	    saveAs("Tiff", outputDirName + "04_c1_background_removed.tif");
		close("04_c1_background_removed.tif");
		
		// Get parameters of particles in background-subtracted channel 2 and save results table
		selectImage("04_c2_background_removed");
		for (roi = 0; roi < numberOfRois; roi++) {
			// Measure particle
			roiManager("Select", roi);
			run("Measure");
			Table.set("Particle_No", table_row, roi);
			Table.set("Channel", table_row, 2);
			Table.set("Measurement_mode", table_row, "Particle");
			table_row = table_row + 1;
			
			// Measure particle and some surroundings
			RoiManager.scale(2, 2, true);
			roiManager("Select", roi);
			run("Measure");
			Table.set("Particle_No", table_row, roi);
			Table.set("Channel", table_row, 2);
			Table.set("Measurement_mode", table_row, "Inflated");
			RoiManager.scale(0.5, 0.5, true);
			table_row = table_row + 1;
			}
		roiManager("Deselect");
		saveAs("Results", input_folder + originalImageNameNoSuffix + "_Spot_Stats.csv");
		close("Results"); // Reset results table

		// Save and close images no longer required
		selectImage("04_c2_background_removed");
	    saveAs("Tiff", outputDirName + "04_c2_background_removed.tif");
		close("04_c2_background_removed.tif");
				
		////////// Process channel 3 (nuclei) ////////// 
		
		// Filtering
		selectImage("C3-" + originalImageName);
		rename("00_c3_raw");
		selectImage("00_c3_raw");
		run("Duplicate...", "title=08_c3_Median");
		selectImage("08_c3_Median");
		run("Median...", "radius=" + medianFilterCh3);
		
		// Thresholding
		selectImage("08_c3_Median");
		run("Duplicate...", "title=09_c3_Threshold");
		selectImage("09_c3_Threshold");
		resetMinAndMax;
		run("Enhance Contrast", "saturated=0.35");
		setAutoThreshold(thresholdMethodCh3 + " dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask");
	
		// Save and close images no longer required
		selectImage("08_c3_Median");
		saveAs("Tiff", outputDirName + "08_c3_Median.tif");
		close("08_c3_Median.tif");
						
		// Binary operations to avoid over- or undercounting
		selectImage("09_c3_Threshold");
		run("Duplicate...",  "title=10_c3_particle_mask");
		selectImage("10_c3_particle_mask");
		for (i_ED = 0; i_ED < n_ED; i_ED++) {
			run("Erode");
			}
		for (i_ED = 0; i_ED < 2 * n_ED; i_ED++) {
			run("Dilate");
			}
		for (i_ED = 0; i_ED < n_ED; i_ED++) {
			run("Erode");
			}
		run("Fill Holes");
		run("Watershed");
		
		// Save and close images no longer required
		selectImage("09_c3_Threshold");
	    saveAs("Tiff", outputDirName + "09_c3_Threshold.tif");
		close("09_c3_Threshold.tif");
				
		// Detect particles
		if (roiManager("Count") > 0){
			roiManager("Delete"); 
		} // If needed, clear ROI manager to avoid pile-up chaos
		close("Results");
		selectImage("10_c3_particle_mask");
		run("Duplicate...", "title=11_c3_Particle_detection");
		selectImage("11_c3_Particle_detection");
		run("Analyze Particles...", "size=" + minParticleSize + "-Infinity pixel clear overlay add composite");
		numberOfRois = roiManager("count");
		
		// Save and close images no longer required
		selectImage("10_c3_particle_mask");
	    saveAs("Tiff", outputDirName + "10_c3_particle_mask.tif");
		close("10_c3_particle_mask.tif");
		selectImage("11_c3_Particle_detection");
	    saveAs("PNG", outputDirName + "11_c3_Particle_detection.png");
		close("11_c3_Particle_detection.png");
		
		selectImage("00_c3_raw");
		table_row = 0;
		for (roi = 0; roi < numberOfRois; roi++) {
			// Measure particle
			roiManager("Select", roi);
			run("Measure");
			Table.set("Nucleus_No", table_row, roi);
			Table.set("Channel", table_row, 3);
			Table.set("Measurement_mode", table_row, "Nucleus");
			table_row = table_row + 1;
			}
		roiManager("Deselect");
		saveAs("Results", input_folder + originalImageNameNoSuffix + "_Nucleus_Stats.csv");
		close("Results"); // Reset results table

		// Save and close images no longer required
		selectImage("00_c3_raw");
		roiManager("Deselect");
	    saveAs("Tiff", outputDirName + "00_c3_raw.tif");
		close("00_c3_raw.tif");	
		
	} // END if (endsWith(in_path, ".czi")) 
} //END for (i = 0; i < file_list.length; i++)

showMessage("Job done.");
beep();