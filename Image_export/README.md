# Image_export

The scripts collected here are miscellaneous scripts for automatically (batch) exporting data from propriotary image data formats into formats usable elsewhere. This may also include automated image processing steps.

**czi_scences_to_tiling_RGB.py** (Python script) iterates over multi-scene czi files where each scene is a single 
image or xy tile scan (RGB true color). It stitches those scences into a single large image and imputes the RGB value for the surrounding empty areas to avoid discontinuities. The result is written for 24 bit RBG format data. It was originally developed on and for Zeiss AxioScan Z1 image data of Tissue Microsection Arrays where the definition of ROIs and as a consequence storage of data ended up weird. 
Doing similar processing for fluorescence images will require adaptation of the script, although that will be simple. It simply has not been done. Feel free to contact the maintainer of the repo to inquire for such an alteration if you have an application for that.

**czi_to_figures.ijm** (ImageJ macro) is a script for batch mode conversion of a whole directory of .czi image files to color images for presentation, publication, etc. This is the version for single-image .czi files. It includes options for...
- selecting the channel-wise lookup table for export
- whether to export single-color images, two-color overlays, and/or three-color overlays (in each case, all possible combinations will be exported)
- and whether or not to add a scale bar (the scale bar length will be automatically chosen based on the input metadata)

**Elyra2Picasso.ijm** (ImageJ macro) is a script for batch mode conversion of a whole directory of Elyra7 .czi files to more generically usable formats. It is rather generically usable for .czi time xyt series data beyond the Elyra7 platform, though. 
The primary application is in Picasso-friendly .raw files, also auto-generating the .yaml file that Picasso needs for automatically reading a .raw file. Picasso is a software for single molecule localization microscopy data processing developed and maintained by the Ralf Jungmann lab. Check https://github.com/jungmannlab/picasso for details about Picasso.
This macro also supports export as TIFF stack usable for example in the Petra Schwille lab's Surface-Integrated FCS software, or other tools using .tif data. In case you are interested in the siFCS software itself, contact the Schwille lab directly.


