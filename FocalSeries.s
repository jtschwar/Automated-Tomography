//Globals
taggroup tiltMin, deltaTilt, tiltMax, dimX, dimY, dwellTime, numImages

void FocalSeries(int j) 
{
    //Getting values from dialog box fields c->current
    number cImageNum = dlgGetValue(numImages) //Number of images in Focal Series.
    number cDwellT = dlgGetValue(dwellTime) //Dwell Time.
    number xDims = dlgGetValue(dimX) //Pixel Dimension - X
    number yDims = dlgGetValue(dimY) //Pixel Dimension - Y
    number cX = EMGetStageX()
    number cY = EMGetStageY()
    number cZ = EMGetStageZ()
    number theta = EMGetStageAlpha()
    number originalFocus = EMGetFocus()
    number i, cSFocus, cEFocus, focusStep
    cSFocus = originalFocus - 200
    cEFocus = orignalFocus + 200

    //Image acquisition locals for paramID 
    number signalIndexDF = 0    //HAADF Detector = 0   
    number signalIndexBF = 1    //BF detector = 1
    number dataDepth = 4        //4-byte data (Data Type)
    number acquire = 1          //Acquire this signal
    number imageID = 0          //Create new image
    number cRotation = 0        //DSGetRotation()
        
    //Creating DigiScan scan: (xdim, ydim, rotation, dwell time (pixelTime), line sync)
    number paramID = DSCreateParameters(xDims,yDims,cRotation,cDwellT,0)
    DSSetParametersSignal( paramID, signalIndexDF, dataDepth, acquire, imageID ) //DF
    DSSetParametersSignal( paramID, signalIndexBF, dataDepth, acquire, imageID ) //BF

    String Stack_Index = j+"_stack_"+theta+"_degrees_"+cX+"(x)_"+cY+"(y)_"+cZ+"(z)_microns" 
    image stack = NewImage(Stack_Index,2,xDims,yDims,cImageNum)
    SetName(stack, Stack_Index)
    
    if(!(cImageNum==1)) //to avoid div by 0
    {
        focusStep = (cEFocus - cSFocus)/(cImageNum-1)
    }
    else
    {
        focusStep = 0
    }
    
    EMChangeFocus(cSFocus) //Defocus to starting value
    
    for(i = 0; i < cImageNum; i++)//looping, taking each image and adjusting focus
    {
        DSStartAcquisition(paramID,0,1)     //Captures STEM - DF & BF IMAGE
        image curr := getFrontImage()       //pulls front most image as target
        stack[0,0,i,cDims,cDims,i+1]= curr  //adds to stack
        DeleteImage(curr)
        
        if(!(focusstep==0))                 //changing focus by focal step
        {
            EMChangeFocus(focusStep)
        }
    }
    
    EMChangeFocus(originalFocus) 
    ShowImage(stack) //show image stack once complete
}