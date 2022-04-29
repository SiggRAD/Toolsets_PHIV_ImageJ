// Pieces of macros for RootCell treatments

// Trouve les centroids des steles et sauvegarde un ROI contenant tous les centres des images d'un dossier

run("Close All");
chezRomain=true;
chezMathieu=!chezRomain;
if(chezRomain){
	maindir="/home/rfernandez/Bureau/A_Test/Aerenchyme/Tests/PipeIJM/";
}
else maindir = "E:/DONNEES/Matthieu/Projet_PHIV-RootCell/Test/";

dir1=maindir+"Source";
list = getFileList(dir1);
print(dir1);

N=list.length;


doCompute=false;
doVerif=true;


if(doCompute){
	for (i=0; i<N; i++) {
		//Open and prepare image
		print("Processing "+list[i]);
		//if(list[i]!="2c.tif")continue;
		prepareImage(dir1+"/"+list[i]);
		
		//Alternated sequential filter at lower res to process faster
		run("Scale...", "x=0.25 y=0.25 z=1.0 width=409 height=272 depth=1 interpolation=Bilinear average process create");
		for(j=0;j<20;j++){
			run("Morphological Filters", "operation=Closing element=Disk radius="+j);
			run("Morphological Filters", "operation=Opening element=Disk radius="+j);
		}

		//Exclude edge area of the computation
		makeOval(80, 40,240, 190);
		roiManager("Add");
		run("Clear Outside");
		cleanRois();

		//Locate the maxima and its val-3% associated area
		getStatistics(area, mean, min, max, std, histogram);
		threshold = max*0.97;
		setThreshold(threshold, 255);
		run("Analyze Particles...", "size=0-Infinity circularity=0-1.00 clear include add");
		run("Set Measurements...", "centroid display redirect=None decimal=3");

		//Find the centroid of the maxima area
		roiManager("Select", 0);
		List.setMeasurements;
		x = List.getValue("X");
		y = List.getValue("Y");
		run("Close All");

		
		//Find the minima around this maxima in a first neighbourhood
		prepareImage(dir1+"/"+list[i]);
		run("Scale...", "x=0.25 y=0.25 z=1.0 width=409 height=272 depth=1 interpolation=Bilinear average process create");
		run("Median...", "radius=10");	
		run("Invert");
		r=20;
		makeOval(x-r, y-r,r*2, r*2);
		run("Clear Outside");
		cleanRois();
		run("Find Maxima...", "prominence=30 output=[Point Selection]");
		roiManager("Add");
		Roi.getCoordinates(xpoints, ypoints);
		roiManager("Delete");	
		x=xpoints[0]*2;
		y=ypoints[0]*2;

		
		//Find the minima around this minima in a second neighbourhood
		prepareImage(dir1+"/"+list[i]);
		run("Scale...", "x=0.5 y=0.5 z=1.0 width=818 height=544 depth=1 interpolation=Bilinear average process create");
//		run("Median...", "radius=5");	
//		run("Median...", "radius=10");	
		run("Gaussian Blur...", "sigma=10");
		run("Invert");
		rename("Med");
		r=30;
		makeOval(x-r, y-r,r*2, r*2);
		run("Clear Outside");
		cleanRois();
		run("Find Maxima...", "prominence=30 output=[Point Selection]");
		roiManager("Add");
		Roi.getCoordinates(xpoints, ypoints);
		roiManager("Delete");	
		x=xpoints[0];
		y=ypoints[0];
		prepareImage(dir1+"/"+list[i]);
		makePoint(x*2, y*2, "large yellow hybrid");
		roiManager("Add");
		roiManager("Save", maindir+"SteleCenter/SteleCenter_highres_slice"+i+".zip");
		wait(1000);
		run("Close All");
		cleanRois();
	}
}

if(doVerif){
	for (i=0; i<N; i++) {
		//if(list[i]!="2d.tif")continue;
		cleanRois();
		run("Close All");
		prepareImage(dir1+"/"+list[i]);
		roiManager("open", maindir+"SteleCenter/SteleCenter_highres_slice"+i+".zip");
		roiManager("Select", 0);
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

