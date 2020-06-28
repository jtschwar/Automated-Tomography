// Combining ALL necessary Scripts
// Order: NSSaveDialog, NSImageAcquisition, Load_Refresh_Functions, Filtering_Functions

//Creation and Return of TagGroup for Noah Schnitzer's Save Dialog
//Adapted by Jacob Pietryga

//HOW TO USE
//Use MakeSaveDialog to create Dialogs, then create button functions that call SetPathFunction(self), SaveFunction(self)
//under respective button options

//Organization
//Sub Functions: FindNextKeyFrame, getDate, getTime
//Main Functions: SetPath, MakeSaveDialog, Save


//SUB FUNCTIONS
//REQUIRES: Properly formatted string input
//EFFECTS : Using % as a delimiter, look for next instance of naming variable (Ex) D, K, T, etc.
string FindNextKeyName(string input, number & searchPos )
    {
        number totalLength = len( input )
        number start = 0, end = 0
        while( searchPos < totalLength )
        {
            searchpos++
            if ( "%" == input.mid(searchpos-1,1) )
            {
                if ( !start ) 
                    start = searchpos-1
                else
                    {
                    end = searchpos-1
                    return input.mid(start+1,end-start-1)
                    }
            }
        }
        return ""

    }
//EFFECTS : Retrieves Year, month, day as known by the computer and returns it
String getDate()
    {
        string dateTime = DateStamp()
        string dateMDY = dateTime.left(dateTime.find(" "))
        //year is always 4 characters
        //month and day can be 1 or 2
        number monthDelim = dateMDY.find("/")
        string month,day,year
        if(monthDelim==1)
            month = "0"+dateMDY.left(monthDelim)
        else
            month = dateMDY.left(monthDelim)
        if(dateMDY.len() - monthDelim - 6==1)
            day = "0"+dateMDY.mid(monthDelim+1,dateMDY.len()-6-monthDelim)
        else
            day = dateMDY.mid(monthDelim+1,dateMDY.len()-6-monthDelim)
        year = dateMDY.right(4)
        
        string time = dateTime.right(dateTime.len()-dateTime.find(" ")-1)
        string ampm = time.right(time.len()-time.find(" ")-1)
        string hour = time.left(time.find(":"))
        string min = time.right(time.len()-time.find(":")-1)
        min = min.left(min.find(":"))
        if(ampm=="AM")
        {
            if(hour.val()==12)
                hour = "00"//result("00")
            else
                hour = "0"+hour
        }
        else
        {
            if(hour != "12")
            hour = 12+hour.val() +""
        }
        return year+month+day;
    }
    
    //EFFECTS : Retrieves current time as known by computer  and returns it
String getTime()
    {
        string dateTime = DateStamp()
        string dateMDY = dateTime.left(dateTime.find(" "))
        //year is always 4 characters
        //month and day can be 1 or 2
        number monthDelim = dateMDY.find("/")
        string month,day,year
        if(monthDelim==1)
            month = "0"+dateMDY.left(monthDelim)
        else
            month = dateMDY.left(monthDelim)
        if(dateMDY.len() - monthDelim - 6==1)
            day = "0"+dateMDY.mid(monthDelim+1,dateMDY.len()-6-monthDelim)
        else
            day = dateMDY.mid(monthDelim+1,dateMDY.len()-6-monthDelim)
        year = dateMDY.right(4)
        
        string time = dateTime.right(dateTime.len()-dateTime.find(" ")-1)
        string ampm = time.right(time.len()-time.find(" ")-1)
        string hour = time.left(time.find(":"))
        string min = time.right(time.len()-time.find(":")-1)
        min = min.left(min.find(":"))
        if(ampm=="AM")
        {
            if(hour.val()==12)
                hour = "00"//result("00")
            else if(hour.val()<10)
                hour = "0"+hour
        }
        else
        {
            if(hour != "12")
            hour = 12+hour.val() +""
        }

        return hour+min;
    }



//MAIN FUNCTIONS: Not sure how "object self" will transfer 

//MODIFIES: Savepath field
//EFFECTS : Modifies SavePathField to be to chosen directory
void SetPathFunction(object given)
    {
        String current_path;
    
        if(SaveAsDialog("Save As","Navigate to the correct directory then press save",current_path))
        {

            DLGValue(given.lookupelement("SavePathField"),pathExtractDirectory(current_path, 2));

        }
    }

