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

TagGroup CalibDialog()
{
	TagGroup Cal_items = newTagGroup()
	TagGroup Cal_box = DLGCreateBox("Calibration",Cal_items)
	TagGroup coordinateButton = DLGCreatePushButton("Acquire Coordinates", "Coordinate")
	
	TagGroup ExportButton = DLGCreatePushButton("Export Coordinates", "Export").dlgexternalpadding(10,10)
	
	Cal_items.DLGAddElement(DLGgroupitems(coordinateButton, ExportButton).DLGtablelayout(2,1,0))
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
	TagGroup TiltRange_region = DLGgroupitems(TiltRangE_Label,LowerBoundField,UpperBoundField).DLGtablelayout(3,1,0)
	
	TagGroup Load_items = newTagGroup()
	TagGroup Load_box = DLGCreateBox("Use ONCE", Load_items) 
	Load_items.DLGaddelement(Loadbutton)
	//Load_items.DLGaddelement(DLGGroupitems(Loadbutton,TiltRange_region).DLGtablelayout(1,2,0))
	
	
	//Tilt Column
	TagGroup TiltButton = DLGCreatePushbutton("Tilt", "tilt")
	TagGroup CurrTiltField = DLGCreateRealField(currenttilt, 5, 5).dlgidentifier("currenttiltfield")
	TagGroup CurrtiltField_Label = DLGCreateLabel("Current Tilt: " )
	TagGroup deltaTiltField = DLGCreateRealField(deltaTilt, 5, 5).dlgidentifier("deltatiltfield")
	TagGroup DeltaTiltField_Label = DLGCreateLabel("Step Field: ")
	
	TagGroup TiltOptions = DLGGroupItems(currtiltField_Label, currTiltField,DeltatiltField_Label, deltaTiltField).dlgtablelayout(2,2,0)
	
	
	
	//Stage Shift Column
	TagGroup ShiftButton = DLGCreatePushbutton("Shift Stage", "Shift")
	TagGroup EmptyLabel = DLGCreateLabel("")
	TagGroup XLabel = DLGCreateLabel("X")
	TagGroup YLabel = DLGCreateLabel("Y")
	TagGroup ZLabel = DLGCreateLabel("Z")
	
	TagGroup CurrLabel = DLGCreateLabel("Current: ")
	TagGroup CurrX = DLGCreateRealField(0,5,5).dlgidentifier("currX")
	TagGroup CurrY = DLGCreateRealField(0,5,5).dlgidentifier("currY")
	TagGroup CurrZ = DLGCreateRealField(0,5,5).dlgidentifier("currZ")
	//TagGroup CurrRow = DLGgroupitems(CurrLabel,CurrX,CurrY,CurrZ).DLGtablelayout(4,1,0)
	
	TagGroup NextLabel = DLGCreateLabel("Next: ")
	TagGroup NextX = DLGCreateRealField(0,5,5).dlgidentifier("nextX")
	TagGroup NextY = DLGCreateRealField(0,5,5).dlgidentifier("nextY")
	TagGroup NextZ = DLGCreateRealField(0,5,5).dlgidentifier("nextZ")
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
		self.Pose()
	}
	//Acquisition and Save Script's Buttons
	void SetPath(object self)
	{
		SetPathFunction(self)
	}
	
	void Save(object self)
	{
		result("Save Pressed\n")
		SaveFunction(self, 0)
	}
	
	void capture(object self)
	{
		result("Capture pressed\n")
		captureFunction(self)
		result("Capture Complete\n")
	}
	
	
	//Calibration Buttons
	void coordinate(object self)
	{
		result("Acquired!")
		//EMGetStagePositions(31,imagex,imagey,imagez,alpha,beta)
		output = output +imagex+","+imagey+","+imagez+","+alpha+","+beta+"\n"
		capturefunction(self)
		savefunction(self,1)
	}
	
	void Export(object self)
	{
		result("Exported")
		string directory
		DLGgetValue(self.lookupelement("SavePathField"),directory)
		string fullpath = directory + export_file_name
		result(fullpath)
		number file = CreateFileForWriting(fullpath)
		WriteFile(file, output)
		CloseFile(file)
	}
	
	//Tomography Buttons
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
		
		//EMGetStagePositions(31,imagex,imagey,imagez,alpha,beta)
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
		number anglechange = (DLGGetValue(self.lookupelement("deltaTiltField")))
		number newtilt = anglechange + tilt
		//EMSetStageAlpha(newtilt)
		//EMWaitUntilReady()
	}
	
	void Shift(object self)
	{
		number newX,newY,newZ
		newX = DLGGetValue(self.lookupelement("nextX"))
		newY = DLGGetValue(self.lookupelement("nextY"))
		newZ = DLGGetValue(self.lookupelement("nextZ"))
		
		//EMSetStagePositions(7,nextX,nextY,nextZ,0,0)
		//Use necessary absolute EM commands
		//EMWaitUntilReady()
	}
	
	void acquire(object self)
	{
		//captureFunction(self)
		//saveFunction(self,1)
		
		//Add Refresh code, DLGValue w/ read in terms
		//Reset Current Values
		//EMGetStagePositions(31,imagex,imagey,imagez,alpha,beta)
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
		
		//EMWaitUntilReady()
	}
	
}



void CreateDialog()
{
	alloc(MainMenu).Launch()
}

CreateDialog()