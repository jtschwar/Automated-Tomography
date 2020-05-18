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


//MODIFIES: *A,*B
//EFFECTS : Further updates curr and new values
void RefreshFunction_linear(object &given, number &xA,number &xB, number &yA, number &yB, number &zA, number &zB,number &dfA,number &dfB){
	number pastx, pasty, pastz, pastdf, imagex,imagey,imagez,alpha,beta,imageDF
	
	
	//EMGetStagePositions(27,imagex,imagey,imagez,alpha,beta)
	//imageDF = EMgetcalibratedfocus()/1000
	
	//UPDATE past VALUES
	dlggetvalue(given.lookupelement("currX"),pastx)
	dlggetvalue(given.lookupelement("currY"),pasty)
	dlggetvalue(given.lookupelement("currZ"),pastz)
	dlggetvalue(given.lookupelement("currDF"),pastdf)
	dlgvalue(given.lookupelement("pastX"),pastX)
	dlgvalue(given.lookupelement("pastY"),pasty)
	dlgvalue(given.lookupelement("pastZ"),pastz)
	dlgvalue(given.lookupelement("pastDF"),pastdf)
	
	//UPDATE curr VALUES
	dlgvalue(given.lookupelement("currX"), imagex)
	dlgvalue(given.lookupelement("currY"), imagey)
	dlgvalue(given.lookupelement("currZ"), imagez)
	dlgValue(given.lookupelement("currenttiltfield"), alpha)
	dlgValue(given.lookupelement("currDF"), imageDF)
	
	//UPDATE new VALUES
	number nextAngle = (alpha + DLGGetValue(given.lookupelement("deltatiltfield")))*Pi()/180
	dlgvalue(given.lookupelement("nextX"), nextAngle*xA+xB)
	dlgvalue(given.lookupelement("nextY"), nextAngle*yA+yB)
	dlgValue(given.lookupelement("nextZ"), nextAngle*zA+zB)
	dlgValue(given.lookupelement("nextDF"), nextAngle*dfA+dfB)

}

//MODIFIES: *A,*B,*C
//EFFECTS : Further updates curr and new values
//NOTES   : Uses *=Asin((theta)B+C)
void RefreshFunction_sinusoidal(object &given, number &xA,number &xB, number &xC, number &xD,number &yA, number &yB, number &yC, number &yD,number &zA, number &zB, number &zC, number &zD,number &dfA, number &dfB, number &dfC, number &dfD){
	number pastx, pasty, pastz, pastdf, imagex,imagey,imagez,alpha,beta,imageDF
	//UPDATE past VALUES
	dlggetvalue(given.lookupelement("currX"),pastx)
	dlggetvalue(given.lookupelement("currY"),pasty)
	dlggetvalue(given.lookupelement("currZ"),pastz)
	dlggetvalue(given.lookupelement("currDF"),pastdf)
	dlgvalue(given.lookupelement("pastX"),pastX)
	dlgvalue(given.lookupelement("pastY"),pasty)
	dlgvalue(given.lookupelement("pastZ"),pastz)
	dlgvalue(given.lookupelement("pastDF"),pastdf)
	
	
	//UPDATE curr VALUES
	//EMGetStagePositions(27,imagex,imagey,imagez,alpha,beta)
	//imageDF = EMgetcalibratedfocus()/1000
	dlgvalue(given.lookupelement("currX"), imagex)
	dlgvalue(given.lookupelement("currY"), imagey)
	dlgvalue(given.lookupelement("currZ"), imagez)
	dlgvalue(given.lookupelement("currDF"), imageDF)
	dlgValue(given.lookupelement("currenttiltfield"), alpha)
	
	
	//UPDATE new VALUES
	number nextAngle = (alpha + DLGGetValue(given.lookupelement("deltatiltfield")))*Pi()/180
	dlgvalue(given.lookupelement("nextX"), xA * cos(yB*nextAngle+xC)+xD)
	dlgvalue(given.lookupelement("nextY"), yA * cos(yB*nextAngle + yC)+yD)
	dlgValue(given.lookupelement("nextZ"), zA * cos(zB*nextAngle + zC)+zD)
	dlgValue(given.lookupelement("nextDF"), dfA * cos(dfB*nextAngle + dfC)+dfD)
		
}

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
	
	RefreshFunction_linear(given,xA,xB,yA,yB,zA,zB,dfA,dfB)	
	
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
	
	RefreshFunction_sinusoidal(given,xA,xB,xC,xD,yA,yB,yC,yD,zA,zB,zC,zD,dfA,dfB,dfC,dfD)
	
	closefile(file)
		

	
}

