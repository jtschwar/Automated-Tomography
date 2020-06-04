//Faux EM Library

//This Script should cover all functions as of GMS 2.3.1
//Use this script to more easily develop offline code.
//To use, install as a library on offline device
//Then, when on the microscope, DO NOT install this script.

//Scripts will give output feedback to show they are working
//Values spawned will mostly be dummy values.

//VARIABLES
//Boolean does not exist offline, so Number (1/0) used instead
//NumberVariable = Number

Number EMCanGetCameraLength( ){
	result("Can get Camera Length\n")
	return 1
}

Number EMCanGetHighTension(){
	result("Can get accelerating voltage\n")
	return 1
}

Number EMCanGetIlluminationMode( ){
	result("Can get illumination mode\n")
	return 1
}

Number EMCanGetImagingOpticsMode(){
	result("Can get Imaging Optics Mode\n")
	return 1
}

Number EMCanGetMagnification(){
	result("Can get magnification\n")
	return 1
}

void EMChangeBeamShift(Number xAmount, Number yAmount){
	result("Beam Shift x by " + xAmount + " raw units and y by " + yAmount + " raw units\n")
}

void EMChangeBeamTilt( Number xAmount, Number yAmount ){
	result("Beam Tilt x by " + xAmount + " raw units and y by " + yAmount + " raw units\n")
}

void EMChangeCalibratedBeamShift( Number xAmount, Number yAmount ){
	result("Beam Shift x by " + xAmount + " calibrated units and y by " + yAmount + " calibrated units\n")
}

void EMChangeCalibratedBeamTilt( Number xAmount, Number yAmount ){
	result("Beam Shift x by " + xAmount + " calibrated units and y by " + yAmount + " calibrated units\n")
}

void EMChangeCalibratedFocus( Number amount ){
	result("Focus changed by " + amount + " calibrated units\n")
}

void EMChangeCalibratedImageShift( Number xAmount, Number yAmount ){
	result("Image Shift x by " + xAmount + " calibrated units and y by " + yAmount + " calibrated units\n")
}

void EMChangeCalibratedObjectiveStigmation( Number xAmount, Number yAmount ){
	result("Objective stigmator shifted X/Y by " + xAmount + " and " +yAmount + " calibrated units, respectively\n")
}

void EMChangeCondensorStigmation( Number xAmount, Number yAmount ){
	result("Condensor stigmator shifted X/Y by " + xAmount + " and " +yAmount + " raw units, respectively\n")
}

void EMChangeFocus( Number amount ){
	result("Focus changed by " + amount + " raw units\n")
}

void EMChangeImageShift( Number xAmount, Number yAmount ){
	result("Image Shift x by " + xAmount + " raw units and y by " + yAmount + " raw units\n")
}

void EMChangeObjectiveStigmation( Number xAmount, Number yAmount ){
	result("Objective stigmator shifted X/Y by " + xAmount + " and " +yAmount + " raw units, respectively\n")
}

void EMGetBeamShift( Number &shiftX, Number &shiftY){
	shiftX = 100
	shiftY = 100
	result("Beam Shift acquired in raw units\n")
}

void EMGetBeamTilt( Number &shiftX, Number &shiftY ){
	shiftX = 100
	shiftY = 100
	result("Beam Tilt acquired in raw units\n")
}

Number EMGetBrightness(){
	result("Brightness acquired in raw units\n")
	return 10
}

void EMGetCalibratedBeamShift( Number &shiftX, Number &shiftY ){
	shiftX = 150
	shiftY = 150
	result("Beam Shift acquired in calibrated units\n")
}

void EMGetCalibratedBeamTilt( Number &tiltX, Number &tiltY ){
	tiltX = 150
	tiltY = 150
	result("Beam Tilt acquired in calibrated units\n")
}

Number EMGetCalibratedCameraLength( String deviceLocation, TagGroup stateInfo, Number &calCL, Number matchOptions ){
	result("Getting " + deviceLocation + "'s Camera Length with calibrated units\n")
	calCL = 100
	return calCL
}

Number EMGetCalibratedFieldOfView( String deviceLocation, TagGroup stateInfo, Number &calFOV, Number matchOptions ){
	result("Getting " + deviceLocation + "'s Field of View with calibrated units\n")
	calFOV = 100
	return calFOV
}

