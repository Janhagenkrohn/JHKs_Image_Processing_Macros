// Script for batch mode conversion of a whole directory of  .czi
// to color images for presentation, publication, etc.

// Software setup
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display redirect=None decimal=3");
setOption("BlackBackground", true);

// Clean up potentially open stuff
if (roiManager("Count") > 0){
	roiManager("Delete"); 
} // If needed, clear ROI manager to avoid pile-up chaos
close("Results");
close("Log");


function save_to_png_single(image_id, 
							 min_contrast,
							 max_contrast,
							 nx,
							 ny,
							 rescale,
							 tf_add_scale_bar,
							 scale_bar_color,
							 sb_length,
							 lut_choice,
							 input_folder, 
							 save_name) { 
	
	
	// Make sure the correct image is selected
	selectImage(image_id);

	// Duplicate for processing
	run("Duplicate...", " ");
	image_id_1_d = getTitle();
	
	// Adjust contrast
	setMinAndMax(min_contrast, max_contrast);
	run("Apply LUT");

	// Upscale if needed, immediately deleting the original
	if (rescale > 1)
	{
		run("Scale...", "x=" + rescale + " y=" + rescale + " width=" + nx * rescale + " height=" + ny * rescale + " interpolation=None create");
		image_id_1_d_new = getTitle();
		close(image_id_1_d);
		image_id_1_d = image_id_1_d_new;
		selectImage(image_id_1_d);
	} // END if (rescale > 1)
			
	// Apply LUT
	run(lut_choice);
	
	// Add scalebar
	if (tf_add_scale_bar)
	{
		run("Scale Bar...", "width=" + sb_length + " height=5 thickness=" + round(ny / 50) +" color="+ scale_bar_color+" font=" + round(ny / 20) +" bold overlay");
	}
	
	// Write
    saveAs("PNG", input_folder + save_name + ".png");
	
	// Close duplicated channel image
	close();
}

function save_to_png_dual(image_id_1, 
						   image_id_2, 
						   min_contrast_1,
						   min_contrast_2,
						   max_contrast_1,
						   max_contrast_2,
						   nx,
						   ny,
						   rescale,
						   tf_add_scale_bar,
						   scale_bar_color,
						   sb_length,
						   lut_choice_1,						   
						   lut_choice_2,
						   input_folder, 
						   save_name) { 

	// Adjust contrast, apply LUT, and rescale as needed
	selectImage(image_id_1);
	run("Duplicate...", " ");
	rename("image1_d");
	image_id_1_d = getTitle();
	setMinAndMax(min_contrast_1, max_contrast_1);
	run("Apply LUT");
	if (rescale > 1)
	{
		run("Scale...", "x=" + rescale + " y=" + rescale + " width=" + nx * rescale + " height=" + ny * rescale + " interpolation=None create");
		rename("image1_d_new");
		image_id_1_d_new = getTitle();
		close(image_id_1_d);
		image_id_1_d = image_id_1_d_new;
		selectImage(image_id_1_d);
	} // END if (rescale > 1)
	run(lut_choice_1);
	
	selectImage(image_id_2);
	run("Duplicate...", " ");	
	rename("image2_d");
	image_id_2_d = getTitle();
	setMinAndMax(min_contrast_2, max_contrast_2);
	run("Apply LUT");
	if (rescale > 1)
	{
		run("Scale...", "x=" + rescale + " y=" + rescale + " width=" + nx * rescale + " height=" + ny * rescale + " interpolation=None create");
		rename("image2_d_new");
		image_id_2_d_new = getTitle();
		close(image_id_2_d);
		image_id_2_d = image_id_2_d_new;
		selectImage(image_id_2_d);
	} // END if (rescale > 1)
	run(lut_choice_2);
			
	
	// Create overlay - this also implicitly closes the single-channel image working copies
	run("Merge Channels...", "c1=" + image_id_1_d + " c2=" + image_id_2_d + " create");
		
		
	// Add scalebar
	if (tf_add_scale_bar)
	{
		run("Scale Bar...", "width=" + sb_length + " height=5 thickness=" + round(ny / 50) + " color="+ scale_bar_color + " font=" + round(ny / 20) +" bold overlay");
	}
	
	// Write
    saveAs("PNG", input_folder + save_name + ".png");
	
	// Close overlay image image
	close();		
}


