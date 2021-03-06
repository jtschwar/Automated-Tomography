//Creation and Return of TagGroup for Noah Schnitzer's Save Dialog
//Adapted by Jacob Pietryga

//HOW TO USE
//Use MakeSaveDialog to create Dialogs, then create button functions that call SetPathFunction(self), SaveFunction(self)
//under respective button options

//Organization
//Sub Functions: FindNextKeyFrame, getDate, getTime
//Main Functions: SetPath, MakeSaveDialog, Save


//SUB FUNCTIONS
string FindNextKeyName( object self, string input, number & searchPos )
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

void SetPathFunction(object given)
    {
        String current_path;
    
        if(SaveAsDialog("Save As","Navigate to the correct directory then press save",current_path))
        {

            DLGValue(given.lookupelement("SavePathField"),pathExtractDirectory(current_path, 2));

        }
    }

void SaveFunction(object given, number fieldNo)
    {
       	//result("asdf"+field_number)
        String save_path = "";
        dlggetvalue(given.lookupelement("SavePathField"), save_path);
        if(save_path == "[NO PATH]")
        {
            okdialog("Must select path before imaging");
            return;
        }

        String save_string = "";
        dlggetvalue(given.lookupelement("SaveStringField"),save_string);
        save_string = " "+save_string
        //result(""+FindNextKeyName(self, "asdf%m%sdf","%"))
        //result(FindNextKeyName(self,"asdf%r%",0));
        number pos = 0;
        String substituted_string = "$";
        while(pos < len(save_string))
        {
            //result(findnextkeyname(  self, save_string, pos ));
            number oldPos = pos;
            String next_key = findnextkeyname(  given, save_string, pos );
            String added = "";


            //D,Date; T,Time; V, Voltage; M, mag; L, length; o, Mode; R, Brightness; S spot; A alpha; B beta


            if(next_key=="D")//Date
            {
                added = getDate();
            }
            else if(next_key=="T")//Time
            {
                added = getTime();

            }
            else if(next_key=="V")//Voltage
            {
                added = "[voltage]"
                added = ""+EMGetHighTension( )/1000; //kv
            }
            else if(next_key=="M")//Mag
            {
                added = ""+EMGetMagnification( )/1e6; // *1,000,000 (1e6)

            }
            else if(next_key=="L")//cam len
            {
                added = ""+EMGetCameraLength()/10; //cm

            }
            else if(next_key=="O")//operation mode
            {
                added = ""+EMGetIlluminationMode( );

            }
            else if(next_key=="R")//Brightness
            {
                added = ""+EMGetBrightness();

            }
            else if(next_key=="S")
            {
                added=""+EMGetSpotSize( );
            }
            else if(next_key=="A")
            {
                added=""+EMGetStageAlpha( );
            }
            else if(next_key=="B")
            {
                added = ""+EMGetStageBeta();
            }
            else if(next_key=="X")
            {
                added=""+EMGetStageX();
            }
            else if(next_key=="Y")
            {
                added=""+EMGetStageY();
            }
            else if(next_key=="Z")
            {
                added=""+EMGetStageZ();
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
            //result(substituted_string+"\n")
        }

        Image curr:= getFrontImage();


        substituted_string = substituted_string.right(len(substituted_string)-2)
        SaveAsGatan3(curr,save_path+substituted_string)
        DeleteImage(curr)

        okdialog("Saved as: \n"+substituted_string+"\n")
    }
   
TagGroup MakeSaveDialog()
    {
        taggroup box1_items
        taggroup box1=dlgcreatebox("Save Path", box1_items)
        TagGroup label1 = DLGCreateLabel("   Saving to:   ");
        TagGroup savePathField = dlgCreateStringField("[NO PATH]",20).dlgidentifier("SavePathField");
        //will need to pull date from image metadata
        //TagGroup saveStrLabel = DLGCreateLabel("Saving as:\n[YYYY_MM_DD_HHMM]_[Voltage]_[Mag]_[CamLen]_[comment]");
                    //D,Date; T,Time; V, Voltage; M, mag; L, length; o, Mode; R, Brightness; S spot; A alpha; B beta
 
        TagGroup ExpressionsLabel = DLGCreateLabel("%D%=Date, %T%=Time, %V%=Voltage, %M%=Mag, %L% = Length, \n %O%=Mode, %R% = Brightness, %S% = spot, %A%= alpha, %B% = Beta, \n %X%= x, %Y% = y, %Z% = z");
        TagGroup setSave = DLGCreatePushButton("Set", "SetPath")
        
        TagGroup SaveTable = DLGGroupItems(savePathField,setSave)
        SaveTable.dlgtablelayout(2,1,0)
        //Size Voltage SpotSize Alpha Beta
        TagGroup SaveStringLabel = DLGCreateLabel("Save String:")
        TagGroup SaveStringField = DLGCreateStringField("%D%_%T%_%V%kV_%S%_%M%X_%L%cm_%A%alpha",80).dlgidentifier("SaveStringField");
        TagGroup SaveButton = DLGCreatePushButton("Save Front Image","Save")
        
        TagGroup SaveStringTable = DLGGroupItems(SaveStringLabel, SaveStringField, SaveButton)
        SaveStringTable.DLGTableLayout(3,1,0)



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