//EFFECTS: Save as a Gatan type file the front most image in given SavePathDirection with Name
//NOTES  : Pay Close attention to Dialog names in the future
//		     as program will crash randomly if no matches found
void SaveFunction(object given, number fieldNo)
    {

        String save_path = ""
        dlggetvalue(given.lookupelement("SavePathField"), save_path);
        if(save_path == "[NO PATH]")
        {
            okdialog("Must select path before imaging")
            return;
        }
        String save_string = ""
        dlggetvalue(given.lookupelement("SaveStringField"),save_string);
        save_string = " "+save_string
        number pos = 0;
        String substituted_string = "$"

        while(pos < len(save_string))
        {
            
            number oldPos = pos;
            String next_key = findnextkeyname( save_string, pos );
            String added = "";
			// result(next_key+"\n")

            //D,Date; T,Time; V, Voltage; M, mag; L, length; o, Mode; R, Brightness; S spot; A alpha; B beta


            if(next_key=="D")//Date
            {
				//added = "[date]"
                added = getDate();
            }
            else if(next_key=="T")//Time
            {
				//added = "[time]"
                added = getTime();

            }
            else if(next_key=="V")//Voltage
            {
                //added = "[voltage]"
                added = ""+EMGetHighTension( );
            }
            else if(next_key=="M")//Mag
            {
				//added = "[mag]"
                added = ""+EMGetMagnification( );

            }
            else if(next_key=="L")//cam len
            {
				//added = "[length]"
                added = ""+EMGetCameraLength();

            }
            else if(next_key=="O")//operation mode
            {
				//added = "[Operation]"
               added = ""+EMGetOperationMode( );

            }
            else if(next_key=="R")//Brightness
            {
				//added = "[brightness]"
                added = ""+EMGetBrightness();

            }
            else if(next_key=="S")
            {
				//added = "[spot]"
                added=""+EMGetSpotSize( );
            }
            else if(next_key=="A")
            {
				//added = "[alpha]"
               added=""+EMGetStageAlpha( );
            }
            else if(next_key=="B")
            {
				added = "[beta]"
                //added = ""+EMGetStageBeta();
            }
            else if(next_key=="X")
            {
				added = "[X]"
                //added=""+EMGetStageX();
            }
            else if(next_key=="Y")
            {
				added = "[Y]"
                //added=""+EMGetStageY();
            }
            else if(next_key=="Z")
            {
				added = "[Z]"
                //added=""+EMGetStageZ();
            }
            else if(next_key != "")
            {
                okdialog("Invalid parameter: %"+next_key+"% at position "+pos);
                return;

            }
            else
            {
                //fixing end of string artifact by giving back 3 characters...
                pos+=3;
                result("end["+next_key+"]");
            }
			
            substituted_string = substituted_string + save_string.mid(oldPos,pos-oldPos-3)+added;
            
        }
        
        
		Image curr := findImageByName("Current")
		if(!ImageIsValid(curr)){
			okdialog("Current image not found!")
			return
		}

        substituted_string = substituted_string.right(len(substituted_string)-2)
        setname(curr,substituted_string)
		SaveAsGatan(curr,save_path+substituted_string)

        okdialog("Saved as: \n"+substituted_string+"\n")
    }
   
   //EFFECTS: Make Save Path Dialog
