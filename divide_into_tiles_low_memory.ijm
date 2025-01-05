//@ int(label="Size of tiles in pixels:") tileSize
//@File(label = "Input directory", style = "directory") inputDir
//@File(label = "Output directory", style = "directory") outputDir
// @String (label = "File suffix", value = ".nd2") fileSuffix

// divide_into_tiles_low_memory.ijm
// Theresa Swayne, 2025


// ---- Setup ----

while (nImages>0) { // clean up open images
	selectImage(nImages);
	close();
}
print("\\Clear"); // clear Log window

setBatchMode(true); // faster performance
run("Bio-Formats Macro Extensions"); // support native microscope files


// ---- Run ----

print("Starting");
processFolder(inputDir, outputDir, fileSuffix, tileSize);
while (nImages > 0) { // clean up open images
	selectImage(nImages);
	close(); 
}
setBatchMode(false);
print("Finished");


// ---- Functions ----

function processFolder(input, output, suffix, size) {
	filenum = -1;
	print("Processing folder", input);
	// scan folder tree to find files with correct suffix
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) {
			processFolder(input + File.separator + list[i], output, suffix);
		}
		if(endsWith(list[i], suffix)) {
			filenum = filenum + 1;
			processFile(input, output, list[i], filenum, size);
		}
	}
}


function processFile(inputFolder, outputFolder, fileName, fileNumber, tileSize) {
	
	path = inputFolder + File.separator + fileName;
	print("Processing file at path" ,path);	

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
	
	print("Processing file",fileName, "with basename",basename);
	

	// Calculate how many boxes we will need based on the user-selected size 
	// --  note that thin edges will not be converted based on tolerance in ceiling function
	nBoxesX = ceiling(width/tileSize);
	nBoxesY = ceiling(height/tileSize);
	nBoxes = nBoxesX * nBoxesY;
	print("We will make",nBoxesX,"x",nBoxesY,"tiles");
	// how much to pad?
	digits = 1 + Math.ceil((log(nBoxes)/log(10)));
	
	tileNum = 0;
	
	for(j=0; j< nBoxesY; j++) {
		for(i=0; i< nBoxesX; i++) {

			// increment a counter
			tileNum += 1;
			// open the region with crop on import makeRectangle(x+i*selectedSize, y+j*selectedSize, selectedSize,selectedSize);
			xStart = i * tileSize;
			yStart = j * tileSize;
			print("Creating tile at",xStart,",",yStart);
			run("Bio-Formats", "open=&path crop x_coordinate_1=&xStart y_coordinate_1=&yStart width_1=&tileSize height_1=&tileSize");
			// save the region -- basename_count_padded to 4 digits.tif
			tileNumPad = IJ.pad(tileNum, digits);
			tileName = basename+"_tile_"+tileNumPad;
			saveAs("tiff", outputFolder + File.separator + tileName);
			close();

		} // x loop
	} // y loop
} // process file

/*
 * Helper function, find ceiling value of float
 */
function ceiling(value) {
	tol = 0.2; // this is the fraction of box size below which an edge tile is not created  
	if (value - round(value) > tol) {
		return round(value)+1;
	} else {
		return round(value);
	}
}
	