Number EMGetCalibratedFocus( ){
	result("Getting Focus in calibrated units\n")
	return 50
}

void EMGetCalibratedImageShift( Number &shiftX, Number &shiftY ){
	shiftX = 150
	shiftY = 150
	result("Image Shift acquired in calibrated units\n")
}

Number EMGetCalibratedMag( String deviceLocation, TagGroup stateInfo, Number &calMag, Number matchOptions ){
	result("Getting " + deviceLocation + "'s Magnification with calibrated units\n")
	calMag = 100
	return calMag
}

void EMGetCalibratedObjectiveStigmation( Number &stigX, Number &stigY ){
	stigX = 150
	stigY = 150
	result("Objective Stigmation acquired in calibrated units\n")
}

TagGroup EMGetCalibrationStateTags(){
	TagGroup dummy
	result("State Tags TagGroup acquired!")
	return dummy
}

Number EMGetCameraLength(){
	result("Camera Length aquired in raw units\n")
	return 50
}

void EMGetCondensorStigmation( Number &stigX, Number &stigY ){
	stigX = 100
	stigY = 100
	result("Condensor Stigmation acquired in raw units\n")
}

Number EMGetFocus(){
	result("Focus acquired in raw units\n")
	return 50
}

Number EMGetHighTension(){
	result("Voltage acquired in volts\n")
	return 50
}

String EMGetIlluminationMode(){
	result("Illumination mode acquired\n")
	return "Illum. Mode"
}

TagGroup EMGetIlluminationModes(){
	result("Illumination modes acquired\n")
	TagGroup dummy
	return dummy
}

void EMGetImageShift( Number &shiftX, Number &shiftY ){
	shiftX = 300
	shiftY = 300
	result("Image Shift acquired in raw units\n")
}

String EMGetImagingOpticsMode( ){
	result("Imaging Optics mode acquired\n")
	return "Optics mode"
}

TagGroup EMGetImagingOpticsModes(){
	result("Imaging Optics modes acquired\n")
	TagGroup dummy
	return dummy
}

Number EMGetMagIndex( ){
	result("Magnification index acquired\n")
	return 5
}

Number EMGetMagnification( ){
	result("Magnification acquired in raw units\n")
	return 5
}

String EMGetMicroscopeName(){
	result("Microscope name acquired\n")
	return "MICROSCOPE NAME"
}

void EMGetObjectiveStigmation( Number &stigX, Number &stigY ){
	stigX = 150
	stigY = 150
	result("Objective Stigmation acquired in raw units\n")
}

String EMGetOperationMode(){
	result("Operation Mode acquired\n")
	return "OPERATION MODE"
}

Number EMGetScreenPosition(){
	result("Screen Index found\n")
	return 1
}

Number EMGetSpotSize(){
	result("Spot Size Index found\n")
	return 2
}

Number EMGetStageAlpha(){
	result("Stage Alpha acquired in degrees\n")
	return 0
}

Number EMGetStageBeta(){
	result("Stage Beta acquired in degrees\n")
	return 0
}

void EMGetStagePositions(Number axisFlags, Number &x, Number &y, Number &z, Number &a, Number &b){
	if(axisFlags >= 16){
		result("Stage Beta acquired in degrees\n")
		b = 20
		axisFlags = axisFlags-16
		}
	if(axisFlags >= 8){
		result("Stage Alpha acquired in degrees\n")
		a = 10
		axisFlags = axisFlags-8
		}
	if(axisFlags >= 4){
		result("Stage Z acquired in microns\n")
		z = 0
		axisFlags = axisFlags-4
		}
	if(axisFlags >= 2){
		result("Stage Y acquired in microns\n")
		y = 100
		axisFlags = axisFlags-2
		}
	if(axisFlags >= 1){
		result("Stage X acquired in microns\n")
		x = 75
		axisFlags = axisFlags-1
		}
	return 0
}

void EMGetStageXY(Number &x, Number &y){
	result("Stage X/Y acquired in microns\n")
	x = 60
	y = 60
}

number EMGetStageX(){
	result("Stage X acquired in microns\n")
	return 60
}

