//Performs a coarse semi-automated tomography tilt series
//with a GUI to specificy certain parameters such as dwell time, image dimensions, and number of images.
//By Jonathan Schwartz, adapated from programs written by Noah Schnitzer. 

//Globals
taggroup tiltMin, deltaTilt, tiltMax, dimX, dimY, dwellTime, numImages //Should I let the user specify the focus range too??

/*  Arrays for storing stage movements for Tilt - N. 
Image TiltData := RealImage("Tilt Angles", 4, 100, 1) 
Image xPosition := RealImage("xPositions", 4, 100, 1)
Image yPosition := RealImage("yPositions", 4, 100, 1)
Image xRelPosition := RealImage("Relative x-Shifts", 4, 100, 1)
Image yRelPosition := RealImage("Relative y-Shifts", 4, 100, 1)
*/

Image AcquireImage(Number dwell, String name)
{
    //Getting values from dialog box fields c->current
    number xDims = dlgGetValue(dimX) //Pixel Dimension - X
    //number yDims = dlgGetValue(dimX) //Pixel Dimension - Y
    number theta = EMGetStageAlpha()
    number cX = EMGetStageX()
    number cY = EMGetStageY()
    number cZ = EMGetStageZ()

    //Image acquisition locals for paramID. 
    number signalIndexDF = 0    //HAADF Detector = 0   
    number dataDepth = 4        //4-byte data (Data Type)
    number acquire = 1          //Acquire this signal
    number imageID = 0          //Create new image
    number cRotation = 0        //DSGetRotation()
        
    //Creating DigiScan scan: (xdim, ydim, rotation, dwell time (pixelTime), line sync)
    number paramID = DSCreateParameters(xDims,xDims,cRotation,dwell,0)
    DSSetParametersSignal( paramID, signalIndexDF, dataDepth, acquire, imageID ) //DF

    String Index = Name+ "_"+theta+"_degrees_"+cX+"_"+cY+"_"+cZ+"_microns"  //Stage Location
    DSStartAcquisition(paramID,0,1)     //Captures STEM - DF & BF IMAGE  
    image SingleImg := GetFrontImage()  
    SetName(SingleImg, Index)
    ShowImage(SingleImg) //Show image stack once complete
    return SingleImg
}

void Correlation(image &img1, image &img2, number &x, number &y)
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
    //ShowImage(CC)                               //Show the cross correlation. 
    number mpX, mpY
    max( CC, mpX, mpY )                         //Position of max pixel is at (mpX, mpY)
    number sX = cx - mpX 
    number sY = cy - mpY 
    //Result( "Relative image shift: (" + sX + "/" + sY + ") pixels \n" )

    //Return the current STEM field-of-view (FOV) in calibrated units according to the stored calibration.
    number scaleX = img2.imageGetDimensionScale(0)  // Returns the scale of the given dimension of image.  
    number scaleY = img2.imageGetDimensionScale(1)   
    x = sX*scaleX
    y = sY*scaleY   

    Result("Relative image shift: (" + x + "/" + y + ") Microns \n" ) 
}

void StageMovement(Number sx, Number sy)
{
    number cX = EMGetStageX()
    number cY = EMGetStageY()
    number nX, nY                              //New position in the x and y - direction.

    nX = cX - sx
    EMSetStageX(nX)  

    nY = cY + sy
    EMSetStageY(nY) 

    /*
    if(!(sx < -0.5 || sx > 0.5 ))
    {   nX = cX + sx
        EMSetStageX(nX)    
    }
    
    else if(sx > 0.5)
    {   showalert("Outside of range!\n",2)
        sx = 0.5
        nX = cX + sx
        EMSetStageX(nX)    
    }
    else 
    {   showalert("Outside of range!\n",2)
        sx = -0.5
        nX = cX + sx
        EMSetStageX(nX)     
    }

    if(!(sy < -0.5 || sy > 0.5 ))
    {   nY = cY + sy
        EMSetStageY(nY)     
    }
    else if(sy > 0.5)
    {   showalert("Outside of range!\n",2)
        sy = 0.5
        nY = cY + sy
        EMSetStageY(nY)     
    }
    else 
    {   showalert("Outside of range!\n",2)
        sy = -0.5
        nY = cY + sy
        EMSetStageY(nY)     
    }
    */

}

