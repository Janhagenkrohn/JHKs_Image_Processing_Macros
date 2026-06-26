# -*- coding: utf-8 -*-
"""
Created on Tue Sep 30 13:09:32 2025

@author: Krohn
"""

'''
tba
'''

import pandas as pd
import numpy as np
import os
import re

folder = r'C:\Users\Krohn\Documents\Data\20260612_Ilgim_Oezerk\UBAP2L'

fold_change_cutoff = 1.3


###################

#%% Detect files
# Code in this section based on code generated using Codestral 22B
# Get a list of all files in the directory
all_files = os.listdir(folder)

# Filter the list to only include .csv files with the desired naming pattern
csv_files = [f for f in all_files if f.endswith('.csv') and re.match(r'^.*_Nucleus_Stats\.csv$|^.*_Spot_Stats\.csv$', f)]

# Extract the base names of the files (without the '_Ch2_stats' or '_Distance' suffix)
base_names = [os.path.splitext(f)[0].rsplit('_', 2)[0] for f in csv_files]

# Get unique base names
files = list(set(base_names))

#%% Prepare result container
results = pd.DataFrame(columns=['title',
                                'N_spots_total',
                                'N_nuclei',
                                
                                'N_spots_ch1_only',
                                'mean_spot_area_ch1_only',
                                'sd_spot_area_ch1_only',
                                'mean_spot_brightness_ch1_only',
                                'sd_spot_brightness_ch1_only',
                                'mean_circularity_ch1_only',
                                'sd_circularity_ch1_only',
                                
                                'N_spots_ch2_only',
                                'mean_spot_area_ch2_only',
                                'sd_spot_area_ch2_only',
                                'mean_spot_brightness_ch2_only',
                                'sd_spot_brightness_ch2_only',
                                'mean_circularity_ch2_only',
                                'sd_circularity_ch2_only',
                                
                                'N_spots_double_pos',
                                'mean_spot_area_double_pos',
                                'sd_spot_area_double_pos',
                                'mean_spot_brightness_double_pos_ch1',
                                'sd_spot_brightness_double_pos_ch1',
                                'mean_spot_brightness_double_pos_ch2',
                                'sd_spot_brightness_double_pos_ch2',
                                'mean_circularity_double_pos',
                                'sd_circularity_double_pos'
                                ])
i_row = 0