TagGroup MakeSaveDialog()
    {
        taggroup box1_items
        taggroup box1=dlgcreatebox("Save Path", box1_items)
        TagGroup label1 = DLGCreateLabel("   Saving to:   ");
        TagGroup savePathField = dlgCreateStringField("[NO PATH]",20).dlgidentifier("SavePathField");
        //will need to pull date from image metadata
        //TagGroup saveStrLabel = DLGCreateLabel("Saving as:\n[YYYY_MM_DD_HHMM]_[Voltage]_[Mag]_[CamLen]_[comment]");
                    //D,Date; T,Time; V, Voltage; M, mag; L, length; o, Mode; R, Brightness; S spot; A alpha; B beta
 
        TagGroup ExpressionsLabel = DLGCreateLabel("%D%=Date, %T%=Time, %V%=Voltage, %M%=Mag, %L% = Camera Length, \n %O%=Mode, %R% = Brightness, %S% = Spot, %A%= Alpha, %B% = Beta, \n %X%= x, %Y% = y, %Z% = z");
        TagGroup setSave = DLGCreatePushButton("Set", "SetPath")
        
        TagGroup SaveTable = DLGGroupItems(savePathField,setSave)
        SaveTable.dlgtablelayout(2,1,0)
        
        TagGroup SaveStringLabel = DLGCreateLabel("Save String:")
        TagGroup SaveStringField = DLGCreateStringField("%A%degrees_%X%um_%Y%um_%Z%um_%M%X_%L%cm_",80).dlgidentifier("SaveStringField");
        TagGroup SaveButton = DLGCreatePushButton("Save Front Image","SaveFunction")
        
        TagGroup SaveStringTable = DLGGroupItems(SaveStringLabel, SaveStringField, SaveButton)
        SaveStringTable.DLGTableLayout(2,1,0)



        TagGroup SaveStringLabel2 = DLGCreateLabel("Save String:")
        TagGroup SaveSTringField2 = dlgCreateStringField("Second",80).dlgidentifier("SaveStringField2")
        TagGroup SaveButton2 = DLGCreatePushButton("Save Front Image", "Save2")
        //TagGroup SaveStringTable2 = DLGGroupItems()

        box1.dlgexternalpadding(0,10)

        box1_items.dlgaddelement(label1)
        box1_items.dlgAddElement(SaveTable)
        box1_items.dlgAddElement(ExpressionsLabel)
        box1_items.dlgAddElement(SaveStringTable)
        
        
        
        
        return box1
    }

/*----------------------------------------------------------*/

//Inspired by Noah Schnitzer's AcqInterface code, should allow 
//for definition of image#, dwelltime, dimension and be installable
//NEEDED: NSSaveDialog
//and usable via simple procedure
//By Jacob Pietryga 23 July 2019

//SUB FUNCTIONS
//MODIFIES: 'Cycler' images
//EFFECTS : Gets rid of old 'Cycler'
//			'Cycler' becomes the most recently found 'stack'
//NOTES   : It is important to have saved the acquired images prior if they are desired
void cycle(string Cycler){
	image img1,img2
	img1 := FindImageByName(Cycler)
	if(ImageIsValid(img1)){
		deleteimage(img1)
	}
	img2 := FindImageByName("stack")
	SetName(img2,Cycler)	
}

number error_badValues(object given){
	number detectChecks = 0
	number signalIndex = 0
	number dataDepth = 4
	number acquire = 1
	number imageID = 0
	number cDim
	DLGGetValue(given.lookupelement("dimField"), cDim)
	number cDwellT 
	DLGGetValue(given.lookupelement("dwellField"), cDwellT);
	number cImageNum 
	dlgGetValue(given.lookupelement("imageNumfield"), cImageNum)
	
	return (cDwellT < 0 || cImageNum < 0 || cDim < 0)
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
	TagGroup detect3_check = DLGCreateCheckBox("3",0).dlgidentifier("detect3_check")
	TagGroup detect4_check = DLGCreateCheckBox("4",0).dlgidentifier("detect4_check")
	TagGroup detect_check_Total = dlgGroupItems(detect1_check,detect2_check,detect3_check,detect4_check).dlgtablelayout(4,1,0)
	TagGroup detect_region = dlgGroupitems(detect_label, detect_check_Total).dlgtablelayout(3,1,0)
	
	TagGroup Label_column = DLGGroupitems(dwell_label,dim_label,Image_Label,rotation_label).dlgtablelayout(1,4,0)
	TagGroup entry_column = DLGGroupitems(dwellField,DimField,imageNumField,rotationfield).dlgTablelayout(1,4,1)
	TagGroup Values_Region = DLGgroupitems(Label_column,entry_column).DLGtablelayout(2,1,0)
	Acq_items.DLGAddElement(DLGgroupitems(values_Region, detect_region).DLGtablelayout(1,2,0))
	
	return Acq_box
}

