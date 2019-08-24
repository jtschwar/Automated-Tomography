//Step 1 Code: Get 3 images (manually setting), gather their coordinates, export info to textfile
//WIP, ask Jacob if any questions on functionality

//TO-DO:


number imagex,imagey,imagez
number alpha, beta
string export_file_name = "Coordinate.txt"
string file_name = "model_fit.txt"
string output = ""
number deltaTilt = 1
number CurrentTilt = 0
number A, B, C   //To be used for y = Acos(B*theta + C)


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
	
TagGroup TomoDialog()
{
	TagGroup Tomo_items = newTagGroup()
	TagGroup Tomo_box = DLGCreateBox("Tomography", tomo_items)
	
	//Load Button
	TagGroup Loadbutton = DLGCreatePushButton("Load Python", "Load")
	TagGroup TiltRange_Label = DLGCreateLabel("Tilt Range: ")
	TagGroup LowerBoundfield = DLGCreateRealField(-25,4,2).DLGidentifier("LowerBoundfield")
	TagGroup UpperBoundfield = DLGCreateRealField(25,4,2).DLGidentifier("UpperBoundfield")
	TagGroup TiltRange_region = DLGgroupitems(TiltRange_Label,LowerBoundField,UpperBoundField).DLGtablelayout(3,1,0)
	
	TagGroup Load_items = newTagGroup()
	TagGroup Load_box = DLGCreateBox("Use ONCE", Load_items) 
	Load_items.DLGaddelement(Loadbutton)
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
	
class MainMenu : uiframe
{
	//Main Launch Functions (create buttons, create menu)
	TagGroup ButtonCreate(object self)
	{
		TagGroup RightSide = DLGgroupitems(MakeAcqDialog(),MakeSaveDialog()).dlgtablelayout(1,2,0)
		
		TagGroup LeftSide = DLGGroupItems(CalibDialog(),TomoDialog()).dlgtablelayout(1,2,0)
		
		TagGroup Total = DLGGroupitems(LeftSide,RightSide).DLGtablelayout(2,1,0)
		return Total
	}
	
	object Launch(object self)
	{
		self.init(self.ButtonCreate())
		self.Display("CA-Tomography")
	}
	//Acquisition and Save Script's Buttons
	void SetPath(object self)
	{
		SetPathFunction(self)
	}
	
	void Save(object self)
	{
		SaveFunction(self, 0)
		okdialog("Correct run-through\n")
	}
	
	void capture(object self)
	{
		captureFunction(self)
		okdialog("Capture Complete!")
	}
	
	
	//Calibration Buttons
	void TiltOffset(object self)
	{
		number xshift, yshift, theta_offset
		image img1,img2
		captureFunction(self)
		if (!getfrontimage(img1))
		{
			okdialog("No Image found!")
			return
		}
		img1 := getfrontimage()
		
		EMSetStageAlpha(EMGetStageAlpha()+5)  //Tilts slightly
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
	}
	void coordinate(object self)
	{
		result("Acquired!\n")
		EMGetStagePositions(31,imagex,imagey,imagez,alpha,beta)
		output = output +alpha+","+imagex+","+imagey+","+imagez+","+beta+"\n"
		capturefunction(self)
		savefunction(self,1)
	}
	
	void Export(object self)
	{
		result("Exported\n")
		string directory
		DLGgetValue(self.lookupelement("SavePathField"),directory)
		string fullpath = directory + export_file_name
		result(fullpath)
		number file = CreateFileForWriting(fullpath)
		WriteFile(file, output)
		CloseFile(file)
	}
	
	Tomography Buttons
	void Load(object self)
	{
		string directory
		DLGgetValue(self.lookupelement("SavePathField"),directory)
		number file
		string temporary_Line
		object myStream

		string full_path = directory+file_name
		if(DoesFileExist(full_path))
		{
			file = OpenFileforReading(full_path)
			myStream = newStreamFromFileReference( file, 0)
		}
		else
		{
			okdialog("File not found! Make sure Python loaded correctly")
			return;
		}
		
		//Read in the A,B,C values
		myStream.StreamReadTExtLine(0,temporary_Line)
		A = val(temporary_Line)
		myStream.StreamReadTExtLine(0,temporary_Line)
		B = val(temporary_Line)
		myStream.StreamReadTExtLine(0,temporary_Line)
		C = val(temporary_Line)
		//result("\n"+A+"\n"+B+"\n"+C+"\n")
		
		EMGetStagePositions(31,imagex,imagey,imagez,alpha,beta)
		dlgvalue(self.lookupelement("currX"), imagex)
		dlgvalue(self.lookupelement("currY"), imagey)
		dlgvalue(self.lookupelement("currZ"), imagez)
		dlgValue(self.lookupelement("currenttiltfield"), alpha)
		
		
		//Next Values, not sure if this works or not
		number nextAngle = (alpha + DLGGetValue(self.lookupelement("deltatiltfield")))*Pi()/180
		dlgvalue(self.lookupelement("nextX"), imageX)
		dlgvalue(self.lookupelement("nextY"), A * cos(B*nextAngle + C))
		dlgValue(self.lookupelement("nextZ"), A * sin(B*nextAngle + C))
		
		closefile(file)
	}
	
	void Tilt(object self)
	{
		number tilt = DLGGetValue(self.lookupelement("currenttiltfield"))
		number anglechange = (DLGGetValue(self.lookupelement("deltatiltfield")))
		EMSetStageAlpha(anglechange + tilt)
		EMWaitUntilReady()
	}
	
	void Shift(object self)
	{
		number newX,newY,newZ
		newX = DLGGetValue(self.lookupelement("nextX"))
		newY = DLGGetValue(self.lookupelement("nextY"))
		newZ = DLGGetValue(self.lookupelement("nextZ"))
		
		EMSetStagePositions(7,newX,newY,newZ,0,0)
		//Use necessary absolute EM commands
		EMWaitUntilReady()
	}
	
	void acquire(object self)
	{
		captureFunction(self)
		saveFunction(self,1)
		
		string directory
		DLGgetValue(self.lookupelement("SavePathField"),directory)
		string fullpath = directory + export_file_name
		number file = OpenFileForWriting(fullpath)
		
		
		EMGetStagePositions(31,imagex,imagey,imagez,alpha,beta)
		WriteFile(file,alpha+","+imagex+","+imagey+","+imagez+","+beta+"\n") 
		
		DSInvokeButton(1)
		
		//Add Refresh code, DLGValue w/ read in terms
		//Reset Current Values
		EMGetStagePositions(31,imagex,imagey,imagez,alpha,beta)
		dlgvalue(self.lookupelement("currX"), imagex)
		dlgvalue(self.lookupelement("currY"), imagey)
		dlgvalue(self.lookupelement("currZ"), imagez)
		dlgValue(self.lookupelement("currenttiltfield"), alpha)
		
		//Next Values, not sure if this works or not
		number nextAngle = (alpha + DLGGetValue(self.lookupelement("deltatiltfield")))*Pi()/180
		//result("\n" + DLGGetValue(self.lookupelement("deltatiltfield")))
		//result("\n"+ nextAngle)
		//result("\n"+ (A * cos(B*nextAngle + C)))
		dlgvalue(self.lookupelement("nextX"), imageX)
		dlgvalue(self.lookupelement("nextY"), A * cos(B*nextAngle + C))
		dlgValue(self.lookupelement("nextZ"), A * sin(B*nextAngle + C))
		
		EMWaitUntilReady()
	}
	
}



void CreateDialog()
{
	alloc(MainMenu).Launch()
}

CreateDialog()
