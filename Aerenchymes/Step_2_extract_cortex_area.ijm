// Pieces of macros for RootCell treatments

// Trouve les centroids des steles et sauvegarde un ROI contenant tous les centres des images d'un dossier
run("Close All");
if (roiManager("count")>0){
	roiManager("Deselect");
	roiManager("Delete");
}

chezRomain=true;
chezMathieu=!chezRomain;
if(chezRomain){
	maindir="/home/rfernandez/Bureau/A_Test/Aerenchyme/Tests/PipeIJM/";
}
else maindir = "E:/DONNEES/Matthieu/Projet_PHIV-RootCell/Test/";
dir1=maindir+"Source";
list = getFileList(dir1);
N=list.length;
radiusStele=100;//Measured on a bunch of images


compute=false;
verif=true;

function excludeThisOne(imgName){
	if(imgName=="NOTHING HERE1f (2).tif")return true;
	return false;
}

if(compute){
	for (i=0; i<N; i++) {
		if(excludeThisOne(list[i]))continue;
		//Open and prepare image
		cleanRois();
		prepareImage(dir1+"/"+list[i]);
	
		//Get stele center coordinates
		coords=getCoordsOfPointInRoi(maindir+"SteleCenter/SteleCenter_highres_slice"+i+".zip");
		x=coords[0];
		y=coords[1];
	
		//////COMPUTE STELE CONTOUR
		// Remove stele center
		ray1=radiusStele*0.85;
		makeOval(x-ray1, y-ray1, ray1*2, ray1*2);
		run("Clear", "slice");
		run("Select None");
	
		 // Remove all the tissue outside the stele
		ray2=radiusStele*2; 
		makeOval(x-ray2, y-ray2, ray2*2, ray2*2);
		run("Clear Outside");
		run("Select None");
	
		 // Get contour
		run("Gaussian Blur...", "sigma=10");
		rename("gauss");
		run("Find Maxima...", "prominence=30 light output=[Single Points]");
		rename("marks");
		run("Marker-controlled Watershed", "input=gauss marker=marks mask=None compactness=0 binary calculate use");
		doWand(x,y);
		run("Enlarge...", "enlarge=-25");
		roiManager("Add");
		roiManager("Save", maindir+"CortexRoi/cortexInsideBoundary_slice"+i+".zip");
		cleanRois();
		run("Close All");
		
	
	
		//////COMPUTE SCLERENCHYME CONTOUR
		//Open and prepare image
		prepareImage(dir1+"/"+list[i]);
	
		// Remove all the stele
		ray1=radiusStele*2.7;
		makeOval(x-ray1, y-ray1, ray1*2, ray1*2);
		run("Clear", "slice");
		run("Select None");
	
		 // Get contour
		run("Median...", "sigma=20");
		run("Gaussian Blur...", "sigma=20");
		rename("gauss");
		run("Find Maxima...", "prominence=30 light output=[Single Points]");
		rename("marks");
		run("Marker-controlled Watershed", "input=gauss marker=marks mask=None compactness=0 binary calculate use");
		doWand(x,y);
		run("Enlarge...", "enlarge=3");
		roiManager("Add");
		roiManager("Save", maindir+"CortexRoi/cortexOutsideBoundary_slice"+i+".zip");
		cleanRois();
		run("Close All");
	}
}

if(verif){
	for (i=0; i<N; i++) {
		if(excludeThisOne(list[i]))continue;
		run("Close All");
		cleanRois();
		//////ADAPT THE CONTOURS A BIT INCLUDING A SAFETY ZONE
		prepareImage(dir1+"/"+list[i]);
		roiManager("open", maindir+"CortexRoi/cortexInsideBoundary_slice"+i+".zip");
		roiManager("open", maindir+"CortexRoi/cortexOutsideBoundary_slice"+i+".zip");
		//	run("Clear", "slice");
		//	run("Clear Outside");
		run("Select All");
		roiManager("Show All");
		waitForUser;
	}
}


run("Close All");
cleanRois();


function cleanRois(){
	if (roiManager("count")>0){
		roiManager("Deselect");
		roiManager("Delete");
	}
}

function getCoordsOfPointInRoi(path){
	tab=newArray(2);
	roiManager("open", path);
	roiManager("Select", 0);
	Roi.getCoordinates(xpoints, ypoints);
	roiManager("Delete");
	tab[0]=xpoints[0];
	tab[1]=ypoints[0];
	return tab;
}

function prepareImage(path){
	open(path);
	run("8-bit");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");
}

