//Step 1 Code: Get 3 images (manually setting), gather their coordinates, export info to textfile
//WIP, ask Jacob if any questions on functionality

//TO-DO:

//Global Variables
number imagex,imagey,imagez
number alpha, beta
string export_file_name = "Coordinate.txt"
string file_name = "model_fit.txt"
string output = "" //string that is shunted through Coordinate.txt
number deltaTilt = 1
number CurrentTilt = 0
number A, B, C   //To be used for y = Acos(B*theta + C) in model prediction
number xA,xB,xC,yA,yB,yC,zA,zB,zC
number tiltComplete = 0 //0 false, 1 true
number setting = 0


//REQUIRES: Two Images
//MODIFIES: x and y, the reference values
//EFFECTS : By performing CC, we see how an images change with rotation
//			Thus, we can see if the rotation axis is 	 at all tilted from being strictly <1 0 0>
//NOTE    :  z |
//			   |_ _ _ y
//			  /
//	         / x
//
// z is chamber height/defocus direction, x is presumed rotation axis, y is a translational axis
void Correlation(image &img1, image &img2, number &x, number &y) //Borrowed from Jonathan Schwartz 
{   
    // STEP 1: Ensure image are of same size, else pad (with zeros).
    number sx1, sy1, sx2, sy2
    GetSize( img1, sx1, sy1 )
    GetSize( img2, sx2, sy2 )
    Number mx = max( sx1, sx2 )
    Number my = max( sy1, sy2 )
    Number cx = trunc(mx/2)
    Number cy = trunc(my/2)
    image src := Realimage( "Source", 4, mx, my )       //Realimage(title, size, width, height)
    image ref := Realimage( "Reference", 4, mx, my )
    src[ 0, 0, sy1, sx1 ] = img1
    ref[ 0, 0, sy2, sx2 ] = img2
    
    // STEP 2: Cross-Correlate images and find maximum correlation
    image CC := CrossCorrelate( src, ref )
    String Name = "Correlation"
    SetName(CC, Name)
    ShowImage(CC)                               //Show the cross correlation. 
    number mpX, mpY
    max( CC, mpX, mpY )                         //Position of max pixel is at (mpX, mpY)
    number sX = cx - mpX 
    number sY = cy - mpY 

    Result( "Relative image shift: (" + sX + ", " + sY + ") pixels \n" )

    //Return the current STEM field-of-view (FOV) in calibrated units according to the stored calibration.
    number scaleX = img2.imageGetDimensionScale(0)  // Returns the scale of the given dimension of image.  
    number scaleY = img2.imageGetDimensionScale(1)   
    x = sX*scaleX
    y = sY*scaleY   

    Result("Relative image shift: (" + x + ", " + y + ") Microns \n" ) 

}

//EFFECTS: Generate a Dialog Box for Calibration
//NOTE   : Calibration entails finding tilt offset, x-y-z-alpha-beta at eucentric height
//DISCUSS: Should we acquire this point at alpha=beta=0? Does that better fit the model of prediction?
TagGroup CalibDialog()
{
	TagGroup Cal_items = newTagGroup()
	TagGroup Cal_box = DLGCreateBox("Calibration",Cal_items)

	TagGroup thetaTiltButton = DLGCreatePushButton("Find Tilt Angle Offset", "TiltOffset")
	TagGroup thetaOffsetField = DLGCreateRealField(0,4,4).DLGidentifier("tiltoffsetfield")
	TagGroup theta_region = DLGGroupitems(thetaTiltButton, thetaOffsetField).dlgtablelayout(1,2,1)
	TagGroup coordinateButton = DLGCreatePushButton("Acquire Coordinates", "Coordinate")	
	TagGroup ExportButton = DLGCreatePushButton("Export Coordinates", "Export").dlgexternalpadding(10,10)
	
	
	Cal_items.DLGAddElement(DLGgroupitems(theta_region,coordinateButton, ExportButton).DLGtablelayout(3,1,0))
	return Cal_box
}