void Tilt(number theta)
{
    number currentAngle = EMGetStageAlpha()
    EMSetStageAlpha(currentAngle + theta)
}

void Automation(image &img1, number &dwell)
{
    number sx, sy, error
    Image img2 := AcquireImage(dwell/2, "Correlation") 
    Correlation(img1, img2, sx, sy)
    StageMovement(sx, sy)
    error = sx*sx + sy*sy                         
    number i = 0 
    while(error >= 0.04)
    {
        img2 := AcquireImage(dwell/2, "Correlation")
        Correlation(img1, img2, sx, sy)
        StageMovement(sx,sy) 
        error = sx*sx + sy*sy
        result(error+"\n"+sx+"(x)"+sy+"sy\n")
        i +=1
        if(i >= 5)
        {
            break;
        }
    }
}

/* 
Image StoreCurrentLocation(Number &currentX, Number &currentY)
{    
    //Record the position of each tilt. 
    return 
}

Image StoreRelativeShift(Number &relativeX, Number &relativeY)
{
    //Record the relative shfit from each tilt. 
}
*/

class Dialog : uiframe
{   
    number shiftX, shiftY, userDwell
    Image  firstImg, secondImg

    void Start(object self)
    {
         userDwell = DLGGetValue(dwellTime)
         firstImg := AcquireImage(userDwell, "OriginalImage")
    }

    void Tilt(object self)
    {
        number deltaTheta = DLGGetValue(deltaTilt)
        Tilt(deltaTheta)
    }

    void CalcShift(object self)
    {
        userDwell = DLGGetValue(dwellTime)
        secondImg := AcquireImage(userDwell/2, "Correlation")          //Acquire a second image for cross correlation. 
        Correlation(firstImg, secondImg, shiftX, shiftY)               //Perform cross correlation between both images.
    }

    void Shift(object self)
    {
        userDwell = DLGGetValue(dwellTime)
        Automation(firstImg, userDwell)
        //StageMovement(shiftX, shiftY)
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
    TagGroup ExecuteButton = DLGCreatePushButton("Take Data", "Start").DLGSide("Bottom");
    ExecuteButton.dlgexternalpadding(10,10)

    Taggroup TiltButton = DLGCreatePushButton("Tilt", "Tilt").DLGSide("Bottom");
    ExecuteButton.dlgexternalpadding(10,10)

    Taggroup CalcButton = DLGCreatePushButton("Calculate Stage Shift", "CalcShift").DLGSide("Bottom");
    ExecuteButton.dlgexternalpadding(10,10)

    Taggroup ShiftButton =  DLGCreatePushButton("Move Stage", "Shift").DLGSide("Bottom");
    ExecuteButton.dlgexternalpadding(10,10)
    
    Taggroup group = dlggroupitems(ExecuteButton,TiltButton,CalcButton, ShiftButton)
    group.dlgtablelayout(4,1,0)

    return group
}


Taggroup makefields() //Rename all the taggroups variables "taggroup-i"
{
    Taggroup theta_title = dlgcreatelabel("Tilt (Degrees): ").dlganchor("West")
    tiltMin = dlgcreaterealfield(-60.0,10,8).dlganchor("West")
    deltaTilt = dlgcreaterealfield(3.0,10,8).dlganchor("West")
    tiltMax = dlgcreaterealfield(60.0,10,8).dlganchor("West")
    Taggroup group1 = dlggroupitems(theta_title, tiltmin, deltatilt, tiltmax)
    group1.dlgtablelayout(4,1,0) 

    Taggroup dim_title = dlgcreatelabel("Pixel Dimensions ( x, y ): ").dlganchor("West")
    dimX = dlgcreaterealfield(256,23,8).dlganchor("West")
    Taggroup group2 = dlggroupitems(dim_title, dimX)
    group2.dlgtablelayout(3,1,0) 

    Taggroup dwell_title = dlgcreatelabel("Dwell Time (ms): ").dlganchor("West")
    dwellTime = dlgcreaterealfield(5,20,8).dlganchor("West")
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
