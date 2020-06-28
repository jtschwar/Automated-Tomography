//Inspired by Noah Schnitzer's AcqInterface code, should allow 
//for definition of image#, dwelltime, dimension and be installable
//NEEDED: NSSaveDialog
//and usable via simple procedure
//By Jacob Pietryga 23 July 2019

//SUB FUNCTIONS
//MODIFIES: 'Past' and 'Current' images
//EFFECTS : Gets rid of old 'Past' and replaces it with 'Current'
//			'Current' becomes the most recently found 'stack'
//NOTES   : It is important to have saved the acquired images prior if they are desired
void cycle_PastCurrent(){
	image img1,img2,img3
	img1 := FindImageByName("Past")
	if(ImageIsValid(img1)){
		deleteimage(img1)
	}
	img2 := FindImageByName("Current")
	if(ImageisValid(img2)){
		SetName(img2, "Past")
	}
	img3 := FindImageByName("stack")
	SetName(img3,"Current")	
}



//MAIN FUNCTIONS

//EFFECTS: Creates the Dialog box for Acquisition Box settings
TagGroup MakeAcqDialog()
{
	TagGroup Acq_items = newTagGroup()
	TagGroup Acq_box = DLGCreateBox("Acquisition Settings", Acq_items)

	//Creates All field options
	TagGroup dwellField = DLGCreateRealField(4,4,5).DLGidentifier("dwellField")
	TagGroup dwell_label = DLGCreateLabel("Dwell time (us):")
	TagGroup dimField = DLGCreateRealField(512, 5, 4).DLGidentifier("dimField")
	TagGroup dim_label = DLGCreateLabel("Dimensions (px):")
	TagGroup imageNumField = DLGCreateIntegerField(1, 2).DLGidentifier("imageNumfield")
	TagGroup image_label = DLGCreateLabel("Images per Acquisition: ")
	TagGroup captureButton = DLGCreatePushButton("Capture Image", "capture")
	TagGroup rotationfield = DLGCreateRealField(0,4,5).DLGidentifier("rotationField")
	TagGroup rotation_label = DLGCreateLabel("Rotation (degrees): ")
	
	//Create Detector Options (UNTESTED AND UNKNOWN EFFECTS)
	TagGroup detect_label = DLGCreateLabel("Select Detector: ")
	TagGroup detect1_check = DLGCreateCheckBox("1",1).dlgidentifier("detect1_check")
	TagGroup detect2_check = DLGCreateCheckBox("2",0).dlgidentifier("detect2_check")
	TagGroup detect_region = dlgGroupitems(detect_label, detect1_check,detect2_check).dlgtablelayout(3,1,0)
	
	TagGroup Label_column = DLGGroupitems(dwell_label,dim_label,Image_Label,rotation_label).dlgtablelayout(1,4,0)
	TagGroup entry_column = DLGGroupitems(dwellField,DimField,imageNumField,rotationfield).dlgTablelayout(1,4,1)
	TagGroup Values_Region = DLGgroupitems(Label_column,entry_column).DLGtablelayout(2,1,0)
	Acq_items.DLGAddElement(DLGgroupitems(values_Region, detect_region).DLGtablelayout(1,2,0))
	
	return Acq_box
}

//REQUIRES: Approrpiate Imaging Environment OR disabled EM functions
//EFFECTS : Using Acquisition parameters, capture and save image stack to SavePath
//NOTES   : Refer to NSSaveDialog for save functionality
void captureFunction(object given)
{
	result("Beginning Capture Function... \n")
	string savePath
	DLGgetValue(given.lookupelement("SavePathField"), savepath)
		if(savePath == "[NO PATH]")
		{
			okdialog("Must select path before imaging")
			return;
		}
	number detectChecks = 0
	number signalIndex = 0
	number dataDepth = 4
	number acquire = 1
	number imageID = 0
	number cDim
	//result("Variables instantiated")
	DLGGetValue(given.lookupelement("dimField"), cDim)
	//result("DLGGetValue used successfully")
	number cDwellT 
	DLGGetValue(given.lookupelement("dwellField"), cDwellT);
	number cImageNum 
	dlgGetValue(given.lookupelement("imageNumfield"), cImageNum)
	number sRotation
	dlgGetValue(given.lookupelement("rotationField"), sRotation)
	
	number ParamID = 1 //DSCreateParameters(cDim,cDim,sRotation,cDwellT,0)
	
	image stack = NewImage("stack",2,cDim,cDim,cImageNum)
	setname(stack,"stack")
	
	
	//result(dlgGetValue(given.lookupelement("detect1_check")))
	//result(dlgGetValue(given.lookupelement("detect2_check")))
	if(dlgGetValue(given.lookupelement("detect1_check")))
	{
		detectChecks += 1
		
		//DSSetParametersSignal(paramID,0,dataDepth,acquire,imageID)
	}
	if(dlgGetValue(given.lookupelement("detect2_check")))
	{	
		detectChecks += 1
		//DSSetParametersSignal(paramID,0,dataDepth,acquire,imageID)
	}
	if (detectChecks == 0)
	{
		okdialog("Please choose a detector!")
		return;
	}
	if (detectChecks >= 2)
	{
		okdialog("Functionality uncertain, please select one detector")
		return;
	}
	number i
	for (i = 0; i < cImageNum; i++)
	{
		//DSStartAcquisition(paramID,0,1)
		//image curr:= getFrontImage()
		//stack[0,0,i,cDim,CDim,i+1]=curr
		//DeleteImage(curr)
	}
	ShowImage(stack)
	cycle_PastCurrent()
	result("Capture Complete!\n")
}