function save_to_png_triple(image_id_1, 
			 			     image_id_2, 
			 		         image_id_3, 
					   	     min_contrast_1,
					   		 min_contrast_2,
					   		 min_contrast_3,
					   	     max_contrast_1,
					  	     max_contrast_2,
					  		 max_contrast_3,
					  		 nx,
					  		 ny,
					  		 rescale,
					  		 tf_add_scale_bar,
					  		 scale_bar_color,
					  		 sb_length,
					  		 lut_choice_1,						   
					  		 lut_choice_2,
					  		 lut_choice_3,						   
					  		 input_folder, 
					  		 save_name) { 
	
	// Adjust contrast, apply LUT, and rescale as needed
	selectImage(image_id_1);
	run("Duplicate...", " ");	
	rename("image1_d");
	image_id_1_d = getTitle();
	setMinAndMax(min_contrast_1, max_contrast_1);
	run("Apply LUT");
	if (rescale > 1)
	{
		
		run("Scale...", "x=" + rescale + " y=" + rescale + " width=" + nx * rescale + " height=" + ny * rescale + " interpolation=None create");
		rename("image1_d_new");
		image_id_1_d_new = getTitle();
		close(image_id_1_d);
		image_id_1_d = image_id_1_d_new;
		selectImage(image_id_1_d);
	} // END if (rescale > 1)
	run(lut_choice_1);
	
	selectImage(image_id_2);
	run("Duplicate...", " ");
	rename("image2_d");
	image_id_2_d = getTitle();
	setMinAndMax(min_contrast_2, max_contrast_2);
	run("Apply LUT");
	if (rescale > 1)
	{
		run("Scale...", "x=" + rescale + " y=" + rescale + " width=" + nx * rescale + " height=" + ny * rescale + " interpolation=None create");
		rename("image2_d_new");
		image_id_2_d_new = getTitle();
		close(image_id_2_d);
		image_id_2_d = image_id_2_d_new;
		selectImage(image_id_2_d);
	} // END if (rescale > 1)
	run(lut_choice_2);
	
	selectImage(image_id_3);
	run("Duplicate...", " ");
	rename("image3_d");
	image_id_3_d = getTitle();
	setMinAndMax(min_contrast_3, max_contrast_3);
	run("Apply LUT");
	if (rescale > 1)
	{
		run("Scale...", "x=" + rescale + " y=" + rescale + " width=" + nx * rescale + " height=" + ny * rescale + " interpolation=None create");
		rename("image3_d_new");
		image_id_3_d_new = getTitle();
		close(image_id_3_d);
		image_id_3_d = image_id_3_d_new;
		selectImage(image_id_1_d);
	} // END if (rescale > 1)
	run(lut_choice_3);
			
	// Create overlay - this also implicitly closes the single-channel image working copies
	run("Merge Channels...", "c1=" + image_id_1_d + " c2=" + image_id_2_d + " c3=" + image_id_3_d + " create");
		
		
	// Add scalebar
	if (tf_add_scale_bar)
	{
		run("Scale Bar...", "width=" + sb_length + " height=5 thickness=" + round(ny / 50) + " color="+ scale_bar_color + " font=" + round(ny / 20) +" bold overlay");
	}
	
	// Write
    saveAs("PNG", input_folder + save_name + ".png");
	
	// Close overlay image image
	close();	
}






// Get input data folder
input_folder = getDirectory("Choose a Directory");
file_list = getFileList(input_folder);


// Definitions
scaleBarSizeOptions = newArray(1, 2, 3, 5, 10, 20, 25, 30, 50, 100, 200, 250, 300, 500, 1000, 200, 2500, 3000, 5000);
settings_done = false;

