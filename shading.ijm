
// paste this text in process > batch > macro window to process a whole folder

title = getTitle();
run("Pseudo Flat Field Correction (2D/3D)", "flatfieldradius=50.0 force2dfilter=true activechannelonly=false showbackgroundimage=false stackslice=1");
selectImage(title);
close();
selectImage("PFFC_"+title);
rename(title);
