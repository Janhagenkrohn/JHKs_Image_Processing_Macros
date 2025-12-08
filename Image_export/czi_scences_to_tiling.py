# -*- coding: utf-8 -*-
"""
Created on Mar 25 2025

@author: Jan-Hagen Krohn, IMCES-LMU, University Hospital Essen
ABOUT
This script  iterates over multi-scene czi files where each scene is a single 
image or xy tile scan. It stitches those scences into a single large image and 
imputes the greyscale value(s) for the surrounding empty areas to avoid 
discontinuities. Note that the stiching is done based on metadata alone, without
attempting image registration of overlapping borders.

The script can be used for RGB true-color data, or for fluorescence data. The
differences furtunately are not very big. RGB data is written into 24-bit RGB 
format, fluorescence data into 16-bit (per channel) format.

It was developed on and for Zeiss AxioScan image data of Tissue Microsection 
Arrays where the definition of ROIs and as a consequence storage of data ended 
up weird. Initially it was used for RGB data only, later adapted for fluorescence
as well.

REQUIREMENTS
The only real requirement is a Python environment with a reasonably recent 
version of the pylibCZIrw package. 
tifffile and numpy are also used, but if I am not mistaken, these will be 
automatically installed as dependencies by pip as packages that pylibCZIrw 
depends on.
"""

import os
from pylibCZIrw import czi as pyczi
import numpy as np
import tifffile



# Directory in which input files are (and where output will be written)
folder = r'D:\Test_data_collection\Fluorescence_TMA_Stiching'

# List of filenames - the script will automatically convert one after another,
# if there are multiple files
files = [
    '2025_12_04__8342.czi',
    'TMA7 P3 MQ 2025_12_03__8317.czi'
         ]

# Fluorescence data or RBG brightfield?
# accepted: 'fluorescence' and 'RGB'
mode = 'fluorescence' 

#%% Do not change after this line unless the script causes issues
#%% Function(s)
    