number EMGetStageY(){
	result("Stage Y acquired in microns\n")
	return 60
}

number EMGetStageZ(){
	result("Stage Z acquired in microns\n")
	return 60
}

Number EMIsReady(){
	result("Microscope is ready\n")
	return 1
}

void EMSetBeamShift( Number shiftX, Number shiftY ){
	result("Beam Shift X/Y set to "+shiftX+" and "+shiftY +" raw units, respectively\n")
}
	
void EMSetBeamTilt( Number tiltX, Number tiltY ){
	result("Beam tilt X/Y set to "+tiltX+" and "+tiltY +" raw units, respectively\n")
}

void EMSetBrightness( Number brightness ){
	result("Brightness set to " + brightness +" in raw units\n")
}

void EMSetCalibratedBeamShift( Number shiftX, Number shiftY ){
	result("Beam Shift X/Y set to "+shiftX+" and "+shiftY +" calibrated units, respectively\n")
}

void EMSetCalibratedBeamTilt( Number tiltX, Number tiltY ){
	result("Beam tilt X/Y set to "+tiltX+" and "+tiltY +" calibrated units, respectively\n")
}

Number EMSetCalibratedFocus(Number focus){
	result("Focus set at " + focus +" calibrated units\n")
	return 0
}

void EMSetCalibratedImageShift( Number shiftX, Number shiftY ){
	result("Image Shift X/Y set to "+shiftX+" and "+shiftY +" calibrated units, respectively\n")
}

void EMSetCalibratedObjectiveStigmation( Number stigX, Number stigY ){
	result("Objective lens Stigmation X/Y set to "+stigX+" and "+stigY +" calibrated units, respectively\n")
}

void EMSetCondensorStigmation( Number stigX, Number stigY ){
	result("Condensor lens stigmation X/Y set to "+stigX+" and "+stigY +" raw units, respectively\n")
}

Number EMSetFocus(Number focus){
	result("Focus set at " + focus +" raw units\n")
	return 0
}

void EMSetImageShift( Number shiftX, Number shiftY ){
	result("Image Shift X/Y set to "+shiftX+" and "+shiftY +" raw units, respectively\n")
}

void EMSetMagIndex(Number index){
	result("Mag index set at " + index+"\n")
}

void EMSetObjectiveStigmation( Number stigX, Number stigY ){
	result("Objective lens Stigmation X/Y set to "+stigX+" and "+stigY +" raw units, respectively\n")
}

void EMSetScreenPosition(number pos){
	result("Screen Position set at " + pos + "\n")
}

void EMSetSpotSize(number spotSize){
	result("Spot Size set at " + spotSize + "\n")
}

void EMSetStageAlpha(Number a){
	result("Stage Alpha set " + a + " in degrees\n")
}

void EMSetStageBeta(Number b){
	result("Stage Beta set " + b + " in degrees\n")
}

void EMSetStagePositions(Number axisFlags, Number x, Number y, Number z, Number a, Number b){
	if(axisFlags >= 16){
		result("Stage Beta set " + b + " in degrees\n")
		axisFlags = axisFlags-16
		}
	if(axisFlags >= 8){
		result("Stage Alpha set " + b + " in degrees\n")
		axisFlags = axisFlags-8
		}
	if(axisFlags >= 4){
		result("Stage Z set " + z + " in microns\n")
		axisFlags = axisFlags-4
		}
	if(axisFlags >= 2){
		result("Stage Y set " + y + " in microns\n")
		axisFlags = axisFlags-2
		}
	if(axisFlags >= 1){
		result("Stage X set " + x + " in microns\n")
		axisFlags = axisFlags-1
		}
}

void EMSetStageXY(Number x, Number y){
	result("Stage X set " + x + " in microns\n")
	result("Stage Y set " + y + " in microns\n")
}

void EMSetStageX(Number x){
	result("Stage X set " + x + " in microns\n")
}

void EMSetStageY(Number y){
	result("Stage Y set " + y + " in microns\n")
}

void EMSetStageZ(Number z){
	result("Stage Z set " + z + " in microns\n")
}

void EMUpdateCalibrationState(){
	result("Calibration state updated\n")
}

void EMWaitUntilReady(){
	result("Waiting until ready...\n")
}