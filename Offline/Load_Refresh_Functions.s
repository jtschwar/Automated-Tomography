//New File for Condensing Load and Acquire model functions


//-----SUB FUNCTION-----//

number openFile(object &given, string file_name){
	string directory
	DLGgetValue(given.lookupelement("SavePathField"),directory)
	number file
	string temporary_Line

	string full_path = directory+file_name
	if(DoesFileExist(full_path))
	{
		file = OpenFileforReading(full_path)
		
	}
	else
	{
		okdialog("File not found! Make sure Python loaded correctly")
		return -1;
	}
	
}

//------MAIN FUNCTION-----//

//REQUIRES: Valid file_name
//MODIFIES: *A,*B
//EFFECTS : Loads file_name.txt and scrapes coefficient information
//		  : Further updates curr  and new values
//NOTES   : Uses *=(theta)A+B
void LoadFunction_linear(object &given,string file_name, number &xA,number &xB, number &yA, number &yB, number &zA, number &zB){
	number imagex,imagey,imagez,alpha,beta
	number file = openFile(given,file_name)
	String temporary
	if(file == -1){
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
	
	//UPDATE curr VALUES
	//EMGetStagePositions(27,imagex,imagey,imagez,alpha,beta)
	dlgvalue(given.lookupelement("currX"), imagex)
	dlgvalue(given.lookupelement("currY"), imagey)
	dlgvalue(given.lookupelement("currZ"), imagez)
	dlgValue(given.lookupelement("currenttiltfield"), alpha)
	
	
	//UPDATE new VALUES
	number nextAngle = (alpha + DLGGetValue(given.lookupelement("deltatiltfield")))*Pi()/180
	dlgvalue(given.lookupelement("nextX"), nextAngle*xA+xB)
	dlgvalue(given.lookupelement("nextY"), nextAngle*yA+yB)
	dlgValue(given.lookupelement("nextZ"), nextAngle*zA+zB)
		
	
	closefile(file)
	
}

//MODIFIES: *A,*B
//EFFECTS : Further updates curr and new values
void RefreshFunction_linear(object &given, number &xA,number &xB, number &yA, number &yB, number &zA, number &zB){
	number imagex,imagey,imagez,alpha,beta
	
	
	//EMGetStagePositions(27,imagex,imagey,imagez,alpha,beta)
	//UPDATE curr VALUES
	dlgvalue(given.lookupelement("currX"), imagex)
	dlgvalue(given.lookupelement("currY"), imagey)
	dlgvalue(given.lookupelement("currZ"), imagez)
	dlgValue(given.lookupelement("currenttiltfield"), alpha)
	
	
	//UPDATE new VALUES
	number nextAngle = (alpha + DLGGetValue(given.lookupelement("deltatiltfield")))*Pi()/180
	dlgvalue(given.lookupelement("nextX"), nextAngle*xA+xB)
	dlgvalue(given.lookupelement("nextY"), nextAngle*yA+yB)
	dlgValue(given.lookupelement("nextZ"), nextAngle*zA+zB)

}

//REQUIRES: Valid file_name
//MODIFIES: *A,*B,*C
//EFFECTS : Loads file_name.txt and scrapes coefficient information
//		  : Further updates curr and new values
//NOTES   : Uses *=Asin((theta)B+C)
void LoadFunction_sinusoidal(object &given,string file_name, number &xA,number &xB, number &xC, number &yA, number &yB, number &yC, number &zA, number &zB, number &zC){
	number imagex,imagey,imagez,alpha,beta
	number file = openFile(given,file_name)
	String temporary
	if(file == -1){
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
	yA = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	yB = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	yC = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	zA = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	zB = val(temporary)
	myStream.StreamReadTextLine(0,temporary)
	zC = val(temporary)
	
	//UPDATE curr VALUES
	//EMGetStagePositions(27,imagex,imagey,imagez,alpha,beta)
	//imagez = EMgetcalibratedfocus()/1000
	dlgvalue(given.lookupelement("currX"), imagex)
	dlgvalue(given.lookupelement("currY"), imagey)
	dlgvalue(given.lookupelement("currZ"), imagez)
	dlgValue(given.lookupelement("currenttiltfield"), alpha)
	
	
	//UPDATE new VALUES
	number nextAngle = (alpha + DLGGetValue(given.lookupelement("deltatiltfield")))*Pi()/180
	dlgvalue(given.lookupelement("nextX"), imageX)
	dlgvalue(given.lookupelement("nextY"), yA * cos(yB*nextAngle + yC))
	dlgValue(given.lookupelement("nextZ"), zA * sin(zB*nextAngle + zC))
		

	
}

//MODIFIES: *A,*B,*C
//EFFECTS : Further updates curr and new values
//NOTES   : Uses *=Asin((theta)B+C)
void RefreshFunction_sinusoidal(object &given, number &xA,number &xB, number &xC, number &yA, number &yB, number &yC, number &zA, number &zB, number &zC){
	number imagex,imagey,imagez,alpha,beta
	//UPDATE curr VALUES
	//EMGetStagePositions(27,imagex,imagey,imagez,alpha,beta)
	//imagez = EMgetcalibratedfocus()/1000
	dlgvalue(given.lookupelement("currX"), imagex)
	dlgvalue(given.lookupelement("currY"), imagey)
	dlgvalue(given.lookupelement("currZ"), imagez)
	dlgValue(given.lookupelement("currenttiltfield"), alpha)
	
	
	//UPDATE new VALUES
	number nextAngle = (alpha + DLGGetValue(given.lookupelement("deltatiltfield")))*Pi()/180
	dlgvalue(given.lookupelement("nextX"), imageX)
	dlgvalue(given.lookupelement("nextY"), yA * cos(yB*nextAngle + yC))
	dlgValue(given.lookupelement("nextZ"), zA * sin(zB*nextAngle + zC))
		
}