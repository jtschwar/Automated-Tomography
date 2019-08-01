//Inspired by Noah Schnitzer's AcqInterface code, should allow 
//for definition of image#, dwelltime, dimension and be installable
//NEEDED: NSSaveDialog
//and usable via simple procedure
//By Jacob Pietryga 23 July 2019

//SUB FUNCTIONS
//none needed at the moment, perhaps in the future with additonal functionality







//MAIN FUNCTIONS

TagGroup MakeAcqDialog()
{
	TagGroup Acq_items = newTagGroup()
	TagGroup Acq_box = DLGCreateBox("Acquisition Settings", Acq_items)

	TagGroup dwellField = DLGCreateRealField(4,4,5).DLGidentifier("dwellfield")
	TagGroup dwell_label = DLGCreateLabel("Dwell time (us):")
	TagGroup dimField = DLGCreateRealField(512, 5, 4).DLGidentifier("dimfield")
	TagGroup dim_label = DLGCreateLabel("Dimensions (px):")
	TagGroup imageNumField = DLGCreateIntegerField(1, 2).DLGidentifier("imageNumfield")
	TagGroup image_label = DLGCreateLabel("Images per Acquisition: ")
	TagGroup captureButton = DLGCreatePushButton("Capture Image", "capture")
	TagGroup rotationfield = DLGCreateRealField(0,4,5).DLGidentifier("rotationfield")
	TagGroup rotation_label = DLGCreateLabel("Rotation (degrees): ")
	
	TagGroup Label_column = DLGGroupitems(dwell_label,dim_label,Image_Label,rotation_label).dlgtablelayout(1,4,0)
	TagGroup entry_column = DLGGroupitems(dwellField,DimField,imageNumField,rotationfield).dlgTablelayout(1,4,1)
	TagGroup Values_Region = DLGgroupitems(Label_column,entry_column).DLGtablelayout(2,1,0)
	Acq_items.DLGAddElement(DLGgroupitems(values_Region, captureButton).DLGtablelayout(1,2,0))
	
	return Acq_box
}

void captureFunction(object given)
{
	string savePath
	DLGgetValue(given.lookupelement("SavePathField"), savepath)
		if(savePath == "[NO PATH]")
		{
			okdialog("Must select path before imaging")
			return;
		}
	
	number signalIndex = 0
	number dataDepth = 4
	number acquire = 1
	number imageID = 0
	number cDim
	DLGGetValue(given.lookupelement("dimField"), cDim);
	number cDwellT 
	DLGGetValue(given.lookupelement("dwellField"), cDwellT);
	number cImageNum 
	dlgGetValue(given.lookupelement("imageNumfield"), cImageNum)
	number sRotation
	dlgGetValue(given.lookupelement("rotationfield"), sRotation)
	
	number ParamID = DSCreateParameters(cDim,cDim,sRotation,cDwellT,0)
	
	image stack = NewImage("stack",2,cDim,cDim,cImageNum)
	
	number i
	for (i = 0; i < cImageNum; i++)
	{
		DSStartAcquisition(paramID,0,1)
		image curr:= getFrontImage()
		stack[0,0,i,cDim,CDim,i+1]=curr
		DeleteImage(curr)
	}
	
}

