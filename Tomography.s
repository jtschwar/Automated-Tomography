//Performs a coarse semi-automated tomography tilt series
//with a GUI to specificy certain parameters such as dwell time, image dimensions, and number of images.
//By Jonathan Schwartz, adapated from programs written by Noah Schnitzer. 

//Globals
taggroup tiltMin, deltaTilt, tiltMax, dimX, dimY, dwellTime, numImages //Should I let the user specify the focus range too??

//Taking actual series of images

void FocalSeries(Number j)
{
 /*
    Acquire Series of images within a range of defocus values. 
 */
}


void AcquireImage()
{
 /*
    Aquire Single Image for Cross-Correlation.
 */
}

void Correlation()
{ 
  /*
     Measure the shift from the previous and current tilt.  
  */
}

void StageMovement(Number sx, Number sy)
{
 /*
   Move the Stage in the x-y direction to track the sample.  
 */
}

void StorePositionShift(Number X, Number Y)
{
 /*
    Store the image shifts.        
 */   
}

void Tilt()
{
    number deltaTheta = dlgGetValue(deltaTilt)
    number currentAngle = EMGetStageAlpha()
    EMSetStageAlpha(currentAngle + thetaDelta)
}


class Dialog : uiframe
{

    void Tomgoraphy(object self, int i) //..PROGRAM BEGINS..
    {
        

        FocalSeries(i)                    //Take Through Focal Image Stack. 
        AquireImage()
        Tilt(thetaDelta)                  //Tilt the stage by thetaDelta. 
        EMWaitUntilReady()                //Wait for a command to be completely executed.             
        AquireImage()           
        Correlation(imgX, imgY)           //Perform a correlation of the image between the previous (X) and current (Y) image. 
        StageMovement(shiftX, shiftY)                   
        EMWaitUntilReady()                //BeamBlankOn
        okdialog("Recenter the stage and record the coordinates (if necessary).")   
        //BeamBlankOff
    }

    void Go(object self) // When the 'Go' button is pressed
    {
        number i, tilts 
        number thetaMin = dlgGetValue(tiltMin)
        number thetaMax = dlgGetValue(tiltMax)
        number deltaTheta = dlgGetValue(deltaTilt)
        
        tilts = (thetaMax - thetaMin)/deltaTheta  
        
        for(i = 0; i <= tilts; i++ )        
        {
            if( shiftDown() && controlDown() && spaceDown() )       //Add a separte "Stop" button instead.   
            {
                OkDialog("Sript aborted")
                self.close()
                Exit(0)
            }
            self.Tomography(i)
        }
    }

}

// This creates a boxed label at the top of the dialog box.
TagGroup MakeLabels()
{
    Taggroup box1_items
    Taggroup box1=dlgcreatebox("", box1_items)
    TagGroup label1 = DLGCreateLabel("\n   Tomography   \n");
    box1.dlgexternalpadding(0,10)
    box1_items.dlgaddelement(label1)
    
    return box1
}


// This creates the Go and Stop buttons in the dialog.
TagGroup MakeButtons()
{
    TagGroup ExecuteButton = DLGCreatePushButton("Go", "Go").DLGSide("Bottom");
    ExecuteButton.dlgexternalpadding(10,10)
    
    return ExecuteButton
}


Taggroup makefields() //Rename all the taggroups variables "taggroup-i"
{
    Taggroup theta_title = dlgcreatelabel("Tilt (Degrees): ").dlganchor("West")
    tiltMin = dlgcreaterealfield(-60.0,10,8).dlganchor("West")
    deltaTilt = dlgcreaterealfield(3.0,10,8).dlganchor("West")
    tiltMax = dlgcreaterealfield(60.0,10,8).dlganchor("West")
    Taggroup group1 = dlggroupitems(theta_title, tilt_min, delta_tilt, tilt_max)
    group1.dlgtablelayout(4,1,0) 

    Taggroup dim_title = dlgcreatelabel("Pixel Dimensions ( x, y ): ").dlganchor("West")
    dimX = dlgcreaterealfield(256,11,8).dlganchor("West")
    dimY = dlgcreaterealfield(256,11,8).dlganchor("West")
    Taggroup group2 = dlggroupitems(dim_title, dimX, dimY)
    group2.dlgtablelayout(3,1,0) 

    Taggroup dwell_title = dlgcreatelabel("Dwell Time (ms): ").dlganchor("West")
    dwellTime = dlgcreaterealfield(5,22,8).dlganchor("West")
    Taggroup group3 = dlggroupitems(dwell_title, dwellTime)
    group3.dlgtablelayout(2,1,0) 

    Taggroup focal_title = dlgcreatelabel("Number of Images per Stack: ").dlganchor("West")
    numImages=dlgcreateintegerfield(5,15).dlganchor("West") 
    Taggroup group4 =dlggroupitems(focal_title, numImages)
    group4.dlgtablelayout(2,1,0) 
    
    Taggroup gui = dlggroupitems(group1, group2, group3, group4)
    gui.dlgtablelayout(1,4,0)
    return gui
}


// This function calls the various functions to create the dialog
void CreateDialog()
{
    TagGroup dialog_items;
    TagGroup dialog = DLGCreateDialog("", dialog_items);
    dialog_items.DLGAddElement( MakeLabels() );
    dialog_items.dlgaddelement(makefields())
    dialog_items.DLGAddElement( MakeButtons() );
    Object dialog_frame = alloc(Dialog).init(dialog)
    dialog_frame.display("Tomography Control Panel");
    
}

// Main program - This calls the function above, which creates the dialog.
CreateDialog()
