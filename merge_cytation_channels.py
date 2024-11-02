#@ File (label = "Input directory", style = "directory") inDir
#@ File (label = "Output directory", style = "directory") outDir
#@ String(label="Image File Extension", required=false, value=".tif") image_extension
#@ String  (label = "C1 name contains", value = "Phase") C1name
#@ String  (label = "C2 name contains", value = "GFP") C2name
#@ String  (label = "C3 name contains", value = "Red") C3name

# merge exactly 3 channels
# limitations: not recursive

# ---- Setup ----

import os
import math
import io
from net.imglib2.view import Views
from ij import IJ, ImagePlus, ImageStack
from ij.process import ImageProcessor, FloatProcessor, StackProcessor
import string
from ij.plugin import RGBStackMerge



# Create the arrays first

# ---- Find image files ---- 
inputDir = str(inDir) # convert the directory object into a string
outputDir = str(outDir)
fnames = [] # empty array for filenames

# set up arrays for channels
C1 = []
C2 = []
C3 = []

# get full file list
for fname in os.listdir(inputDir):
	if fname.startswith("."): # avoid dotfiles that have the extension and filename filter
		continue
	if fname.endswith(image_extension):
		fnames.append(os.path.join(inputDir, fname))

if len(fnames) < 1: # no files
	raise Exception("No image files found in %s" % inputdir)

fnames = sorted(fnames) # so correct images are matched up

# fill the channel arrays
for fname in fnames:
	if C1name in fname:
		C1.append(os.path.join(inputDir, fname))
	elif C2name in fname:
		C2.append(os.path.join(inputDir, fname))
	elif C3name in fname:
		C3.append(os.path.join(inputDir, fname))

if ((len(C1) != len(C3)) or (len(C1) != len(C2)) or (len(C2) != len(C3))):
	raise Exception("Unequal number of channel images found")

IJ.log("Found " + str(len(C1)) + " image sets")

# Loop over the images
for i in range(0, len(C1)):
	IJ.log("Processing set " + str(i))
	
	imp1 = IJ.openImage(os.path.join(inputDir,C1[i])) #image plus
	imp2 = IJ.openImage(os.path.join(inputDir,C2[i]))
	imp3 = IJ.openImage(os.path.join(inputDir,C3[i]))
	
	#stk1 = imp1.getStack() # get the stack within the ImagePlus
	#stk2 = imp2.getStack()
	#stk3 = imp3.getStack()
	imp1.show() # required
	imp2.show()
	imp3.show()
	
	C1file = os.path.basename(C1[i])
	#print C1file
	C2file = os.path.basename(C2[i])
	C3file = os.path.basename(C3[i])
	
	# use brackets to prevent spaces in filename from causing problems
	impMerge =IJ.run("Merge Channels...", "c1=[" + C1file + "] c2=[" + C2file + "] c3=[" + C3file + "] create")

	#stkMerge = RGBStackMerge.mergeStacks(stk1, stk2, stk3, False) # of course this makes RGB goddammit
	#impMerge = ImagePlus("merge", stkMerge)
	
	location = C1file.split("_")[0] # part up to the first underscore
	outputName = string.join((location,"_merge", image_extension), "")
	IJ.saveAs(impMerge, "Tiff", os.path.join(outputDir, outputName));

IJ.log("Finished")

