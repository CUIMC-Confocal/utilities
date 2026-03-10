//@ int(label="Upper left X:") xStart
//@ int(label="Upper left Y:") yStart
//@ int(label="Size in X:") xSize
//@ int(label="Size in Y:") ySize
//@File(label = "Input file", style = "file") inputFile
//@File(label = "Output directory", style = "directory") outputDir

// crop_split_t.ijm
// ImageJ/Fiji script to open a piece of a file for easier processing
// Does not require the entire image to be loaded into memory
// --- Opens a cropped area in XY and a single timepoint, then projects and saves --- 
// Theresa Swayne, 2026
// 

// TO USE: Create a folder for the output file. 
// 	Run the script in Fiji. 
//	Enter the desired parameters (you can get the crop area from Analyze > Set measurements > Bounding Box)
//  Limitation -- cannot have >1 dots in the filename
// 


// ---- Setup ----

run("Fresh Start");
//while (nImages>0) { // clean up open images
//	selectImage(nImages);
//	close();
//}
print("\\Clear"); // clear Log window

setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files


// ---- Run ----

print("Starting");
run("Fresh Start");
processFile(inputFile, outputDir, xStart, yStart, xSize, ySize);
while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");


function processFile(inputFile, outputFolder, xStart, yStart, xSize, ySize) {
	
	path = inputFile;
	print("Processing file at path" ,path);	

	fileName = File.getName(path);
	dotIndex = indexOf(fileName, "."); // limitation -- cannot have >1 dots in the filename
	basename = substring(fileName, 0, dotIndex); 
	extension = substring(fileName, dotIndex);
	
	// ---- Open image metadata only to get information ----
	Ext.setId(path);
	//run("Bio-Formats", "open=&path display_metadata view=[Metadata only] stack_order=Default");
	//title = getTitle();
	
	//getDimensions(width, height, channels, slices, frames);
	Ext.getSizeX(width);
	Ext.getSizeY(height);
	Ext.getSizeZ(slices);
	Ext.getSizeT(frames);
	
	digits = 1 + Math.ceil((log(frames)/log(10)));
	print("Processing file",inputFile, "with basename",basename);
	
	// open the region with crop on import makeRectangle(x+i*selectedSize, y+j*selectedSize, selectedSize,selectedSize);
	print("Creating tile at",xStart,",",yStart);
	
	
	// crop only (whole dataset)
	//run("Bio-Formats", "open=&path crop x_coordinate_1=&xStart y_coordinate_1=&yStart width_1=&xSize height_1=&ySize");

	for (tIndex = 1; tIndex <=frames; tIndex++) {
		//tIndex = 3;
		print("processing time",tIndex);
		// crop and open a subset of time
		run("Bio-Formats", "open=&path color_mode=Default series_1 crop specify_range z_begin=1 z_end=5 z_step=1 t_begin=&tIndex t_end=&tIndex t_step=1 x_coordinate_1=&xStart y_coordinate_1=&yStart width_1=&xSize height_1=&ySize");
		
		// save the region all Z
		tIndexPad = IJ.pad(tIndex, digits);
		cropName = basename + "_crop_t" + tIndexPad;
		//saveAs("tiff", outputFolder + File.separator + cropName);
		
		// save the projection
		run("Z Project...", "projection=[Max Intensity]");
		//selectWindow("MAX_"+cropName); this window is not found but the saving seems to work without it
		projName = basename + "_crop_max_t"+ tIndexPad;
		saveAs("tiff", outputFolder + File.separator + projName);
		
		close("*");
		run("Fresh Start");
	}
} // process file


	