// Code source acknowledgement: Parts of this code are copied from, or based on, code developed by Jan Brocher (https://www.biovoxxel.de/)

// This very simple macro has been written for automatic domain size analysis in images of patterns of self-organizing MinDE proteins. 
// It has been used in Figs. 3 D,E of Gavrilovic et al. Small 2024 (doi.org/10.1002/smll.202309680)


// User-defined parameters:
// Pseudo-flatfield correction
pseudoFlatFieldRadius = 10 // Smoothing radius for large-scale Gaussian. In micrometers!!!

// De-noising
denoisingRadius = 0.8 // Smoothing radius for mean filter for segmentation. In micrometers!!! 

// Thresholding
thresholdMethod = "Shanbhag" // Can choose any of the different threshold method names allowed by ImageJ

// Closing (Dilate-Erode sequence to smooth out edges of segmentation and small pseudo-particles)
closingIterations = 1 // Strength with which to smooth edges in segmentation. Techincally number of iterations in gap closing procedure.
closingOnMinima = false // If false, closing is done on high signal (MinD maxima), if true on low-signal area (MinD minima).
useFillHoles = false //  If true, a fill holes operation is applied to the binarized mask after gap closing, with the same bright/dark annotation as for gap closing.

// Minima particle detection
particleDetectionMinSize = 1 // Minimum size of a minimum to be included in analysis. In square micrometers!!!





///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameter setup
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display redirect=None decimal=3");
setOption("BlackBackground", true);

// Clean up potentially open stuff
if (roiManager("Count") > 0){
	roiManager("Delete"); 
} // If needed, clear ROI manager to avoid pile-up chaos
close("Results");
close("Log");


// Set up where to save stuff
originalImageName = getTitle();
originalDir = getDirectory("image");	//getting base directory from image
originalImageNameNoSuffix = substring(originalImageName,0,lengthOf(originalImageName)-4);
outputDirName = originalDir + originalImageNameNoSuffix + "_analysis" + File.separator;
File.makeDirectory(outputDirName);


// Get pixel size to convert spatial parameters from micrometers to pixels
getPixelSize(nm,sx,sy);


// Pseudo-flat-field correction: Blur out any relevant local structure and divide original image by new one
run("Duplicate...", " ");
rename("01_Flatfield");
run("Gaussian Blur...", "sigma="+ pseudoFlatFieldRadius +" scaled");
imageCalculator("Divide create 32-bit", originalImageName, "01_Flatfield"); 
// Division is run such that new image is created as result, rename
rename("02_Flatfield_corr");


// Denoise: Mean filter and contrast adjustment for normalized signal
run("Duplicate...", " ");
rename("03_Denoised");
//run("Mean...", "radius=" + d2s(round(denoisingRadius / sx));
run("Mean...", "radius=" + round(denoisingRadius / sx));
run("Enhance Contrast...", "saturated=0.01 normalize");


// Thresholding: Convert back to 8-bit space, apply threshold
run("Duplicate...", " ");
rename("04_Mask_min_dark");
setOption("ScaleConversions", true);
run("8-bit");
setAutoThreshold(thresholdMethod + " dark");
setOption("BlackBackground", true);
run("Convert to Mask");


// Gap closing: Dilation/erosion, possibly over multiple iterations, and possibly hole filling
run("Duplicate...", " ");
rename("05_Mask_closed_min_dark");
if (closingOnMinima){
	run("Invert");
}
for (i = 0; i < closingIterations; i++){
	run("Dilate");
}
for (i = 0; i < closingIterations; i++){
	run("Erode");
}
if (useFillHoles){
	run("Fill Holes");
}
if (closingOnMinima){
	run("Invert");
} // Invert again to go back to "bright=bright"


// Get ROIs (minima)
run("Duplicate...", " ");
rename("06_Particle_det_min_bright");
run("Invert");
run("Analyze Particles...", "size=" + particleDetectionMinSize + "-Infinity clear overlay add composite");
run("Select All");


// Distance transform
selectImage("05_Mask_closed_min_dark");
run("Duplicate...", " ");
run("Invert");
rename("07_Dist_map_on_min");
run("Distance Map");


// Get parameters and save results table
numberOfRois = roiManager("count");
for (roi = 0; roi < numberOfRois; roi++) {
	roiManager("Select", roi);
	run("Measure");
}
saveAs("Results", outputDirName + originalImageNameNoSuffix + "_results.csv");


// Save output images
selectImage("01_Flatfield"); 
saveAs("Tiff", outputDirName + "01_" + originalImageNameNoSuffix + "_Flatfield.tif");

selectImage("02_Flatfield_corr"); 
run("16-bit"); // Tif does not support 32-bit
saveAs("Tiff", outputDirName + "02_" + originalImageNameNoSuffix + "_Flatfield_corr.tif");

selectImage("03_Denoised"); 
run("16-bit"); // Tif does not support 32-bit
saveAs("Tiff", outputDirName + "03_" + originalImageNameNoSuffix + "_Denoised.tif");

selectImage("04_Mask_min_dark"); 
saveAs("Tiff", outputDirName + "04_" + originalImageNameNoSuffix + "_Mask_min_dark.tif");

selectImage("05_Mask_closed_min_dark"); 
saveAs("Tiff", outputDirName + "05_" + originalImageNameNoSuffix + "_Mask_closed_min_dark.tif");

selectImage("06_Particle_det_min_bright"); 
saveAs("Tiff", outputDirName + "06_" + originalImageNameNoSuffix + "_Particle_det_min_bright.tif");

selectImage("07_Dist_map_on_min"); 
saveAs("Tiff", outputDirName + "07_" + originalImageNameNoSuffix + "_Dist_map_on_min.tif");


// End - let user chose if to close images or keep for further playing around
waitForUser("Job done, results table saved and images saved. \n Click OK to close all processed images. Click Cancel to keep images.");
selectImage("01_" + originalImageNameNoSuffix + "_Flatfield.tif");
close();
selectImage("02_" + originalImageNameNoSuffix + "_Flatfield_corr.tif");
close();
selectImage("03_" + originalImageNameNoSuffix + "_Denoised.tif");
close();
selectImage("04_" + originalImageNameNoSuffix + "_Mask_min_dark.tif");
close();
selectImage("05_" + originalImageNameNoSuffix + "_Mask_closed_min_dark.tif");
close();
selectImage("06_" + originalImageNameNoSuffix + "_Particle_det_min_bright.tif");
close();
selectImage("07_" + originalImageNameNoSuffix + "_Dist_map_on_min.tif");
close();




