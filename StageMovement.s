//Globals
taggroup tiltMin, deltaTilt, tiltMax, dimX, dimY, dwellTime, numImages

//Move the Stage in the x-y direction to track the sample with a safety check. (max should be x/y = +/- 0.5 um). 
void StageMovement(Number shiftX, Number shiftY)
{ 
    number cX = EMGetStageX()
    number cY = EMGetStageY()
    number nx, ny                              //New position in the x and y - direction.

    if(!(shiftX < -0.5 || shiftX > 0.5 ))
    {   nX = cX + shiftX
        EMSetStageX(nX)    }
    else if(shiftX > 0.5)
    {   showalert("Outside of range!",2)
        shiftX = 0.5
        nX = cX + shiftX
        EMSetStageX(nX)    }
    else 
    {   showalert("Outside of range!",2)
        shiftX = -0.5
        nX = cX + shiftX
        EMSetStageX(nX)     }

    if(!(shiftY < -0.5 || shiftY > 0.5 ))
    {   nY = cY + shiftY
        EMSetStageY(nY)     }
    else if(shiftY > 0.5)
    {   showalert("Outside of range!",2)
        shiftY = 0.5
        nY = cY + shiftY
        EMSetStageX(nY)     }
    else 
    {   showalert("Outside of range!",2)
        shiftY = -0.5
        nY = cY + shiftY
        EMSetStageX(nY)     }

}

