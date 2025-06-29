# Measurements

The scripts collected here are miscellaneous scripts for analyzing image data to extract quantitative measurements, used in projects at some point or another.

**MinDE_get_distance_parameters.ijm** (ImageJ macro) has been used in Gavrilovic et al. Small 2024 (doi.org/10.1002/smll.202309680) to extract characteristic spatial scales of domains formed by pattern-forming MinDE proteins. Essentially it is uses segmentation followed by a distance transform and calculation of a mean value within masked regions to get the average pixel-wise distance from the closest domain border.