//REQUIRES: Approrpiate Imaging Environment OR disabled EM functions
//EFFECTS : Using Acquisition parameters, capture and save image stack to SavePath
//NOTES   : Refer to NSSaveDialog for save functionality
void captureFunction(object given, string Cycler)
{
	
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
	
	number ParamID = DSCreateParameters(cDim,cDim,sRotation,cDwellT,0)
	
	image stack = NewImage("stack",2,cDim,cDim,cImageNum)
	setname(stack,"stack")
	
	
	//result(dlgGetValue(given.lookupelement("detect1_check")))
	//result(dlgGetValue(given.lookupelement("detect2_check")))
	if(dlgGetValue(given.lookupelement("detect1_check")))
	{
		detectChecks += 1
		
		DSSetParametersSignal(paramID,0,dataDepth,acquire,imageID)
	}
	if(dlgGetValue(given.lookupelement("detect2_check")))
	{	
		detectChecks += 1
		DSSetParametersSignal(paramID,1,dataDepth,acquire,imageID)
	}
	if(dlgGetValue(given.lookupelement("detect3_check")))
	{	
		detectChecks += 1
		DSSetParametersSignal(paramID,2,dataDepth,acquire,imageID)
	}
	if(dlgGetValue(given.lookupelement("detect4_check")))
	{	
		detectChecks += 1
		DSSetParametersSignal(paramID,3,dataDepth,acquire,imageID)
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
	if(error_badValues(given)){
		okdialog("Bad values in Settings")
		return;
	}
	number i
	for (i = 0; i < cImageNum; i++)
	{
		DSStartAcquisition(paramID,0,1)
		image curr:= getFrontImage()
		stack[0,0,i,cDim,CDim,i+1]=curr
		DeleteImage(curr)
	}
	ShowImage(stack)
	cycle(Cycler)
	result("Capture Complete!\n")
}


/*-------------------------------------------------------*/

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
		result("[WARNING] Python Output File not found! Make sure Python loaded correctly\n")
		return -1;
	}
	
}

//EFFECTS: Use EMFunctions to generate accurate Coordinates
//NOTE   : Call this during a saved_to_tilt_image command for user's benefit
void RefreshFunction_past(object given){
	number imagex,imagey,imagez,alpha,beta,df
	EMGetStagePositions(15,imagex,imagey,imagez,alpha,beta)
	df = EMGetFocus()*10000
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
	EMGetStagePositions(15,imagex,imagey,imagez,alpha,beta)
	df = EMGetFocus()/10000
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
	alpha = EMGetStageAlpha()
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
		result("[WARNING]" + file_name + "\n cannot be opened!\nModel coefficients not updated.\n")
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
		result("[WARNING]" + file_name + "\n cannot be opened!\nModel coefficients not updated.\n")
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


/*-------------------------------------------------------------*/

//FFT Filtering Code

 //SUB FUNCTIONS
// This function carried out the forward FFT. The function used (realFFT()) requires a real image
// so a clone of the passed in image is created and converted to a real image

image forwardfft(realimage frontimage)
	{

		// Get some info on the passed in image
		number xsize, ysize, imagetype
		string imgname=getname(frontimage)
		getsize(frontimage, xsize, ysize)

		// create a complex image of the correct size to store the result of the FFT
		compleximage fftimage=compleximage("",8,xsize, ysize)

		// Clone the passed in image and convert it to type real (required for realFFT())
		image tempimage=imageclone(frontimage)
		converttofloat(tempimage)
		fftimage=realfft(tempimage)	
		deleteimage(tempimage)

		return fftimage
	}



// The Butterworth Filter Function - this creates a filter which can be applied to a FFT
// to exclude the high frequency component - ie remove noise.

image butterworthfilter(number imgsize, number bworthorder, number zeroradius)
	{
		// See John Russ's Image Processing Handbook, 2nd Edn, p 316
		image butterworthimg=realimage("",4,imgsize, imgsize)
		butterworthimg=0

		// note the halfpointconst value sets the value of the filter at the halfway point
		// ie where the radius = zeroradius. A value of 0.414 sets this value to 0.5
		// a value of 1 sets this point to root(2)

		number halfpointconst=0.414
		butterworthimg=1/(1+halfpointconst*(iradius/zeroradius)**(2*bworthorder))
		return butterworthimg
	}

image FFTfiltering(image frontimage, image butterworthimg)
	{
		number xsize, ysize
		getsize(frontimage, xsize, ysize)
		
		// Compute the FFT of passed in image, then mulitply it by the Butterworth filter image
		compleximage fftimage=forwardfft(frontimage)
		compleximage maskedfft=fftimage*butterworthimg
		return maskedfft
	}

//MAIN FUNCTION
image noise_reduction(image img){
	number xsize,ysize
	string name = getname(img)
	img.getsize(xsize,ysize)
	image fftimage = forwardfft(img)
	converttopackedcomplex(fftimage)
	image butterworthimage = butterworthfilter(xsize,3,xsize/5)
	compleximage masked=fftfiltering(img,butterworthimage)
	converttopackedcomplex(masked)
	image invfiltered =packedIFFT(masked)
	setname(invfiltered, "Filtered: " + name)
	showimage(invfiltered)
	return invfiltered
}