//EFFECTS: Generate a Dialog Box for Tomography
//NOTE   : This should read in values from Python for the model: A, B, C such we that we fit a sinusoidal curve
//       : Information presented will let user know current position AND where the next position will be
//       : Interaction Flow: Click Tilt    -> Stage tilts to next tilt position as dictated by dTheta
//						   : Click Shift   -> Stage shifts to next shift position. Repeated presses WON'T work
//						   : Click Acquire -> Acquire with given acquistion settings. Update current AND next shift information
//DISCUSS: Because we have established Rotation and Shift are non-commutative, should we allow the user to do them separate?
//		 : Is it better to have a sinusoidal model in DMScript from A,B,C, or would it be better to be given
//				coordinates from Python directly and just know where in the .txt to look for it?
//		 : Stage Shift is for sure considering absolute coordinates, so no worry should be given to converting
//				between some rotated global coordinate system and what we calculate?
TagGroup TomoDialog()
{
	TagGroup Tomo_items = newTagGroup()
	TagGroup Tomo_box = DLGCreateBox("Tomography", tomo_items)
	
	//Load Button
	TagGroup Loadbutton = DLGCreatePushButton("Load Python", "Load")
	TagGroup RadioButtons = DLGCreateRadioList(0, "RadioSetting")
	RadioButtons.DLGaddRadioItem("Linear",0)
	RadioButtons.DLGaddRadioItem("Sinusoidal",1)
	TagGroup TiltRange_Label = DLGCreateLabel("Tilt Range: ")
	TagGroup LowerBoundfield = DLGCreateRealField(-25,4,2).DLGidentifier("LowerBoundfield")
	TagGroup UpperBoundfield = DLGCreateRealField(25,4,2).DLGidentifier("UpperBoundfield")
	TagGroup TiltRange_region = DLGgroupitems(TiltRange_Label,LowerBoundField,UpperBoundField).DLGtablelayout(3,1,0)
	
	TagGroup Load_items = newTagGroup()
	TagGroup Load_box = DLGCreateBox("Use ONCE", Load_items) 
	//Load_items.DLGaddelement(Loadbutton)
	Load_items.DLGaddelement(DLGGroupitems(Loadbutton,RadioButtons).DLGtablelayout(2,1,0))
	//Load_items.DLGaddelement(DLGGroupitems(Loadbutton,TiltRange_region).DLGtablelayout(1,2,0))
	
	
	//Tilt Column
	TagGroup TiltButton = DLGCreatePushbutton("Tilt", "tilt")
	TagGroup CurrTiltField = DLGCreateRealField(currenttilt, 7, 5).dlgidentifier("currenttiltfield")
	TagGroup CurrtiltField_Label = DLGCreateLabel("Current Tilt: " )
	TagGroup deltaTiltField = DLGCreateRealField(deltaTilt, 7, 5).dlgidentifier("deltatiltfield")
	TagGroup DeltaTiltField_Label = DLGCreateLabel("Step Field: ")
	
	TagGroup TiltOptions = DLGGroupItems(currtiltField_Label, currTiltField,DeltatiltField_Label, deltaTiltField).dlgtablelayout(2,2,0)
	
	
	
	//Stage Shift Column
	TagGroup ShiftButton = DLGCreatePushbutton("Shift Stage", "Shift")
	TagGroup EmptyLabel = DLGCreateLabel("")
	TagGroup XLabel = DLGCreateLabel("X")
	TagGroup YLabel = DLGCreateLabel("Y")
	TagGroup ZLabel = DLGCreateLabel("Z")
	
	TagGroup CurrLabel = DLGCreateLabel("Current: ")
	TagGroup CurrX = DLGCreateRealField(0,9,5).dlgidentifier("currX")
	TagGroup CurrY = DLGCreateRealField(0,9,5).dlgidentifier("currY")
	TagGroup CurrZ = DLGCreateRealField(0,9,5).dlgidentifier("currZ")
	//TagGroup CurrRow = DLGgroupitems(CurrLabel,CurrX,CurrY,CurrZ).DLGtablelayout(4,1,0)
	
	TagGroup NextLabel = DLGCreateLabel("Next: ")
	TagGroup NextX = DLGCreateRealField(0,9,5).dlgidentifier("nextX")
	TagGroup NextY = DLGCreateRealField(0,9,5).dlgidentifier("nextY")
	TagGroup NextZ = DLGCreateRealField(0,9,5).dlgidentifier("nextZ")
	//TagGroup NextRow = DLGGroupItems(NextLabel,NextX,NextY,NextZ).DLGTableLayout(4,1,0)
	
	TagGroup LeftestColumn = DLGGroupItems(EmptyLabel,CurrLabel,NextLabel).dlgTableLayout(1,3,1)
	TagGroup MidLeftColumn = DLGGroupitems(XLabel,Currx,NextX).DLGTableLayout(1,3,1)
	TagGroup MidRightColumn = DLGGroupitems(YLabel, CurrY,NextY).DLGTableLayout(1,3,1)
	Taggroup RightestColumn = DLGGroupItems(ZLabel,CurrZ,NextZ).DLGTableLAyout(1,3,1)
	TagGroup ShiftValueTable = DLGGroupItems(LeftestColumn,MidLeftColumn,MidRightColumn,RightestColumn).DLGTableLayout(4,1,0)
	//TagGroup TotalTable = DLGGroupItems(EmptyLabel,XLabel,YLabel,ZLabel,CurrLabel,CurrX,CurrY,CurrZ,NextLabel,NextX,NextY,NextZ).DLGTableLayout(4,3,1)
	//TagGroup ShiftColumn = DLGGroupItems(ShiftButton,TotalTable).DLGTableLayout(1,2,0)
	
	
	//Acquire/Save Column
	TagGroup AcquireButton = DLGCreatePushButton("Acquire", "acquire")
	
	//Final Organization Defining
	TagGroup value_region = DLGGroupItems(TiltOptions, ShiftValueTable).DLGTablelayout(2,1,0)
	TagGroup Procedure_column = DLGGroupItems(Load_box,Tiltbutton, ShiftButton,AcquireButton).dlgtablelayout(1,4,0)
	tomo_items.DLGAddElement(DLGGroupitems(value_region, Procedure_column).dlgtablelayout(2,1,0))	
	return tomo_box
	
}

