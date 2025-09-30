
# Measurements

The scripts collected here are miscellaneous scripts for analyzing image data to extract quantitative measurements, used in projects at some point or another.

**MinDE_get_distance_parameters.ijm** (ImageJ macro) has been used in Gavrilovic et al. Small 2024 (doi.org/10.1002/smll.202309680) to extract characteristic spatial scales of domains formed by pattern-forming MinDE proteins. Essentially it is uses segmentation followed by a distance transform and calculation of a mean value within masked regions to get the average pixel-wise distance from the closest domain border.

**YM_get_distance_dependent_parameters.ijm** (ImageJ macro) and **YM_summarize_data.py** (Python script) have been written for analysis of 4-channel microscopy data in which two channels were of interest. The data were acquired on tissue sections that showed a significant large-scale, but uninteresting, structure. Channel 1 showed nerve fibers (AF647, bright), channel 2 a certain cell type (Cy3, dimmer). The question here was "How does the morphology or brightness of cells change with distance from the nerve fibers?"
The basic strategy is to segment high-frequency structures in both channels while removing the low-frequency background, and save tables containing:
 1. Brightness statistics derived from a background-subtracted version of the cells
 2. Distance statistics on how far from the closest nerve fiber the cell is
The Python script then helps to aggregate the cell-wise statistics easily. It is developed with and for an environment built around Python 3.11, but uses only Pandas, Numpy, and trivial Python built-ins. 