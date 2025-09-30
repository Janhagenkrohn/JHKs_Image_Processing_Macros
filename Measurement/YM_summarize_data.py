# -*- coding: utf-8 -*-
"""
Created on Tue Sep 30 13:09:32 2025

@author: Krohn
"""

'''
This script takes the .csv files created by the ImageJ macro 
YM_get_distance_dependent_parameters.ijm
and creates aggregated statistics from those.

The user specifies only an in put directory as the string variable "folders"
and the distance cutoffs with which to classify cells into different distances 
from nerve fibers (list of integer or float numbers). The .csv files written 
by the ImageJ macro are auto-detected within the specified folder, and the 
numbers compiled in a single output table.

The result is a .csv spreadsheet that contains aggregate statistics for each 
image previously analyzed by YM_get_distance_dependent_parameters.ijm. Each 
image is represented by several rows: One for all cells within the image, and one
each for each bin of distance from closest nerve fiber. In Excel or similar, 
sorting these semi-manually and performing statistics as required will be trivial.

Calculated numbers are (each mean and SD over the cells in the respective class):
Cell area (square micrometers)
Cell-wise mean brightness (greyscale)
Cell-wise maximum brightness (greyscale)
Cell circularity

Note that the geometry parameters area and circularity are extremely sensitive to
quality of segmentation, and if these are of serious interest, some fine-tuning
of the segmentation parameters in the ImageJ macro may be needed towards shape
accuracy. Currently the segmentation is a three-way compromise between shape 
accuracy, detection sensitivity, and detection specificity.
'''

import pandas as pd
import numpy as np
import os
import re

folder = r'C:\Users\Krohn\Documents\Data\20250902_YMouloud_Apotome_scans\2025 08 01 - repAMI vs Sham\test'

distance_cutoffs = [10, 25, 50, 100] # in micrometers

###################

#%% Detect files
# Code in this section based on code generated using Codestral 22B
# Get a list of all files in the directory
all_files = os.listdir(folder)

# Filter the list to only include .csv files with the desired naming pattern
csv_files = [f for f in all_files if f.endswith('.csv') and re.match(r'^.*_Brightness\.csv$|^.*_Distance\.csv$', f)]

# Extract the base names of the files (without the '_Ch2_stats' or '_Distance' suffix)
base_names = [os.path.splitext(f)[0].rsplit('_', 1)[0] for f in csv_files]

# Get unique base names
files = list(set(base_names))

#%% Prepare result container
results = pd.DataFrame(columns=['title',
                                'N',
                                'min_distance',
                                'max_distance',
                                'mean_area',
                                'sd_area',
                                'mean_mean_brightness',
                                'sd_mean_brightness',
                                'mean_max_brightness',
                                'sd_max_brightness',
                                'mean_circularity',
                                'sd_circularity'
                                ])
i_row = 0

#%% Process files
for i_file, file in enumerate(files):
    
    # Load data and extract relevant columns
    file_path_brightness = os.path.join(folder,
                                        file + '_Brightness.csv')
    file_path_distance = os.path.join(folder,
                                      file + '_Distance.csv')
    
    data_brightness = pd.read_csv(file_path_brightness)
    data_distance = pd.read_csv(file_path_distance)
    
    area_col = data_brightness['Area'].to_numpy()
    mean_brightness_col = data_brightness['Mean'].to_numpy()
    max_brightness_col = data_brightness['Max'].to_numpy()
    circularity_col = data_brightness['Circ.'].to_numpy()
    distance_col = data_distance['Mean'].to_numpy()
    
    # Get statistics without distance filter
    results.loc[i_row,'title'] = file
    results.loc[i_row,'N'] = area_col.shape[0]
    results.loc[i_row,'min_distance'] = 0
    results.loc[i_row,'max_distance'] = np.inf
    results.loc[i_row,'mean_area'] = np.mean(area_col)
    results.loc[i_row,'sd_area'] = np.std(area_col)
    results.loc[i_row,'mean_mean_brightness'] = np.mean(mean_brightness_col)
    results.loc[i_row,'sd_mean_brightness'] = np.std(mean_brightness_col)
    results.loc[i_row,'mean_max_brightness'] = np.mean(max_brightness_col)
    results.loc[i_row,'sd_max_brightness'] = np.std(max_brightness_col)
    results.loc[i_row,'mean_circularity'] = np.mean(circularity_col)
    results.loc[i_row,'sd_circularity'] = np.std(circularity_col)
    
    i_row += 1
    
    # Classify cells according to distance and get statistics
    for i_dist, dist_cutoff in enumerate(distance_cutoffs):
        if i_dist == 0:
            # First bin - lower edge is 0
            low = np.array([0])
            high = np.array([dist_cutoff])
        elif i_dist == len(distance_cutoffs) - 1:
            # Last bin - extend to infinity
            low = np.array([dist_cutoff])
            high = np.array([np.inf])
        else:
            # Normal bin
            low = np.copy(high)
            high = np.array([dist_cutoff])
        # Array formating of scalars for technical reasons
        
        in_bin = np.logical_and(distance_col >= low,
                                distance_col < high)
        
        results.loc[i_row,'title'] = file
        results.loc[i_row,'N'] = np.sum(in_bin)
        results.loc[i_row,'min_distance'] = low
        results.loc[i_row,'max_distance'] = high
        results.loc[i_row,'mean_area'] = np.mean(area_col[in_bin])
        results.loc[i_row,'sd_area'] = np.std(area_col[in_bin])
        results.loc[i_row,'mean_mean_brightness'] = np.mean(mean_brightness_col[in_bin])
        results.loc[i_row,'sd_mean_brightness'] = np.std(mean_brightness_col[in_bin])
        results.loc[i_row,'mean_max_brightness'] = np.mean(max_brightness_col[in_bin])
        results.loc[i_row,'sd_max_brightness'] = np.std(max_brightness_col[in_bin])
        results.loc[i_row,'mean_circularity'] = np.mean(circularity_col[in_bin])
        results.loc[i_row,'sd_circularity'] = np.std(circularity_col[in_bin])
        
        i_row += 1
        
#%% Wrap up and save
results.to_csv(os.path.join(folder, 
                            'summary.csv'),
               header = True)
print('Job done.')