//REQUIRES: Allocation to generate	
//DISCUSS : Varying ways of creating a ui object that can halt script process until closed, allow for it, 
//		       and place itself on separate threads.
class MainMenu : uiframe
{
	//-----BEGIN Main Launch Functions---------------------//
	
	//REQUIRES: uiframe created
	//EFFECTS : Generates ui buttons in specified locations
	TagGroup ButtonCreate(object self)
	{
		TagGroup RightSide = DLGgroupitems(MakeAcqDialog(),MakeSaveDialog()).dlgtablelayout(1,2,0)
		
		TagGroup LeftSide = DLGGroupItems(CalibDialog(),TomoDialog()).dlgtablelayout(1,2,0)
		
		TagGroup Total = DLGGroupitems(LeftSide,RightSide).DLGtablelayout(2,1,0)
		return Total
	}
	
	//EFFECTS: Called upon object creation. Creates frame, calls for button creation. 
	object Launch(object self)
	{
		self.init(self.ButtonCreate())
		self.Display("CA-Tomography")
	}
	//------END Main Launch Functions---------------------//
	
	//------BEGIN Save/Capture Acquistion Functions-------//
	
	//Acquisition and Save Script's Buttons
	//REQUIRES: SetPath button pressed
	//EFFECTS : Runs SetPath Function
	//NOTES   : Refer to NSSaveDialog for function performance
	void SetPath(object self)
	{
		SetPathFunction(self)
	}
	//REQUIRES: Save button pressed
	//EFFECTS : Runs Save Function, gives confirmation of success.
	//NOTES   : Refer to NSSaveDialog for function performance
	void Save(object self)
	{
		SaveFunction(self, 0)
		okdialog("Correct run-through\n")
	}
	//REQUIRES: Capture button pressed
	//EFFECTS : Runs Capture Function, yields confirmation
	//NOTES   : Refer to NSImageAcquisitionDialog_v2 for function performance
	void capture(object self)
	{
		captureFunction(self)
		okdialog("Capture Complete!")
	}
	
	//------END Save/Capture Acquisition Functions-------//
	
	//------BEGIN Calibration Functions------------------//
	
	//REQUIRES: Imaging ready environment, Tilt Offset Button is pressed
	//EFFECTS : Automatically take two pictures. From this, generate tilt offset information
	//             that suggests how far microscope deviates from ideal rotation axis (x)
	void TiltOffset(object self)
	{
		result("Getting tilt offset...\n")
		number xshift, yshift, theta_offset
		image img1,img2
		captureFunction(self)
		if (!getfrontimage(img1))
		{
			okdialog("No Image found!")
			return
		}
		img1 := getfrontimage()
		
		//EMSetStageAlpha(EMGetStageAlpha()+5)  //Tilts slightly
		//EMWaitUntilReady()
		captureFunction(self)
		if (!getfrontimage(img2))
		{
			okdialog("No Image found!")
			return
		}
		img2 := getfrontimage()
		
		Correlation(img1,img2,xshift,yshift)
		if (xshift==yshift)
		{
			okdialog("Same image used, or no tilt occurred. \nCheck for errors!")
			return
		}
		theta_offset = atan(xshift/yshift)  //Assumption: X-axis is ideal tilt axis, so Y direction is ideally only shift.
		dlgvalue(self.lookupelement("tiltoffsetfield"),theta_offset)
		result("Tilt offset found!")
	}
	
	//REQUIRES: Appropriate Imaging environment
	//MODIFIES: output
	//EFFECTS : Acquire alpha, x, y, z, beta values and load it into a global variable "output"
	//NOTES   : "output" is the string that is shunted through Coordinate.txt
	void coordinate(object self)
	{
		result("Acquiring...\n")
		//EMGetStagePositions(27,imagex,imagey,imagez,alpha,beta)
		//imagez = EMGetCalibratedFocus/1000
		output = output +alpha+","+imagex+","+imagey+","+imagez+","+beta+"\n"
		capturefunction(self)
		savefunction(self,1)
		result("Acquisition Complete!\n")
	}
	
