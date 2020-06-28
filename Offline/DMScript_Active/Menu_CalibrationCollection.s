//Step 1 Code: Get 3 images (manually setting), gather their coordinates, export info to textfile
//WIP, ask Jacob if any questions on functionality

//TO-DO:

//Global Variables
number imagex,imagey,imagez,df
number alpha, beta
number beamshiftX, beamshiftY
string export_file_name = "Coordinate.txt"
string file_name = "model_fit.txt"
string output = "" //string that is shunted through Coordinate.txt
number deltaTilt = 1
number CurrentTilt = 0
number xA,xB,xC,xD,yA,yB,yC,yD,zA,zB,zC,zD,dfA,dfB,dfC,dfD
number tiltComplete = 0 //0 false, 1 true
number setting = 0
image past, current

//HOLD these values and use these specifically. Do NOT want a user to adjust fields and thus
//change where shifts occur
number P_nextX,P_nextY,P_nextZ,P_nextDF,P_nextTilt
number X_shiftX,X_shiftY

number shift_safety = 0.5

//REQUIRES: Accurate Magnification read-in
//EFFECTS : Returns appropriate mag->pixel
number magToPixel(number mag){
	number m;
	number b;
	
	if(mag < 320e3){ //Low Mag
		m = 2.357e-4
		b = -4.1957e-11
	}
	else if(mag < 5.1e6){
		m = 2.359e-4
		b = -2.5336e-12
	}
	else{
		m = 2.3441e-4
		b = -7.2217e-14
	}
	return (1/mag * m + b);
}

// EFFECTS: Spit out current global and internal variables for user's benefit
void debugTrigger(object self){
	result("DEBUG: Predicted X Position: " + P_nextX + "\n")
	result("DEBUG: Predicted Y Position: " + P_nextY + "\n")
	result("DEBUG: Predicted Z Position: " + P_nextZ + "\n")
	result("DEBUG: XCorr Shift X: " + X_shiftX + "\n")
	result("DEBUG: XCorr Shift Y: " + X_shiftX + "\n")
	result("DEBUG: (xA,xB,xC,xD): (" + xA + ","+ xB +","+ xC +","+ xD +")\n")
	result("DEBUG: (yA,yB,yC,yD): (" + yA +","+ yB +","+ yC +","+ yD +")\n")
	result("DEBUG: (zA,zB,zC,zD): (" + zA +","+ zB +","+ zC +","+ zD +")\n")
	
	
	
}

//REQUIRES: Appropriate Imaging environment
//MODIFIES: output
//EFFECTS : Acquire x, y, z, alpha, beta, df, beamshiftX, beamshiftY values and load it into a global variable "output"
//NOTES   : "output" is the string that is shunted through Coordinate.txt
void acquire_coordinate()
{
	EMGetStagePositions(15,imagex,imagey,imagez,alpha,beta)
	df = EMGetFocus()*10000
	// EMGetBeamShift(beamshiftx,beamshifty)
	output = output+imagex+","+imagey+","+imagez+","+alpha+","+beta+","+df+","+beamshiftx+","+beamshifty+"\n"
	okdialog("Coordinates Acquired!")
}
	
//EFFECTS : Creates Coordinate.txt with "output" in given SavePath
void export_coordinate(object self)
{
	string directory
	DLGgetValue(self.lookupelement("SavePathField"),directory)
	string fullpath = directory + export_file_name
	result(fullpath)
	number file = CreateFileForWriting(fullpath)
	WriteFile(file, output)
	CloseFile(file)
	okdialog("Coordinates Exported!")
}

//MODIFIES: Global Next* variables
//EFFECTS : Takes calculated "next*" values, then locks them inside script
//				thus preventing users from entering values into fields incorrectly
void lock_next(object given){
	DLGGetvalue(given.lookupelement("nextX"),P_nextX)
	DLGGetvalue(given.lookupelement("nextY"),P_nextY)
	DLGGetvalue(given.lookupelement("nextZ"),P_nextZ)
	DLGGetvalue(given.lookupelement("nextDF"),P_nextDF)
	DLGGetvalue(given.lookupelement("nextTilt"),P_nextTilt)
	
}

