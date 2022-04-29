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
N=10;

for (i=5; i<N; i++) {
	if (roiManager("count")>0){
		roiManager("Deselect");
		roiManager("Delete");
	}
	//Open and prepare image
	open(dir1+"/"+list[i]);
	run("8-bit");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");

	//Open roi with stele center coordinates
	roiManager("open", maindir+"SteleCenter/SteleCenter_highres_slice"+i+".zip");
	roiManager("Select", 0);
	Roi.getCoordinates(xpoints, ypoints);
	roiManager("Delete");
	x=xpoints[0];
	y=ypoints[0];

	radius=100;
	ray1=radius*0.92; // inclut forcément dans la stele
	makeOval(x-ray1, y-ray1, ray1*2, ray1*2);
	run("Clear", "slice");
	run("Select None");

	ray2=radius*2; // inclut forcément toute la stele
	makeOval(x-ray2, y-ray2, ray2*2, ray2*2);
	run("Clear Outside");
	run("Select None");

	run("Gaussian Blur...", "sigma=10");
	run("Find Maxima...", "prominence=30 light output=[Segmented Particles]");
	run("Invert");
	run("Analyze Particles...", "clear add");
	run("Close All");

	open(dir1+"/"+list[i]);
	run("8-bit");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");
	ray3=radius*2; // inclut forcément toute la stele
	makeOval(x-ray3, y-ray3, ray3*2, ray3*2);
	run("Clear", "slice");
	run("Select None");
	run("Gaussian Blur...", "sigma=15");
	run("Find Maxima...", "prominence=30 light output=[Segmented Particles]");
	run("Invert");
	run("Analyze Particles...", "exclude include add");
	run("Close All");
	
	open(dir1+"/"+list[i]);
	roiManager("Select", 0);
	run("Enlarge...", "enlarge=-20");
	run("Clear", "slice");
	roiManager("Select", 1);
	run("Enlarge...", "enlarge=2");
	run("Clear Outside");
	run("Select None");
	waitForUser;

}

