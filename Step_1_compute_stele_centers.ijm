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
doVerif=!doCompute;

//1f5 4e 6f
if(doCompute){
	for (i=0; i<N; i++) {
		print("Processing "+list[i]);
		open(dir1+"/"+list[i]);
		run("8-bit");
		run("Enhance Contrast", "saturated=0.35");
		run("Apply LUT");
		run("Scale...", "x=0.25 y=0.25 z=1.0 width=409 height=272 depth=1 interpolation=Bilinear average process create");
	print("t000");
		for(j=0;j<20;j++){
			run("Morphological Filters", "operation=Closing element=Disk radius="+j);
			run("Morphological Filters", "operation=Opening element=Disk radius="+j);
		}
		makeOval(80, 40,240, 190);
				roiManager("Add");

	print("t001");
		run("Clear Outside");
		roiManager("Deselect");
		roiManager("Delete");
	print("t00");
		getStatistics(area, mean, min, max, std, histogram);
		threshold = max*0.97;
		//run("Threshold...");
		print("Til 1");
		setThreshold(threshold, 255);
		run("Analyze Particles...", "size=0-Infinity circularity=0-1.00 clear include add");
		run("Set Measurements...", "centroid display redirect=None decimal=3");
		roiManager("Select", 0);
		print("Til 2");
		List.setMeasurements;
	print("t01");
		r=20;
		x = List.getValue("X");
		y = List.getValue("Y");
		run("Close All");
		open(dir1+"/"+list[i]);
		run("Scale...", "x=0.25 y=0.25 z=1.0 width=409 height=272 depth=1 interpolation=Bilinear average process create");
		run("Median...", "radius=10");	
		run("Invert");
	print("t02");
		makeOval(x-r, y-r,r*2, r*2);
		run("Clear Outside");
		roiManager("Deselect");
		roiManager("Delete");
	print("t1");
		run("Find Maxima...", "prominence=30 output=[Point Selection]");
		roiManager("Add");
		roiManager("Save", maindir+"SteleCenter/SteleCenter_lowres_slice"+i+".zip");
	print("t2");
	}
}

if(doVerif){
	for (i=0; i<N; i++) {
			if(list[i]!="3b.tif")continue;
	if (roiManager("count")>0){
			roiManager("Deselect");
			roiManager("Delete");
		}
		run("Close All");
		open(dir1+"/"+list[i]);
		//run("Scale...", "x=0.25 y=0.25 z=1.0 width=409 height=272 depth=1 interpolation=Bilinear average process create");
		roiManager("open", maindir+"SteleCenter/SteleCenter_lowres_slice"+i+".zip");
		roiManager("Select", 0);
		Roi.getCoordinates(xpoints, ypoints);
		roiManager("Delete");
	
		x=xpoints[0];
		y=ypoints[0];
		makePoint(x*4, y*4, "large yellow hybrid");
		roiManager("Add");
		roiManager("Save", maindir+"SteleCenter/SteleCenter_highres_slice"+i+".zip");

//		roiManager("Select", 0);
		waitForUser;
	
	}
}