//MODIFIES: modeling coefficients
//EFFECTS : Updates the coefficients from model_fit.txt. 
//NOTES   : Used to quietly update coefficients for active model use
//				may not be desired!
void load_Coefficients(object self){
		string directory
		DLGgetValue(self.lookupelement("SavePathField"),directory)
		
		
		string full_path = directory+file_name
		
		if(setting == 0){
			LoadFunction_linear(self,full_path,xA,xB,yA,yB,zA,zB,dfA,dfB)
		}
		else if(setting == 1){
			LoadFunction_sinusoidal(self,full_path,xA,xB,xC,xD,yA,yB,yC,yD,zA,zB,zC,zD,dfA,dfB,dfC,dfD)
		}
}
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
	result("sX =" + sX+"\n")
	result("cX =" + cX+"\n")
	result("mpX =" +mpX+"\n")
	result("sY =" + sY+"\n")
	result("cY =" + cY+"\n")
	result("mpY =" +mpY+"\n")
    //Result( "Relative image shift: (" + sX + ", " + sY + ") pixels \n" )

    //Return the current STEM field-of-view (FOV) in calibrated units according to the stored calibration.
    //number scaleX = img2.imageGetDimensionScale(0)  // Returns the scale of the given dimension of image.  
    //number scaleY = img2.imageGetDimensionScale(1)   
    number scaleX = magToPixel(EMGetMagnification())
    number scaleY = magToPixel(EMGetMagnification())
    
	x = sX*scaleX
    y = sY*scaleY   

    Result("Relative image shift: (" + x + ", " + y + ") Microns \n" ) 

}