	//EFFECTS : Creates Coordinate.txt with "output" in given SavePath
	void Export(object self)
	{
		result("Exporting...\n")
		string directory
		DLGgetValue(self.lookupelement("SavePathField"),directory)
		string fullpath = directory + export_file_name
		result(fullpath)
		number file = CreateFileForWriting(fullpath)
		WriteFile(file, output)
		CloseFile(file)
		result("Export Complete!\n")
	}
	
	//------END Calibration Functions-----//
	
	//------BEGIN Tomography Functions----//
	void RadioSetting(object self, taggroup itemTG){
		setting = itemTG.dlggetvalue()
		if(setting == 0){
			result("New Setting: Linear\n")
		}
		else if(setting == 1){
			result("New Setting: Sinusoidal\n")
		}
	}
	
	
	//REQUIRES: Python's A,B,C Curve_fitting given.
	//MODIFIES: A, B, C
	//EFFECTS : Reads in model_fit.txt to get sinusoidal variables
	//DISCUSS : Do we want the code to function this way? Assuming the linear idea that we're working with,
	//			   are we even reading the sinusoidal parts any more? Would it not instead be something like
	//			   dx, dy, dz that are read in?
	void Load(object self)
	{
		string directory
		DLGgetValue(self.lookupelement("SavePathField"),directory)
		number file
		string temporary_Line
		object myStream
		
		string full_path = directory+file_name
		
		if(setting == 0){
			LoadFunction_linear(self,full_path,xA,xB,yA,yB,zA,zB)
		}
		else if(setting ==1){
			LoadFunction_sinusoidal(self,full_path,xA,xB,xC,yA,yB,yC,zA,zB,zC)
		}
		
	}
	
	//REQUIRES: Python loaded
	//MODIFIES: stageTilt
	//EFFECTS : Adjusts tilt for the given three-step process
	//DISCUSS : Do we want to stop people from messing with this before Python is loaded?
	void Tilt(object self)
	{
		number tilt = DLGGetValue(self.lookupelement("currenttiltfield"))
		number anglechange = (DLGGetValue(self.lookupelement("deltatiltfield")))
		if(tiltComplete == 1){
			okdialog("Tilt already complete!\nProceed to Shift")
			return
		}
		
		
		//EMSetStageAlpha(anglechange + tilt)
		//EMWaitUntilReady()
		tiltComplete = 1
	}
	
	//REQUIRES: NextValues are calculated
	//MODIFIES: currentStage positions
	//EFFECTS : Sets current values to next values
	//DISCUSS : Do we want the code to function this way? Assuming the linear idea that we're working with,
	//			   it may be more convenient to just have tilt be repsonsible for shifting at the same time
	void Shift(object self)
	{
		number newX,newY,newZ
		newX = DLGGetValue(self.lookupelement("nextX"))
		newY = DLGGetValue(self.lookupelement("nextY"))
		newZ = DLGGetValue(self.lookupelement("nextZ"))*1000
		
		//EMSetStagePositions(3,newX,newY,newZ,0,0)
		//EMSetCalibratedfocus(newZ)
		
		//EMWaitUntilReady()
	}
	
	//REQUIRES: Python's A,B,C Curve_fitting given.
	//MODIFIES: next*, curr*
	//EFFECTS : Acquires Image, updates values for the next tilt-shift cycle
	//DISCUSS : Do we want the code to function this way?
	void acquire(object self)
	{
		if(tiltComplete == 0){
			okdialog("Please make sure tilt and stage shift have been completed")
			return
		}
		captureFunction(self)
		saveFunction(self,1)
		string directory
		DLGgetValue(self.lookupelement("SavePathField"),directory)
		string fullpath = directory + export_file_name
		result(fullpath)
		number file = OpenFileForWriting(fullpath)
		
		//EMGetStagePositions(27,imagex,imagey,imagez,alpha,beta)
		//imagez = EMGetCalibratedFocus()/1000
		output = output + alpha+","+imagex+","+imagey+","+imagez+","+beta+"\n"
		WriteFile(file,output) 
		result("File updated\n")
		CloseFile(file)
		if(setting == 0){
				RefreshFunction_linear(self,xA,xB,yA,yB,zA,zB)
			}
		else if(setting ==1){
				RefreshFunction_sinusoidal(self,xA,xB,xC,yA,yB,yC,zA,zB,zC)
		}
		//EMWaitUntilReady()
		tiltComplete = 0
	}
	
	//------END Tomography Functions----//
	
}



void CreateDialog()
{
	alloc(MainMenu).Launch()
}

CreateDialog()