// Dialog for overall settings of how we want to look at the data
Dialog.create("Choose resolution level to export");
Dialog.addMessage("Low number means high resolution. \n3-4 should make sense for AxioScan data.");
Dialog.addChoice("Resolution level:", newArray(1, 2, 3, 4, 5, 6), 4);
Dialog.addMessage("Fluorescence/multi-channel or RBG brightfield?");
Dialog.addChoice("Imaging mode:", newArray("Fluorescence/multi-channel", "RBG brightfield"), "Fluorescence/multi-channel");
Dialog.show();
resolutionLevel = Dialog.getChoice();
imagingMode = Dialog.getChoice();

// We need to adjust the pixel size to the loaded resolution level, ImageJ default behavior is buggy here 
resolution_scaling_factor = pow(2, resolutionLevel-1);

if (imagingMode ==  "Fluorescence/multi-channel")
{
	scale_bar_color = "White";
} else if (imagingMode ==  "RBG brightfield")
{
	scale_bar_color = "Black";
}

if (imagingMode ==  "Fluorescence/multi-channel")
{
	for (i = 0; i < file_list.length; i++)
	{
		in_path = input_folder + file_list[i];
		if (endsWith(in_path, ".czi")) 
		{
			// Shortened file name to be used in export
			//fileNameCopy = file_list[i];
			file_name_strip = split(file_list[i], ".");
			
			run("Bio-Formats Macro Extensions");
			Ext.setId(in_path);
			//Ext.getCurrentFile(file_list[i]);
			Ext.getSeriesCount(seriesCount);
			
			for (resolutionLevelIndex = resolutionLevel; resolutionLevelIndex < seriesCount - 2; resolutionLevelIndex += 6)
			{
				if (resolutionLevelIndex < 10) {rLIAppend = "0";} else {rLIAppend = "";};
				
				// Open file, skipping BioFormats import wizard pop-up
				s = "open=[" + in_path + "] series_"+resolutionLevelIndex +" autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
				run("Bio-Formats Importer", s);
				
				// Get image dimensions
				// If the raw data contains more axes than xyc, there can be confusion
				// at this step depending on the ZEN version that wrote the file.  
				// If you encounter problems that may relate to axes being assigned wrong, 
				// the getDimensions() statement is the first thing to look at.
				getDimensions(nx, ny, nchannels, nz, nframes);
				getPixelSize(nm,sx,sy);
				run("Properties...", "channels=" + nchannels + " slices=" + nz + " frames=" + nframes + " pixel_width=" + sx * resolution_scaling_factor + " pixel_height=" + sy * resolution_scaling_factor + " voxel_depth=1.0000000");
				getPixelSize(nm,sx,sy);
				
				// After loading the first valid image, we adjust the settings for export (of all images)
				if (settings_done == false)
				{
					// When we reach this point for first image, let user specify target contrast for each channel 
					// Get parameters
					Dialog.create("Set export parameters");
		
					// Choices of what overlays to export
					Dialog.addCheckbox("Export Single-Color Image(s)", true);
					if (nchannels > 1)	{Dialog.addCheckbox("Export Two-color Overlay(s)?", true);}
					if (nchannels > 2)	{Dialog.addCheckbox("Export Three-Color Overlay(s)", true);}
		
					// Channel-wise settings
					for (i_ch=1; i_ch <= nchannels; i_ch++) 
					{
						// Contrast
						Dialog.addNumber("Contrast min Channel " + i_ch, 0);
						Dialog.addNumber("Contrast max Channel " + i_ch, 65535);
						
						// Determine default suggestion for display lookup table
						if (nchannels == 2) 
						{
							if (i_ch == 1) {default_lut = "Green";} else {default_lut = "Magenta";}
						}
						else if (nchannels == 3)
						{
							if (i_ch == 1) {default_lut = "Yellow";} else if (i_ch == 2) {default_lut = "Magenta";} else {default_lut = "Cyan";}
						}
						else // nchannels == 1 or nchannels >3
						{
							default_lut = "Grays";
						} // END if (nchannels == 2) 
						
						// Lookup table choice single-channel images
						Dialog.addChoice("LUT in Single-Channel Export", getList("LUTs"), default_lut);
						
						// Lookup table choice multi-color overlays				
						if (nchannels > 1)
						{	
							Dialog.addChoice("LUT in Overlay Export", getList("LUTs"), default_lut);
						} // END if (nchannels > 1)
						
					} // END for (i_ch=1; i_ch ...
		
					Dialog.addCheckbox("Add scalebar?", true);
					
					// User interaction
					Dialog.show();
					
					// Extract values
					tf_get_single = Dialog.getCheckbox();
					if (nchannels > 1)	{tf_get_double = Dialog.getCheckbox();}	else {tf_get_double = false;}
					if (nchannels > 2)	{tf_get_triple = Dialog.getCheckbox();}	else {tf_get_triple = false;}
					
					min_contrasts = newArray(nchannels);			
					max_contrasts = newArray(nchannels);			
					luts_single = newArray(nchannels);			
					luts_overlay = newArray(nchannels);
					
					for (i_ch=0; i_ch < nchannels; i_ch++) 
					{
						min_contrasts[i_ch] = Dialog.getNumber();
						max_contrasts[i_ch] = Dialog.getNumber();
						luts_single[i_ch] = Dialog.getChoice();
						if (nchannels > 1) {luts_overlay[i_ch] = Dialog.getChoice();} else {luts_overlay[i_ch] = "Grays";}
							
					} //END for (i_ch=1; i_ch ...
					
					tf_add_scale_bar =  Dialog.getCheckbox();
					
					settings_done = true;
				} //END  if (settings_done == false)
		
				// Figure out what is a suitbale scale bar size
				// Iterate over different sizes and find the highest that is less than 1/3 of the image width

				sb_length = scaleBarSizeOptions[0];
				for (i_sb = 0; i_sb < scaleBarSizeOptions.length; i_sb++)
				{
					if (nx * sx / 3 > scaleBarSizeOptions[i_sb+1])
					{
						// Next one still makes sense
						sb_length = scaleBarSizeOptions[i_sb+1];
					}
					else
					{
						// The next one would be too long, so we stop here
						break;
					} // END if (nx * sx / 3 > scaleBarSizeOp...
				} // END for (i_sb = 0; i_sb...
				
				// Scale image to at least 1024x1024 px width to avoid aliasing in export
				// So if raw data is smaller, find an integer rescaling factor to fulfil that criterion
				smaller_axis_length = minOf(nx, ny);
				if (smaller_axis_length < 1024)
				{
					rescale = floor(1024 / smaller_axis_length) + 1;
				}
				else
				{
					rescale = 1;
				} // END if (smaller_axis_length...
			
				// RUN EXPORTS
				
				if (nchannels == 1)
				{
					// No channel splitting and overlay creation needed
					// Get greyscale stats
					run("Measure");
					
					// Preparation for saving
					image_id = getTitle();
					save_name = file_name_strip[0] + "_scene" + resolutionLevelIndex + "_ch" + i_ch;
					
					// Save
					save_to_png_single(image_id, 
									   min_contrasts[i_ch-1],
									   max_contrasts[i_ch-1],
									   nx,
									   ny,
									   rescale,
									   tf_add_scale_bar,
									   scale_bar_color,
									   sb_length,
									   luts_single[i_ch-1],
									   input_folder, 
									   save_name);
									   
				   // Close raw image
				   close();
				   
				} else // to if (nchannels == 1), meaning nchannels >= 2
				{			
					// Split and iterate over channels
					run("Split Channels");
					
					// Get measurements for all channels
					for (i_ch=1; i_ch <= nchannels; i_ch++)
					{
						selectWindow("C" + i_ch + "-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
						run("Measure");
					} // END for (i_ch=1; i_ch <= nchannels; i_ch++)
						
						
						
					if (tf_get_single)
					{
						// We export single-channel images
						for (i_ch=1; i_ch <= nchannels; i_ch++)
						{
							// Select correct image
							selectWindow("C" + i_ch + "-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
							
							// Preparation for saving
							image_id = getTitle();
							save_name = file_name_strip[0] + "_scene" + resolutionLevelIndex + "_ch" + i_ch;
					
							// Save
							save_to_png_single(image_id, 
											   min_contrasts[i_ch-1],
											   max_contrasts[i_ch-1],
											   nx,
											   ny,
											   rescale,
											   tf_add_scale_bar,
											   scale_bar_color,
											   sb_length,
											   luts_single[i_ch-1],
											   input_folder, 
											   save_name);
						} // END for (i_ch=1; i_ch <= nchannels; i_ch++)
					} // END if (tf_get_single)
		
		
		
					if (tf_get_double)
					{
						// We export the two-channel overlay(s)
						for (i_ch_1=1; i_ch_1 <= nchannels - 1; i_ch_1++)
						{
							for (i_ch_2=i_ch_1+1; i_ch_2 <= nchannels; i_ch_2++)
							{
								
								// Select image 1, prepare for export
								selectWindow("C" + i_ch_1 + "-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
								image_id_1 = getTitle();
								
								// Select image 2, prepare for export
								selectWindow("C" + i_ch_2 + "-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
								image_id_2 = getTitle();
								
								save_name = file_name_strip[0] + "_scene" + resolutionLevelIndex + "_ch" + i_ch_1 + "_ch" + i_ch_2;	
												
								save_to_png_dual(image_id_1, 
									 			 image_id_2, 
									   			 min_contrasts[i_ch_1-1],
									   			 min_contrasts[i_ch_2-1],
									   			 max_contrasts[i_ch_1-1],
									  			 max_contrasts[i_ch_2-1],
									  			 nx,
									  			 ny,
									  			 rescale,
									  			 tf_add_scale_bar,
									  			 scale_bar_color,
									  			 sb_length,
									  			 luts_overlay[i_ch_1-1],						   
									  			 luts_overlay[i_ch_2-1],
									  			 input_folder, 
									  			 save_name);
							} // END for i_ch_2=i_ch_1+1; i_ch_2 <= nchannels; i_ch_2++)
						} // END for (i_ch_1=1; i_ch_1 <= nchannels - 1; i_ch_1++)
					} // END if (tf_get_double)
					
				
					if (tf_get_triple && nchannels > 2) // We need at least three channels for this
					{
						// We write the three-channel overlay
						for (i_ch_1=1; i_ch_1 <= nchannels - 2; i_ch_1++)
						{
							for (i_ch_2=i_ch_1+1; i_ch_2 <= nchannels - 1; i_ch_2++)
							{
								for (i_ch_3=i_ch_2+1; i_ch_3 <= nchannels; i_ch_3++)
								{
									// Select image 1, prepare for export
									selectWindow("C" + i_ch_1 + "-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
									image_id_1 = getTitle();
									
									// Select image 2, prepare for export
									selectWindow("C" + i_ch_2 + "-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
									image_id_2 = getTitle();
									
									// Select image 2, prepare for export
									selectWindow("C" + i_ch_3 + "-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
									image_id_3 = getTitle();
									
									save_name = file_name_strip[0] + "_scene" + resolutionLevelIndex + "_ch" + i_ch_1 + "_ch" + i_ch_2 + "_ch" + i_ch_3;	
									save_to_png_triple(image_id_1, 
										 			   image_id_2, 
					 					 			   image_id_3, 
										   			   min_contrasts[i_ch_1-1],
										   			   min_contrasts[i_ch_2-1],
										   			   min_contrasts[i_ch_3-1],
										   			   max_contrasts[i_ch_1-1],
										  			   max_contrasts[i_ch_2-1],
										  			   max_contrasts[i_ch_3-1],
										  			   nx,
										  			   ny,
										  			   rescale,
										  			   tf_add_scale_bar,
										  			   scale_bar_color,
										  			   sb_length,
										  			   luts_overlay[i_ch_1-1],						   
										  			   luts_overlay[i_ch_2-1],
										  			   luts_overlay[i_ch_3-1],						   
										  			   input_folder, 
										  			   save_name);
								} // END for (i_ch_3=i_ch_2+1; i_ch_3 <= nchannels; i_ch_3++)
							} // END for (i_ch_2=i_ch_1+1; i_ch_2 <= nchannels - 1; i_ch_2++)
						} // END for (i_ch_1=1; i_ch_1 <= nchannels - 2; i_ch_1++)
					} // END if (tf_get_triple && nchannels > 2)
					
					// Close all raw data images
					for (i_ch=1; i_ch <= nchannels; i_ch++)
					{
						selectWindow("C" + i_ch + "-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
						close();
					}
				} // END if (nchannels == 1)
			} // END
		} // END if (endsWith(in_path, ".czi")) 
	} // END for (i = 0; i < file_list.length; i++)
	
	// Save table
	saveAs("Results", input_folder  + "Greyscale_stats.csv");
	
} else if (imagingMode ==  "RBG brightfield") 
// EXPORT OF RGB IMAGES
{
	for (i = 0; i < file_list.length; i++)
	{
		in_path = input_folder + file_list[i];
		if (endsWith(in_path, ".czi")) 
		{
			// Shortened file name to be used in export	
			file_name_strip = split(file_list[i], ".");
			
			run("Bio-Formats Macro Extensions");
			Ext.setId(in_path);
			Ext.getSeriesCount(seriesCount);
			
			for (resolutionLevelIndex = resolutionLevel; resolutionLevelIndex < seriesCount - 2; resolutionLevelIndex += 6)
			{
				if (resolutionLevelIndex < 10) {rLIAppend = "0";} else {rLIAppend = "";};
				
				// Open file, skipping BioFormats import wizard pop-up
				s = "open=[" + in_path + "] series_"+resolutionLevelIndex +" autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
				run("Bio-Formats Importer", s);
				
				// Get image dimensions
				// If the raw data contains more axes than xyc, there can be confusion
				// at this step depending on the ZEN version that wrote the file.  
				// If you encounter problems that may relate to axes being assigned wrong, 
				// the getDimensions() statement is the first thing to look at.
				getDimensions(nx, ny, nchannels, nz, nframes);
				getPixelSize(nm,sx,sy);
				run("Properties...", "channels=" + nchannels + " slices=" + nz + " frames=" + nframes + " pixel_width=" + sx * resolution_scaling_factor + " pixel_height=" + sy * resolution_scaling_factor + " voxel_depth=1.0000000");
				getPixelSize(nm,sx,sy);
				
				// After loading the first valid image, we adjust the settings for export (of all images)
				if (settings_done == false)
				{
					// When we reach this point for first image, let user specify target contrast for each channel 
					// Get parameters
					Dialog.create("Set export parameters");
					
					// Which images to export
					Dialog.addCheckbox("Export RBG color image?", true);					
					Dialog.addCheckbox("Export luminance greyscale image?", true);
					
					// Channel-wise contrast settings
					Dialog.addNumber("Contrast min Red ", 0);
					Dialog.addNumber("Contrast max Red ", 255);
					Dialog.addNumber("Contrast min Green ", 0);
					Dialog.addNumber("Contrast max Green ", 255);
					Dialog.addNumber("Contrast min Blue ", 0);
					Dialog.addNumber("Contrast max Blue ", 255);
					Dialog.addNumber("Contrast min Luminance ", 0);
					Dialog.addNumber("Contrast max Luminance ", 255);					
					Dialog.addChoice("LUT for Lum. Export", getList("LUTs"), "Grays");
					Dialog.addCheckbox("Add scalebar?", true);
					
					// User interaction
					Dialog.show();
					
					// Extract values
					tf_get_RGB = Dialog.getCheckbox();
					tf_get_lum = Dialog.getCheckbox();

					min_contrasts = newArray(nchannels);			
					max_contrasts = newArray(nchannels);			
					
					for (i_ch=0; i_ch < 4; i_ch++) 
					{
						min_contrasts[i_ch] = Dialog.getNumber();
						max_contrasts[i_ch] = Dialog.getNumber();							
					} //END for (i_ch=1; i_ch ...
					
					lum_LUT_choice = Dialog.getChoice();
					tf_add_scale_bar =  Dialog.getCheckbox();
					
					settings_done = true;
				} //END  if (settings_done == false)
		
				// Figure out what is a suitbale scale bar size
				// Iterate over different sizes and find the highest that is less than 1/3 of the image width
				sb_length = scaleBarSizeOptions[0];
				for (i_sb = 0; i_sb < scaleBarSizeOptions.length; i_sb++)
				{
					if (nx * sx / 3 > scaleBarSizeOptions[i_sb+1])
					{
						// Next one still makes sense
						sb_length = scaleBarSizeOptions[i_sb+1];
					}
					else
					{
						// The next one would be too long, so we stop here
						break;
					} // END if (nx * sx / 3 > scaleBarSizeOp...
				} // END for (i_sb = 0; i_sb...
				
				// Scale image to at least 1024x1024 px width to avoid aliasing in export
				// So if raw data is smaller, find an integer rescaling factor to fulfil that criterion
				smaller_axis_length = minOf(nx, ny);
				if (smaller_axis_length < 1024)
				{
					rescale = floor(1024 / smaller_axis_length) + 1;
				}
				else
				{
					rescale = 1;
				} // END if (smaller_axis_length...
			
				// RUN EXPORTS
						
				if (tf_get_lum)
				{
					// Export monochrome luminance image
					
					image_id = getTitle();
					run("RGB Color");
					rename("tempcopy");
					run("RGB to Luminance");
					rename("tempcopy2");
					close("tempcopy");
					save_name = file_name_strip[0] + "_scene" + resolutionLevelIndex + "_luminance";
					
					// Save
					save_to_png_single("tempcopy2", 
									   min_contrasts[3],
									   max_contrasts[3],
									   nx,
									   ny,
									   rescale,
									   tf_add_scale_bar,
									   scale_bar_color,
									   sb_length,
									   lum_LUT_choice,
									   input_folder, 
									   save_name);
									   
				   // Close luminance image
				   close("tempcopy2");
				   
				} // END if (tf_get_lum)
				
				if (tf_get_RGB)
				{

					// Split and iterate over channels
					run("Split Channels");

					// Select image 1, prepare for export
					selectWindow("C1-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
					image_id_1 = getTitle();
					
					// Select image 2, prepare for export
					selectWindow("C2-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
					image_id_2 = getTitle();
					
					// Select image 2, prepare for export
					selectWindow("C3-" + file_list[i] + " - " + file_list[i] + " #" + rLIAppend + resolutionLevelIndex);
					image_id_3 = getTitle();
					
					save_name = file_name_strip[0] + "_scene" + resolutionLevelIndex + "_RGB";	
					save_to_png_triple(image_id_1, 
						 			   image_id_2, 
	 					 			   image_id_3, 
						   			   min_contrasts[0],
						   			   min_contrasts[1],
						   			   min_contrasts[2],
						   			   max_contrasts[0],
						  			   max_contrasts[1],
						  			   max_contrasts[2],
						  			   nx,
						  			   ny,
						  			   rescale,
						  			   tf_add_scale_bar,
						  			   scale_bar_color,
						  			   sb_length,
						  			   "Red",						   
						  			   "Green",
						  			   "Blue",						   
						  			   input_folder, 
						  			   save_name);
					
					// Close all raw data images
					close(image_id_1);
					close(image_id_2);
					close(image_id_3);

				} // END if (tf_get_RGB)
			} // END for (resolutionLevelIndex = reso...
		} // END if (endsWith(in_path, ".czi")) 
	} // END for (i = 0; i < file_list.length; i++)
} // END if (imagingMode ==  "RBG brightfield") 