def merge_and_save(path,
                   mode):
    with pyczi.open_czi(path) as czidoc:
        
        # Documentation is poor, so here's a list of attributes and methods to 
        # try out when one wants to change stuff
        # CZIreader_methods = [method_name for method_name in dir(czidoc)]
        
        # Read out some metadata
        # metadata = czidoc.metadata['ImageDocument']['Metadata'] # These two layers are pro-forma, there is nothing else in here
        
        print(f'Data type: {czidoc.get_channel_pixel_type(0)}')
        
        # get the image dimensions as a dictionary, where the key identifies the dimension
        total_bounding_box = czidoc.total_bounding_box
        print('Dimensions:')
        [print(f'{key}: {total_bounding_box[key]}') for key in total_bounding_box.keys()]
        
        large_image = np.zeros([total_bounding_box['X'][1] - total_bounding_box['X'][0],
                                total_bounding_box['Y'][1] - total_bounding_box['Y'][0],
                                3 if mode == 'RGB' else total_bounding_box['C'][1]],
                               dtype = np.uint8 if mode == 'RGB' else np.uint16)
        glob_offset_x = total_bounding_box['X'][0]
        glob_offset_y = total_bounding_box['Y'][0]
     
        # get the bounding boxes for each individual acquisition position
        scenes_bounding_rectangle = czidoc.scenes_bounding_rectangle
        n_positions = len(scenes_bounding_rectangle)
        print(f'Number of positions in data: {n_positions}')
    
        for i_pos in range(n_positions):
            print(f'Processing scence # {i_pos}')
        
            # Exract data for this scene
            local_bounding_box = scenes_bounding_rectangle[i_pos]
            
            if mode == 'RGB':
                data_in_scene = czidoc.read(roi = local_bounding_box,
                                            plane = {'T':0,
                                                     'H':0,
                                                     'S':i_pos})
                data_in_scene = np.moveaxis(data_in_scene, 0, 1)
                
                # Get a mask to label empty pixels 
                mask_flat = np.all(data_in_scene == 255,
                                        axis = 2)
                mask = np.repeat(np.reshape(mask_flat,
                                            [mask_flat.shape[0],
                                             mask_flat.shape[1],
                                             1]),
                                 3,
                                 axis = 2)
                
            else: # mode == 'fluorescence'
                data_in_scene = np.zeros([local_bounding_box[2],
                                          local_bounding_box[3],
                                          total_bounding_box['C'][1]],
                                       dtype = np.uint16)
                
                for i_ch in range(total_bounding_box['C'][1]):
                     data_channel = czidoc.read(roi = local_bounding_box,
                                                plane = {'T':0,
                                                         'H':0,
                                                         'S':i_pos,
                                                         'C':i_ch})
                     data_channel = np.moveaxis(data_channel, 0, 1)
                     data_in_scene[:,:,i_ch] = np.reshape(data_channel,
                                                          shape = (data_channel.shape[0],
                                                                   data_channel.shape[1]))

                mask_flat = np.all(data_in_scene == 0,
                                        axis = 2)            
                mask = np.repeat(np.reshape(mask_flat,
                                            [mask_flat.shape[0],
                                             mask_flat.shape[1],
                                             1]),
                                 total_bounding_box['C'][1],
                                 axis = 2)
                
            
            # Get target ROI in large image where to insert data
            roi_min_x = local_bounding_box[0] - glob_offset_x
            roi_max_x = local_bounding_box[0] - glob_offset_x + local_bounding_box[2]
            roi_min_y = local_bounding_box[1] - glob_offset_y
            roi_max_y = local_bounding_box[1] - glob_offset_y + local_bounding_box[3]
            
            # Insert data, skipping empty pixels
            large_image[roi_min_x:roi_max_x,
                        roi_min_y:roi_max_y, 
                        :] = np.where(mask,
                                      large_image[roi_min_x:roi_max_x,
                                                  roi_min_y:roi_max_y, 
                                                  :],
                                      data_in_scene)
            
        # Here we stop accessing the original file
    # Clear a bit of memory
    del mask, data_in_scene
            
    # Wrap up
    
    print('Wrapping up')
    if mode == 'RGB':
        # Image is actually written as BGR by ZEN, not as RGB, so we invert 
        # the color axis to avoid confusion in downstream tools
        large_image = large_image[:,:,::-1]
    
    # Get a mask for empty pixels in large image. Note that empty pixels 
    # can be [255 255 255] or [0 0 0] for RGB, but only [0,0,0] for fluorescence
    mask_flat = np.all(large_image == 0,
                       axis = 2)
    if mode == 'RGB':
        mask_flat = np.logical_or(mask_flat, 
                                  np.all(large_image == 255,
                                         axis = 2))

    # Get median color within the non-empty pixels - should be representative of background    
    for i_color in range(large_image.shape[2]):
        color_slice = large_image[:,:,i_color]
        median_color = np.median(color_slice[np.logical_not(mask_flat)])
    
        # Replace empty pixels with median color
        color_slice[mask_flat] = median_color
        large_image[:,:,i_color] = color_slice
        
    # Free some memory
    del mask_flat, color_slice
        
            
    print('Saving result')

    
    # Write result as multi-channel tiff
    if mode == 'RGB':
        tifffile.imwrite(os.path.splitext(path)[0] + '.ome.tif', 
                         large_image, 
                         photometric='rgb', 
                         metadata={'axes': 'YXC'})
    else:
        # I am sure this is a very roundabout and inefficient method of doing it,
        # but somehow I had a lot of trouble getting the export of this data
        # to work. This is the method that ended up working...
        def frame_generator(large_image):
            for i_ch in range(large_image.shape[2]):
                yield large_image[:,:,i_ch].reshape((large_image.shape[0],
                                                     large_image.shape[1]))
        with tifffile.TiffWriter(os.path.splitext(path)[0] + '.ome.tif',
                                 ome = True,
                                 bigtiff=True
                                 ) as tiff:
            # Write each channel as a separate page
            tiff.write(
                data = frame_generator(large_image),
                photometric = 'minisblack',
                shape = (large_image.shape[2],
                         large_image.shape[0], 
                         large_image.shape[1]),
                dtype = np.uint16,
                metadata={'axes': 'CYX'}
            )

    # Free memory
    del large_image
        
    
#%% Run
if not mode in ['RGB', 'fluorescence']:
    raise ValueError('"mode" must be "RGB" or "fluorescence". Check for typos!')

for file in files:
    path = os.path.join(folder, file)
    print(f'Processing {path}')
    
    merge_and_save(path, 
                   mode)


print('Job done.')