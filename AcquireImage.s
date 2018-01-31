//Globals
taggroup tiltMin, deltaTilt, tiltMax, dimX, dimY, dwellTime, numImages

void AcquireImage()
{
    //Getting values from dialog box fields c->current
    number cDwellT = dlgGetValue(dwellTime) //Dwell Time.
    number xDims = dlgGetValue(dimX) //Pixel Dimension - X
    number yDims = dlgGetValue(dimY) //Pixel Dimension - Y
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
    number paramID = DSCreateParameters(xDims,yDims,cRotation,cDwellT,0)
    DSSetParametersSignal( paramID, signalIndexDF, dataDepth, acquire, imageID ) //DF

    String Index = "Correlation_"+theta+"_degrees_"+cX+"_"+cY+"_"+cZ+"_microns"  //Stage Location
    image stack = NewImage(Index,2,xDims,yDims)
    SetName(stack, Stack_Index)
    DSStartAcquisition(paramID,0,1)     //Captures STEM - DF & BF IMAGE  
        
    ShowImage(stack) //Show image stack once complete
    }
       
}