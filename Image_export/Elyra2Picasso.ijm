// Script for batch mode conversion of a whole directory of Elyra7 .czi
// files to Picasso-friendly .raw files, also auto-generating the .yaml
// file that Picasso needs for automatically reading a .raw file.

// Picasso is a software for single molecule localization microscopy
// data processing developed and maintained by the Ralf Jungmann lab. 
// Check https://github.com/jungmannlab/picasso for details about Picasso.


// This macro also supports export as TIFF stack usable for example in 
// the Petra Schwille lab's siFCS software, or other tools using .tif data. 
// In case you are interested in siFCS, contact the Schwille lab directly.




output_format = "Tiff"; // "Tiff" for siFCS or "raw" for DNA-PAINT
remove_outliers = true; // May be used if you acquired data without noise suppression in ZEN
binning = 2; // if you want to pre-bin data before export




/////////////////////////////////////////////////

input_folder = getDirectory("Choose a Directory");
file_list = getFileList(input_folder);

for (i = 0; i < file_list.length; i++)
{
	in_path = input_folder + file_list[i];
	if (endsWith(in_path, ".czi")) 
	{

		// Open file, skipping BioFormats import wizard pop-up
		s = "open=[" + in_path + "] autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
		run("Bio-Formats Importer", s);
		

			
		
		// Get some required small things
		// technically, what is nframes here should be nslices (referring to z), but this is read in wrong from the raw data
		getDimensions(width, height, nchannels, dummy2, nframes);

		if(binning > 1)
		{
		width = width / binning;
		height = height / binning;
		
		run("Scale...", "x="+ 1/binning +"y=" + 1/binning + "z=1.0 width="+width+" height="+height+" depth="+nframes+" interpolation=None average process create");
		
		
		}
		
		// Estimate resulting file size in GB to determine if TIFF can be used without splitting
		n_files_to_write = Math.ceil(width * height * nframes * 2 / 1024 / 1024 / 1024 / 3.9);
		
		getPixelSize(nm,sx,sy);
		file_name_strip = split(file_list[i], ".");

		// Remove hot pixels, in case the user specified that
		if (remove_outliers) 
		{
			run("Remove Outliers...", "radius=1 threshold=250 which=Bright stack");
		} // END if (remove_outliers)
				
						
		if (nchannels > 1)
		// Multiple channels
		{
			run("Split Channels");
			for (i_ch=1; i_ch <= nchannels; i_ch++)
			{
				selectWindow("C" + i_ch + "-" + file_list[i]);
				if (output_format == "Tiff") {
					
					
					// Save as .tif
					if (n_files_to_write < 2)
					{
						// Single file works
					    saveAs("Tiff", input_folder + file_name_strip[0] + "_ch" + i_ch + ".tif");
				    	close();
					} else {
						// Multiple files needed
						n_frames_per_block = floor(3.9 / (width * height * 2 / 1024 / 1024 / 1024))
						
						for (i_outfile = 1; i_outfile <= n_files_to_write; i_outfile++)
						{
							// Get a segment that is small enough to be written
							first_frame = (i_outfile - 1) * n_frames_per_block
							last_frame = minOf(i_outfile * n_frames_per_block - 1, nframes);
							run("Duplicate...", "duplicate range=" + first_frame + "-" + last_frame);
							
							if (i_outfile == 1)
							{
								// First block without suffix
								save_name = file_name_strip[0] + "_ch" + i_ch;
							} else {
								// Later blocks with suffix
								f_ind  = i_outfile - 1;
								save_name = file_name_strip[0] + "_ch" + i_ch + "_" + f_ind;
							} // END if (i_outfile == 1)
							
						    saveAs("Tiff", input_folder + save_name + ".tif");
				    		close();
							
						} // END for (i_outfile = 1; ...
						
						close();
						
					} // END if (n_files_to_write < 2)
					
				    
					// Save metadata yaml file
				    f = File.open(input_folder + file_name_strip[0] + "_ch" + i_ch + ".yaml");
					print(f, "Frames: " + d2s(nframes,0));
					print(f, "Height: " + d2s(height,0));
					print(f, "Width: " + d2s(width,0));
					print(f, "Pixelsize: " + d2s(sx*1000, 0)); // micrometers to nanometers
					File.close(f);
					
				} else {
					
					// Save as .raw
				    saveAs("raw", input_folder + file_name_strip[0] + "_ch" + i_ch + ".raw");
				    close();
					
					// Save metadata yaml file
				    f = File.open(input_folder + file_name_strip[0] + "_ch" + i_ch + ".yaml");
					print(f, "Byte Order: '>'");
					print(f, "Data Type: uint16");
					print(f, "Frames: " + d2s(nframes,0));
					print(f, "Height: " + d2s(height,0));
					print(f, "Width: " + d2s(width,0));
					print(f, "Pixelsize: " + d2s(sx*1000, 0)); // micrometers to nanometers
					File.close(f);
					
				} // END if (output_format == "Tiff") 
				
			} // END for (i_ch=1; i_ch =< nchannels; i_ch++)
			 
		} else {
			// Single channel
			if (output_format == "Tiff") 
			{
				
				// Save as .tif
				if (n_files_to_write < 2)
				{
					// Single file works
				    saveAs("Tiff", input_folder + file_name_strip[0] + ".tif");
			    	close();
			    	
				} else {
					// Multiple files needed
					n_frames_per_block = floor(3.9 / (width * height * 2 / 1024 / 1024 / 1024));
					
					for (i_outfile = 1; i_outfile <= n_files_to_write; i_outfile++)
					{
						// Get a segment that is small enough to be written
						first_frame = (i_outfile - 1) * n_frames_per_block;
						last_frame = minOf(i_outfile * n_frames_per_block - 1, nframes);
						run("Duplicate...", "duplicate range=" + first_frame + "-" + last_frame);
						
						if (i_outfile == 1)
						{
							// First block without suffix
							save_name = file_name_strip[0];
						} else {
							// Later blocks with suffix
							f_ind  = i_outfile - 1;
							save_name = file_name_strip[0] + "_" + f_ind;
						} // END if (i_outfile == 1)
						
					    saveAs("Tiff", input_folder + save_name + ".tif");
			    		close();
						
					} // END for (i_outfile = 1; ...
					
					close();
					
				} // END if (n_files_to_write < 2)
			    
				// Save metadata yaml file
			    f = File.open(input_folder + file_name_strip[0] + ".yaml");
				print(f, "Frames: " + d2s(nframes,0));
				print(f, "Height: " + d2s(height,0));
				print(f, "Width: " + d2s(width,0));
				print(f, "Pixelsize: " + d2s(sx*1000, 0)); // micrometers to nanometers
				
				File.close(f);
			} else {
				
				// Save as .raw
			    saveAs("raw", input_folder + file_name_strip[0] + ".raw");
			    close();
				
				// Save metadata yaml file
			    f = File.open(input_folder + file_name_strip[0] + ".yaml");
				print(f, "Byte Order: '>'");
				print(f, "Data Type: uint16");
				print(f, "Frames: " + d2s(nframes,0));
				print(f, "Height: " + d2s(height,0));
				print(f, "Width: " + d2s(width,0));
				print(f, "Pixelsize: " + d2s(sx*1000, 0)); // micrometers to nanometers
				
				File.close(f);
			} // END if (output_format == "Tiff")

		} //END  if (nchannels > 1)
		

	    if(binning > 1)
		{
			close();
		}
    } // END if (endsWith(in_path, ".czi"))
} // END for (i = 0; i < file_list.length; i++)