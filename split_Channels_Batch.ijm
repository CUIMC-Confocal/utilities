// @File(label = "Input directory", style = "directory") dir1
// @File(label = "Output directory", style = "directory") dir2
// @String(label = "File suffix", value = ".tif") suffix

// Note: DO NOT DELETE OR MOVE THE FIRST 3 LINES -- they supply essential parameters

// split_Channels_Param.ijm
// TCS, 2017
// User is prompted for a folder containing multi-channel composite images
// Output: individual channel images saved in a folder specifed by the user.
// This macro processes all the images in a folder and any subfolders.


  setBatchMode(true);
  n = 0;
  processFolder(dir1);

  function processFolder(dir1) {
     list = getFileList(dir1);
     for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFolder(dir1++File.separator+list[i]);
          else if (endsWith(list[i], suffix))
             processImage(dir1, list[i]);
      }
  }

  function processImage(dir1, name) {
     open(dir1+File.separator+name);
     print(n++, name);

     id = getImageID();
     title = getTitle();
     dotIndex = indexOf(title, ".");
     basename = substring(title, 0, dotIndex);

     // here is the actual processing code
     run("Split Channels");
	 while (nImages > 0) { // works on any number of channels
		saveAs ("tiff", dir2+File.separator+getTitle);				// save every picture
		close();
    	}
  }
 