#%% Process files
for i_file, file in enumerate(files):
    
    # Load data and extract relevant columns
    file_path_spots = os.path.join(folder,
                                   file + '_Spot_Stats.csv')
    data_spots = pd.read_csv(file_path_spots)

    file_path_nuclei = os.path.join(folder,
                                    file + '_Nucleus_Stats.csv')
    data_nuclei = pd.read_csv(file_path_nuclei)
    
    
    spot_area_col = data_spots['Area'].to_numpy()
    spot_mean_brightness_col = data_spots['Mean'].to_numpy()
    spot_circularity_col = data_spots['Circ.'].to_numpy()
    spot_no_col = data_spots['Particle_No'].to_numpy()
    spot_channel_col = data_spots['Channel'].to_numpy()
    spot_mode_col = data_spots['Measurement_mode']

    n_particles_total = spot_area_col.shape[0]
    
    N_spots_ch1_only = 0
    N_spots_ch2_only = 0
    N_spots_double_pos = 0
    
    mean_spot_area_ch1_only = 0.
    sd_spot_area_ch1_only = 0.
    mean_spot_brightness_ch1_only = 0.
    sd_spot_brightness_ch1_only = 0.
    mean_circularity_ch1_only = 0.
    sd_circularity_ch1_only = 0.
    
    mean_spot_area_ch2_only = 0.
    sd_spot_area_ch2_only = 0.
    mean_spot_brightness_ch2_only = 0.
    sd_spot_brightness_ch2_only = 0.
    mean_circularity_ch2_only = 0.
    sd_circularity_ch2_only = 0.
    
    mean_spot_area_double_pos = 0.
    sd_spot_area_double_pos = 0.
    mean_spot_brightness_double_pos_ch1 = 0.
    sd_spot_brightness_double_pos_ch1 = 0.
    mean_spot_brightness_double_pos_ch2 = 0.
    sd_spot_brightness_double_pos_ch2 = 0.
    mean_circularity_double_pos = 0.
    sd_circularity_double_pos = 0.
    
    for i_spot in np.unique(spot_no_col):
        found_ch1_spot = False
        found_ch2_spot = False
        found_ch1_inflated = False
        found_ch2_inflated = False
        
        for i_row in range(n_particles_total):
            
            if spot_no_col[i_row] != i_spot:
                # Wrong spot, move on to next row
                continue
            
            if (spot_channel_col[i_row] == 1) and (spot_mode_col[i_row] == 'Particle'):
                # Spot measurement on channel 1
                ch1_spot_mean_brightness = spot_mean_brightness_col[i_row]
                spot_area = spot_area_col[i_row]
                spot_circularity = spot_circularity_col[i_row]
                found_ch1_spot = True

            if (spot_channel_col[i_row] == 2) and (spot_mode_col[i_row] == 'Particle'):
                # Spot measurement on channel 2
                ch2_spot_mean_brightness = spot_mean_brightness_col[i_row]
                found_ch2_spot = True

            if (spot_channel_col[i_row] == 1) and (spot_mode_col[i_row] == 'Inflated'):
                # Measurement of spots + surroundings on channel 1
                ch1_infl_mean_brightness = spot_mean_brightness_col[i_row]
                infl_area = spot_area_col[i_row]
                found_ch1_inflated = True

            if (spot_channel_col[i_row] == 2) and (spot_mode_col[i_row] == 'Inflated'):
                # Measurement of spots + surroundings on channel 1
                ch2_infl_mean_brightness = spot_mean_brightness_col[i_row]
                found_ch2_inflated = True
                
            if found_ch1_spot and found_ch2_spot and found_ch1_inflated and found_ch2_inflated:
                # We have found all the information on this particle that we need,
                # time to summarize (and skip looking at the rest of the table)
                
                # Recalc background from particle and inflated-area brightness
                ch1_infl_mean_brightness = (ch1_infl_mean_brightness * infl_area - ch1_spot_mean_brightness * spot_area) / (infl_area - spot_area)
                ch2_infl_mean_brightness = (ch2_infl_mean_brightness * infl_area - ch2_spot_mean_brightness * spot_area) / (infl_area - spot_area)
                
                # Positive particles are ones that are significantly brighter 
                # than their surrounding background
                ch1_positive = ch1_spot_mean_brightness / ch1_infl_mean_brightness >= fold_change_cutoff
                ch2_positive = ch2_spot_mean_brightness / ch2_infl_mean_brightness >= fold_change_cutoff
                
                if ch1_positive and (not ch2_positive):
                    # Channel 1 only
                    N_spots_ch1_only += 1
                    mean_spot_area_ch1_only += spot_area
                    sd_spot_area_ch1_only += spot_area**2
                    mean_spot_brightness_ch1_only += ch1_spot_mean_brightness
                    sd_spot_brightness_ch1_only += ch1_spot_mean_brightness**2
                    mean_circularity_ch1_only += spot_circularity
                    sd_circularity_ch1_only += spot_circularity**2

                if (not ch1_positive) and ch2_positive:
                    # Channel 2 only
                    N_spots_ch2_only += 1
                    mean_spot_area_ch2_only += spot_area
                    sd_spot_area_ch2_only += spot_area**2
                    mean_spot_brightness_ch2_only += ch2_spot_mean_brightness
                    sd_spot_brightness_ch2_only += ch2_spot_mean_brightness**2
                    mean_circularity_ch2_only += spot_circularity
                    sd_circularity_ch2_only += spot_circularity**2

                if ch1_positive and ch2_positive:
                    # Double-positive
                    N_spots_double_pos += 1
                    mean_spot_area_double_pos += spot_area
                    sd_spot_area_double_pos += spot_area**2
                    mean_spot_brightness_double_pos_ch1 += ch1_spot_mean_brightness
                    sd_spot_brightness_double_pos_ch1 += ch1_spot_mean_brightness**2
                    mean_spot_brightness_double_pos_ch2 += ch2_spot_mean_brightness
                    sd_spot_brightness_double_pos_ch2 += ch2_spot_mean_brightness**2
                    mean_circularity_double_pos += spot_circularity
                    sd_circularity_double_pos += spot_circularity**2
                
                # We are done with this particle, skip looking at the rest of 
                # the table and move on with the next particle
                break
            # END for i_row in range(n_particles_total):
        # END for i_spot in np.unique(spot_no_col):
            
    # Done with all particles, time to normalize running sums
    if N_spots_ch1_only > 0:
        mean_spot_area_ch1_only /= N_spots_ch1_only
        sd_spot_area_ch1_only = np.sqrt(sd_spot_area_ch1_only / N_spots_ch1_only - mean_spot_area_ch1_only**2)
        mean_spot_brightness_ch1_only /= N_spots_ch1_only
        sd_spot_brightness_ch1_only = np.sqrt(sd_spot_brightness_ch1_only / N_spots_ch1_only - mean_spot_brightness_ch1_only**2)
        mean_circularity_ch1_only /= N_spots_ch1_only
        sd_circularity_ch1_only = np.sqrt(sd_circularity_ch1_only / N_spots_ch1_only - mean_circularity_ch1_only**2)
    else:
        # No particles of this class found - then all of these values are zeros anyway
        pass
    
    if N_spots_ch2_only > 0:
        mean_spot_area_ch2_only /= N_spots_ch2_only
        sd_spot_area_ch2_only = np.sqrt(sd_spot_area_ch2_only / N_spots_ch2_only - mean_spot_area_ch2_only**2)
        mean_spot_brightness_ch2_only /= N_spots_ch2_only
        sd_spot_brightness_ch2_only = np.sqrt(sd_spot_brightness_ch2_only / N_spots_ch2_only - mean_spot_brightness_ch2_only**2)
        mean_circularity_ch2_only /= N_spots_ch2_only
        sd_circularity_ch2_only = np.sqrt(sd_circularity_ch2_only / N_spots_ch2_only - mean_circularity_ch2_only**2)
    else:
        # No particles of this class found - then all of these values are zeros anyway
        pass

    if N_spots_double_pos > 0:
        mean_spot_area_double_pos /= N_spots_double_pos
        sd_spot_area_double_pos = np.sqrt(sd_spot_area_double_pos / N_spots_double_pos - mean_spot_area_double_pos**2)
        mean_spot_brightness_double_pos_ch1 /= N_spots_double_pos
        sd_spot_brightness_double_pos_ch1 = np.sqrt(sd_spot_brightness_double_pos_ch1 / N_spots_double_pos - mean_spot_brightness_double_pos_ch1**2)
        mean_spot_brightness_double_pos_ch2 /= N_spots_double_pos
        sd_spot_brightness_double_pos_ch2 = np.sqrt(sd_spot_brightness_double_pos_ch2 / N_spots_double_pos - mean_spot_brightness_double_pos_ch2**2)
        mean_circularity_double_pos /= N_spots_double_pos
        sd_circularity_ch2_only = np.sqrt(sd_circularity_ch2_only / N_spots_double_pos - mean_circularity_double_pos**2)
    else:
        # No particles of this class found - then all of these values are zeros anyway
        pass

    
    # Get summary statistics 
    results.loc[i_row,'title'] = file
    results.loc[i_row,'N_spots_total'] = N_spots_ch1_only + N_spots_ch2_only + N_spots_double_pos
    results.loc[i_row,'N_nuclei'] = data_nuclei.shape[0] 
    
    results.loc[i_row,'N_spots_ch1_only'] = N_spots_ch1_only 
    results.loc[i_row,'mean_spot_area_ch1_only'] = mean_spot_area_ch1_only 
    results.loc[i_row,'sd_spot_area_ch1_only'] = sd_spot_area_ch1_only 
    results.loc[i_row,'mean_spot_brightness_ch1_only'] = mean_spot_brightness_ch1_only 
    results.loc[i_row,'sd_spot_brightness_ch1_only'] = sd_spot_brightness_ch1_only 
    results.loc[i_row,'mean_circularity_ch1_only'] = mean_circularity_ch1_only 
    results.loc[i_row,'sd_circularity_ch1_only'] = sd_circularity_ch1_only 

    results.loc[i_row,'N_spots_ch2_only'] = N_spots_ch2_only 
    results.loc[i_row,'mean_spot_area_ch2_only'] = mean_spot_area_ch2_only 
    results.loc[i_row,'sd_spot_area_ch2_only'] = sd_spot_area_ch2_only 
    results.loc[i_row,'mean_spot_brightness_ch2_only'] = mean_spot_brightness_ch2_only 
    results.loc[i_row,'sd_spot_brightness_ch2_only'] = sd_spot_brightness_ch2_only 
    results.loc[i_row,'mean_circularity_ch2_only'] = mean_circularity_ch2_only 
    results.loc[i_row,'sd_circularity_ch2_only'] = sd_circularity_ch2_only 

    results.loc[i_row,'N_spots_double_pos'] = N_spots_double_pos 
    results.loc[i_row,'mean_spot_area_double_pos'] = mean_spot_area_double_pos 
    results.loc[i_row,'sd_spot_area_double_pos'] = sd_spot_area_double_pos 
    results.loc[i_row,'mean_spot_brightness_double_pos_ch1'] = mean_spot_brightness_double_pos_ch1 
    results.loc[i_row,'sd_spot_brightness_double_pos_ch1'] = sd_spot_brightness_double_pos_ch1 
    results.loc[i_row,'mean_spot_brightness_double_pos_ch2'] = mean_spot_brightness_double_pos_ch2 
    results.loc[i_row,'sd_spot_brightness_double_pos_ch2'] = sd_spot_brightness_double_pos_ch2 
    results.loc[i_row,'mean_circularity_double_pos'] = mean_circularity_double_pos 
    results.loc[i_row,'sd_circularity_double_pos'] = sd_circularity_double_pos 

    

    i_row += 1
    
                
#%% Wrap up and save
results.to_csv(os.path.join(folder, 
                            'summary.csv'),
               header = True)
print('Job done.')
