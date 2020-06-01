//New File for Condensing Load and Acquire model functions


//-----SUB FUNCTION-----//
number openFile(object &given, string file_name){
	result("Opening " + file_name + "\n")
	string directory
	DLGgetValue(given.lookupelement("SavePathField"),directory)
	number file
	string temporary_Line

	if(DoesFileExist(file_name))
	{
		file = OpenFileforReading(file_name)
		return file
	}
	else
	{
		okdialog("File not found! Make sure Python loaded correctly")
		return -1;
	}
	
}

//EFFECTS: Use EMFunctions to generate accurate Coordinates
//NOTE   : Call this during a saved_to_tilt_image command for user's benefit
void RefreshFunction_past(object given){
	number imagex,imagey,imagez,alpha,beta,df
	//EMGetStagePositions(31,imagex,imagey,imagez,alpha,beta)
	//df = EMGetCalibratedFocus/1000
	dlgvalue(given.lookupelement("pastX"),imagex)
	dlgvalue(given.lookupelement("pastY"),imagey)
	dlgvalue(given.lookupelement("pastZ"),imagez)
	dlgvalue(given.lookupelement("pastDF"),df)
	dlgvalue(given.lookupelement("pastTilt"),alpha)
}

//EFFECTS: Use EMFunctions to generate accurate Coordinates
//NOTE   : Call this during basically any interaction; ensures user is seeing most relevant information
void RefreshFunction_curr(object given){
	number imagex,imagey,imagez,alpha,beta,df
	//EMGetStagePositions(31,imagex,imagey,imagez,alpha,beta)
	//df = EMGetCalibratedFocus/1000
	dlgvalue(given.lookupelement("currX"),imagex)
	dlgvalue(given.lookupelement("currY"),imagey)
	dlgvalue(given.lookupelement("currZ"),imagez)
	dlgvalue(given.lookupelement("currDF"),df)
	dlgvalue(given.lookupelement("currTilt"),alpha)
}

//EFFECTS: Use *A,*B,*C,*D to calculate next model position
//NOTES  : Call during every TILT command to ensure model is reading correct modern tilt
void RefreshFunction_next(object given, number setting, number xA,number xB, number xC, number xD,number yA, number yB, number yC, number yD,number zA, number zB, number zC, number zD,number dfA, number dfB, number dfC, number dfD){
	number alpha
	//alpha = EMGetStageAlpha()
	alpha = alpha*Pi()/180 //Convert to radians for DMScript math
	if(setting == 1){
		
		//number nextAngle = (alpha + DLGGetValue(given.lookupelement("deltatiltfield")))*Pi()/180
		dlgvalue(given.lookupelement("nextX"), alpha*xA+xB)
		dlgvalue(given.lookupelement("nextY"), alpha*yA+yB)
		dlgValue(given.lookupelement("nextZ"), alpha*zA+zB)
		dlgValue(given.lookupelement("nextDF"), alpha*dfA+dfB)
	}
	else if(setting == 0){
		//number nextAngle = (alpha + DLGGetValue(given.lookupelement("deltatiltfield")))*Pi()/180
		dlgvalue(given.lookupelement("nextX"), xA*cos(alpha*xB+xC)+xD)
		dlgvalue(given.lookupelement("nextY"), yA*cos(alpha*yB+yC)+yD)
		dlgValue(given.lookupelement("nextZ"), zA*cos(alpha*zB+zC)+zD)
		dlgValue(given.lookupelement("nextDF"), dfA*cos(alpha*dfB+dfC)+dfD)
	}
}
//------MAIN FUNCTION-----//


//REQUIRES: Valid file_name
//MODIFIES: *A,*B
//EFFECTS : Loads file_name.txt and scrapes coefficient information
//		  : Further updates curr  and new values
//NOTES   : Uses *=(theta)A+B
void LoadFunction_linear(object &given,string file_name, number &xA,number &xB, number &yA, number &yB, number &zA, number &zB,number &dfA,number &dfB){
	number imagex,imagey,imagez,alpha,beta
	number file = openFile(given,file_name)
	String temporary
	if(file == -1){
		okdialog(file_name + "\n cannot be opened!\nModel coefficients not updated.")
		return
	}
	object myStream = newStreamFromFileReference(file,0)
	myStream.StreamReadTextLine(0,temporary)
	xA = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	xB = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	yA = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	yB = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	zA = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	zB = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	dfA = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	dfB = val(temporary)
	
	RefreshFunction_next(given,0,xA,xB,0,0,yA,yB,0,0,zA,zB,0,0,dfA,dfB,0,0)	
	
	
	closefile(file)
	
}


//REQUIRES: Valid file_name
//MODIFIES: *A,*B,*C
//EFFECTS : Loads file_name.txt and scrapes coefficient information
//		  : Further updates curr and new values
//NOTES   : Uses *=Asin((theta)B+C)
void LoadFunction_sinusoidal(object &given,string file_name, number &xA,number &xB, number &xC, number &xD,number &yA, number &yB, number &yC, number &yD,number &zA, number &zB, number &zC, number &zD,number &dfA, number &dfB, number &dfC, number &dfD){
	number imagex,imagey,imagez,alpha,beta,imageDF
	number file = openFile(given,file_name)
	String temporary
	if(file == -1){
		okdialog(file_name + "\n cannot be opened!\nModel coefficients not updated.")
		return
	}
	object myStream = newStreamFromFileReference(file,0)
	myStream.StreamReadTextLine(0,temporary)
	xA = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	xB = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	xC = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	xD = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	yA = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	yB = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	yC = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	yD = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	zA = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	zB = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	zC = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	zD = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	dfA = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	dfB = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	dfC = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	dfD = val(temporary)
	
	RefreshFunction_next(given,1,xA,xB,xC,xD,yA,yB,yC,yD,zA,zB,zC,zD,dfA,dfB,dfC,dfD)
	
	
	closefile(file)
		
}