//EFFECTS: Generate a Dialog Box for Tomography
//NOTE   : This should read in values from Python for the model: A, B, C, D such we that we fit a curve
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
	
	//LoadPython Settings/Button
	TagGroup Loadbutton = DLGCreatePushButton("Refresh", "refresh")
	TagGroup RadioButtons = DLGCreateRadioList(0, "RadioSetting")
	RadioButtons.DLGaddRadioItem("Linear",0)
	RadioButtons.DLGaddRadioItem("Sinusoidal",1)
	
	TagGroup Load_items = newTagGroup()
	TagGroup Load_box = DLGCreateBox("Tools/Settings", Load_items) 
	Load_items.DLGaddelement(DLGGroupitems(Loadbutton,RadioButtons).DLGtablelayout(2,1,0))
	//END LoadPython Settings/Button
	
	//Tilt Settings
	//Labels
	TagGroup Tilt_items = newTagGroup()
	TagGroup Tilt_box = DLGCreateBox("Tilt Limits", tilt_items)
	
	TagGroup MinTiltField = DLGCreateRealField(-70, 7, 5).dlgidentifier("mintiltfield")
	TagGroup MinTiltField_Label = DLGCreateLabel("Min")
	TagGroup Min_combined = DLGGroupitems(MinTiltField_Label,MinTiltField).dlgtablelayout(1,2,1)
	
	TagGroup MaxTiltField = DLGCreateRealField(70, 7, 5).dlgidentifier("maxtiltfield")
	TagGroup MaxTiltField_Label = DLGCreateLabel("Max")
	TagGroup Max_combined = DLGGroupitems(MaxTiltField_Label,MaxTiltField).dlgtablelayout(1,2,1)
	
	TagGroup Tilt_Block = DLGGroupItems(min_combined,max_combined).dlgtablelayout(2,1,0)
	Tilt_items.DLGaddelement(Tilt_Block)
	//END Tilt Settings
	
	//Stage Values Table
	//Labels Row
	TagGroup EmptyLabel = DLGCreateLabel("")
	TagGroup XLabel = DLGCreateLabel("X\n(um)")
	TagGroup YLabel = DLGCreateLabel("Y\n(um)")
	TagGroup ZLabel = DLGCreateLabel("Z\n(um)")
	TagGroup DFLabel = DLGCreateLabel("Defocus\n(um)")
	TagGroup TiltLabel = DLGCreateLabel("Tilt\n(degrees)")
	
	//Past Row
	TagGroup PastLabel = DLGCreateLabel("Past: ")
	TagGroup PastX = DLGCreateRealField(0,9,5).dlgidentifier("pastX")
	TagGroup PastY = DLGCreateRealField(0,9,5).dlgidentifier("pastY")
	TagGroup PastZ = DLGCreateRealField(0,9,5).dlgidentifier("pastZ")
	TagGroup PastDF = DLGCreateRealField(0,9,5).dlgidentifier("pastDF")
	TagGroup PastTilt = DLGCreateRealField(0,9,5).dlgidentifier("pastTilt")
	
	//Curr Row
	TagGroup CurrLabel = DLGCreateLabel("Current: ")
	TagGroup CurrX = DLGCreateRealField(0,9,5).dlgidentifier("currX")
	TagGroup CurrY = DLGCreateRealField(0,9,5).dlgidentifier("currY")
	TagGroup CurrZ = DLGCreateRealField(0,9,5).dlgidentifier("currZ")
	TagGroup CurrDF = DLGCreateRealField(0,9,5).dlgidentifier("currDF")
	TagGroup CurrTilt = DLGCreateRealField(0,9,5).dlgidentifier("currTilt")
	//TagGroup CurrRow = DLGgroupitems(CurrLabel,CurrX,CurrY,CurrZ).DLGtablelayout(4,1,0)
	
	//Next Row
	TagGroup NextLabel = DLGCreateLabel("Model Next: ")
	TagGroup NextX = DLGCreateRealField(0,9,5).dlgidentifier("nextX")
	TagGroup NextY = DLGCreateRealField(0,9,5).dlgidentifier("nextY")
	TagGroup NextZ = DLGCreateRealField(0,9,5).dlgidentifier("nextZ")
	TagGroup NextDF = DLGCreateRealField(0,9,5).dlgidentifier("nextDF")
	TagGroup NextTilt = DLGCreateRealField(0,9,5).dlgidentifier("nextTilt")
	//TagGroup NextRow = DLGGroupItems(NextLabel,NextX,NextY,NextZ).DLGTableLayout(4,1,0)
	
	
	//Combine into table.
	//NOTE: DLGGroupitems only allows 4 items
	//		This means things get a little weird with formatting
	DLGexternalpadding(emptylabel,0,6)
	DLGexternalpadding(pastLabel,0,2)
	DLGexternalpadding(currLabel,0,2)
	DLGexternalpadding(nextLabel,0,2)
	
	TagGroup LabelVals = DLGgroupitems(pastLabel,currLabel,nextLabel).DLGTableLayout(1,3,0)
	TagGroup Label_combined = DLGgroupitems(EmptyLabel,LabelVals).DLGTablelayout(1,2,0)

	TagGroup XVals = DLGgroupitems(pastX,currX,nextX).DLGTableLayout(1,3,1)
	TagGroup X_combined = DLGgroupitems(XLabel,XVals).DLGTablelayout(1,2,0)
	
	TagGroup YVals = DLGgroupitems(pastY,currY,nextY).DLGTableLayout(1,3,1)
	TagGroup Y_combined = DLGgroupitems(YLabel,YVals).DLGTablelayout(1,2,0)
	
	TagGroup ZVals = DLGgroupitems(pastZ,currZ,nextZ).DLGTableLayout(1,3,1)
	TagGroup Z_combined = DLGgroupitems(ZLabel,ZVals).DLGTablelayout(1,2,0)
	
	TagGroup DFVals = DLGgroupitems(pastDF,currDF,nextDF).DLGTableLayout(1,3,1)
	TagGroup DF_combined = DLGgroupitems(DFLabel,DFVals).DLGTablelayout(1,2,0)
	
	TagGroup TiltVals = DLGgroupitems(pastTilt,currTilt,nextTilt).DLGTableLayout(1,3,1)
	TagGroup Tilt_combined = DLGgroupitems(TiltLabel,TiltVals).DLGTablelayout(1,2,0)
	
	TagGroup XYZ_Block = DLGGroupitems(X_combined,Y_combined,Z_combined).dlgtablelayout(3,1,0)
	TagGroup TotalValues_Block = DLGGroupitems(Label_combined,XYZ_Block,DF_combined,Tilt_combined).dlgtablelayout(4,1,0)
	//END Stage Values table
	//Button Column
	TagGroup TakeImage_button = DLGCreatePushButton("Take Image","take_image")
	TagGroup SaveImageToTilt_button = DLGCreatePushButton("Save Image to Tilt Series","save_image_to_tilt")
	TagGroup Image_combined = DLGGroupItems(TakeImagE_button,SaveImageToTilt_button).dlgtablelayout(1,2,1)
	
	TagGroup TiltMinus_button = DLGCreatePushbutton("Tilt (-)","tilt_minus")
	TagGroup TiltPlus_button = DLGCreatePushbutton("Tilt (+)","tilt_plus")
	TagGroup deltaTiltField = DLGCreateRealField(5, 7, 5).dlgidentifier("deltatiltfield")
	TagGroup TiltButtons_combined = DLGGroupitems(TiltMinus_button,deltaTiltField,TiltPlus_button).DLGtableLayout(3,1,1)
	
	TagGroup ShiftModel_button = DLGCreatePushButton("Shift (Model Prediction)","shift_model")
	
	TagGroup CalcXCorr_button = DLGCreatePushButton("Calc. XCORR","calc_x_corr")
	TagGroup ShiftXCorr_button = DLGCreatePushButton("Shift XCORR","shift_x_corr")
	TaGGroup X_shiftLabel = DLGCreateLabel("Shift (X/Y um):").dlgexternalpadding(0,0).dlginternalpadding(0,0)
	TagGroup X_shiftX = DLGCreateRealField(0, 5, 3).dlgidentifier("X_shiftX")
	TagGroup X_shiftY = DLGCreateRealField(0, 5, 3).dlgidentifier("X_shiftY")
	TagGroup x_shiftFields = DLGGroupitems(X_shiftlabel,x_shiftX,X_shiftY).dlgtablelayout(3,1,0)
	TagGroup XCorr_combined = DLGGroupitems(CalcXCorr_button,X_shiftFields,ShiftXCorr_button).dlgtablelayout(1,3,1)
	
	TagGroup Button_column_T = DLGGroupItems(Image_combined,TiltButtons_combined,ShiftModel_button,XCorr_combined).dlgtablelayout(1,4,0)
	//END Button Column
	
	// Debug Button
	TagGroup Debug_items = newTagGroup()
	TagGroup Debug_box = DLGCreateBox("Debug ", debug_items)
	TagGroup Debug_button = DLGCreatePushButton("DEBUG","debug")
	debug_items.DLGAddElement(Debug_button)
	TagGroup Button_column = DLGGroupitems(Button_column_T,Debug_box).dlgtablelayout(1,2,0)
	
	//Final Organization Defining
	TagGroup topright_block = DLGGroupItems(Tilt_Box,Load_Box).dlgtablelayout(2,1,1)
	TagGroup rightside_Block = DLGGroupItems(topright_block,TotalValues_Block)
	DLGExternalpadding(rightside_Block,20,0)
	TagGroup Total_tomo = DLGGroupItems(Button_column,rightside_Block).dlgtablelayout(2,1,0)
	tomo_items.DLGAddElement(Total_tomo)	
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
		TagGroup Total = DLGGroupitems(MakeSaveDialog(),MakeAcqDialog(),TomoDialog()).DLGtablelayout(1,3,0)
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

	//------END Save/Capture Acquisition Functions-------//
	
	
	//------BEGIN Tomography Functions----//
	void RadioSetting(object self, taggroup itemTG){
		setting = itemTG.dlggetvalue()
		if(setting == 0){
			result("New Setting: Linear\n")
		}
		else if(setting == 1){
			result("New Setting: Sinusoidal\n")
		}
		RefreshFunction_curr(self)
	}	
	
	//REQUIRES: Python's A,B,C,D Curve_fitting given.
	//MODIFIES: A, B, C, D
	//EFFECTS : Reads in model_fit.txt to get form coefficients
	void refresh(object self)
	{
		RefreshFunction_curr(self)
		result("Loading Python...\n")
		load_coefficients(self)
		result("Complete!\n")
		okdialog("Refresh Complete")
	}
	
	//MODIFIES: current, "Current" image
	//EFFECTS : Uses given imageAcquisition settings to make a current image
	//				and, if needed, overwrite "Current"
	void take_image(object self){
		result("Taking image...\n")
		captureFunction(self, "Current")
		current := getfrontimage()
		RefreshFunction_curr(self)
		result("Take Complete!\n")
		okdialog("Image Taken")
	}
	
	//MODIFIES: past (image), Coordinates.txt, 
	//EFFECTS : Uses saveName parameters to save "Current"
	//		  : updates past coordinates for user benefit
	void save_image_to_tilt(object self){
		result("Saving Current to Tilt Series...")
		past := current
		SaveFunction(self,0)
		acquire_coordinate();
		export_coordinate(self);
		RefreshFunction_past(self)
		RefreshFunction_curr(self)
		result("Save Complete!")
		okdialog("Image Saved")
	}
	
	//MODIFIES: stageTilt
	//EFFECTS : Takes Microscope given alpha, adds step to it for a shift!
	void tilt_plus(object self)
	{
		result("Beginning tilt...\n")
		number tilt = EMGetStageAlpha()
		number anglechange = (DLGGetValue(self.lookupelement("deltatiltfield")))
		number newtilt = tilt+anglechange
		if(newtilt > DLGGetValue(self.lookupelement("maxtiltfield"))){
			okdialog("ERROR\nExceeding max tilt range")
			return
		}
		if(newtilt < DLGGetValue(self.lookupelement("mintiltfield"))){
			okdialog("ERROR\nExceeding min tilt range")
			return
		}
		
		
		EMSetStageAlpha(newtilt)
		//EMWaitUntilReady()
		RefreshFunction_curr(self)
		load_coefficients(self)
		RefreshFunction_next(self, setting, xA,xB,xC,xD,yA,yB,yC,yD,zA,zB,zC,zD,dfA,dfB,dfC,dfD);
		lock_next(self)
		
		result("Tilt complete!\n")
		okdialog("Tilt Plus Complete")
	}
	
	//MODIFIES: stageTilt
	//EFFECTS : Takes Microsocpe given alpha, subtracts step from it for a shift!
	void tilt_minus(object self)
	{
		result("Beginning tilt...\n")
		number tilt = EMGetStageAlpha()
		number anglechange = (DLGGetValue(self.lookupelement("deltatiltfield")))
		number newtilt = tilt-anglechange
		if(newtilt > DLGGetValue(self.lookupelement("maxtiltfield"))){
			okdialog("ERROR\nExceeding max tilt range")
			return
		}
		if(newtilt < DLGGetValue(self.lookupelement("mintiltfield"))){
			okdialog("ERROR\nExceeding min tilt range")
			return
		}
		
		
		EMSetStageAlpha(newtilt)
		//EMWaitUntilReady()
		RefreshFunction_curr(self)
		load_coefficients(self)
		RefreshFunction_next(self, setting, xA,xB,xC,xD,yA,yB,yC,yD,zA,zB,zC,zD,dfA,dfB,dfC,dfD);
		lock_next(self)
		
		result("Tilt complete!\n")
		okdialog("Tilt Negative Complete!")
	}
	
	//REQUIRES: NextValues are calculated
	//MODIFIES: currentStage positions, pastStage values 
	//EFFECTS : Sets current values to next values UNLESS they exceed a safety_factor
	//DISCUSS : Do we want an auto-stop if model looks odd? Doesn't exist?
	void shift_model(object self)
	{
		result("Beginning model shift...\n")
		number newX,newY,newZ,newDF
		number currX,currY,currZ,currDF
		number changeX,changeY,changeZ,changeDF
		newX = P_nextX
		newY = P_nextY
		newZ = P_nextZ
		newDF = P_nextDF
		
		EMGetStagePositions(15,currX,currY,currZ,alpha,beta)
		currDF = EMGetFocus()*10000
		changeX = abs(newX-currX)
		changeY = abs(newY-currY)
		changeZ = abs(newZ-currZ)
		changeDF = abs(newDF-currDF)
		
		if(changeX > shift_safety){
			okdialog("X Shift of " + changeX + " violates Safety Factor of "+ shift_safety)
			return 
		}
		if(changeY > shift_safety){
			okdialog("Y Shift of " + changeY + " violates Safety Factor of "+ shift_safety)
			return 
		}
		if(changeZ > shift_safety){
			okdialog("Z Shift of " + changeZ + " violates Safety Factor of "+ shift_safety)
			return 
		}
		if(changeDF > shift_safety){
			okdialog("DF Shift of " + changeDF + " violates Safety Factor of "+ shift_safety)
			return 
		}
		
		EMSetStagePositions(7,newX,newY,newZ,0,0)
		EMSetfocus(newDF/10000)
		
		//EMWaitUntilReady()
		RefreshFunction_curr(self)
		result("Model Shift Complete!\n")
		okdialog("Shift Button Complete")
	}
	
	//MODIFIES: 'Reference' image
	//EFFECTS : Generates a Reference image, then cross correlates this to past image (most recently saved to TiltSeries)
	//				Currently applies a butterworth filter to both images to filter
	void calc_x_corr(object self){
		result("Beginning XCORR...\n")
		number sx, sy
		number imagex,imagey,dummy
		captureFunction(self, "Reference")
		image reference := getfrontimage()
		image past_reduc = noise_reduction(past)
		image reference_reduc = noise_reduction(reference)
		Correlation(reference_reduc, past_reduc,sx,sy)
		EMGetStagePositions(3,imagex,imagey,dummy,dummy,dummy)
		X_shiftX = sx
		X_shiftY = sy
		DLGvalue(self.lookupelement("X_shiftX"),X_shiftX)
		DLGvalue(self.lookupelement("X_shiftY"),X_shiftX)
		
		RefreshFunction_curr(self)
		result("XCORR Complete!\n")
		okdialog("Cross Correlation Calculated")
	}
	//MODIFIES: Stage Positions
	//EFFECTS : Using script-held X_nextX/Y values, shift the stage. Checks if moves beyond a safety factor
	void shift_x_corr(object self){
		result("Beginning XCORR Shift...\n")
		number newX,newY
		number currX,currY
		number changeX,changeY
		number dummy
		
		EMGetStagePositions(3,currX,currY,dummy,dummy,dummy)
		changeX = abs(x_shiftX)
		changeY = abs(X_shiftY)
		
		if(changeX > shift_safety){
			okdialog("X Shift of " + changeX + " violates Safety Factor of "+ shift_safety)
			return 
		}
		if(changeY > shift_safety){
			okdialog("Y Shift of " + changeY + " violates Safety Factor of "+ shift_safety)
			return 
		}
		
		newX = currX + x_shiftX
		newY = currY + x_shiftY
		EMSetStagePositions(3,newX,newY,0,0,0)
		
		//EMWaitUntilReady()
		RefreshFunction_curr(self)
		result("XCORR Shift Complete!\n")
		okdialog("XCORR Shifted")
	}
	
	void debug(object self){
		debugTrigger(self)
	}
	
	//------END Tomography Functions----//
	
}



void CreateDialog()
{
	alloc(MainMenu).Launch()
}

CreateDialog()
