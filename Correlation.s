//Globals
taggroup tiltMin, deltaTilt, tiltMax, dimX, dimY, dwellTime, numImages

//Move the Stage in the x-y direction to track the sample. 
Number Correlation()
{
    // STEP 1: Get source images
    image img1, img2
    if ( !GetFrontImage( img1 ) )
        Throw( "No image displayed." )
    img2 := FindNextImage( img1 )
    if ( !ImageIsValid( img2 ) )
        Throw( "No image 'behind' the front image." )
    
    // STEP 2: Ensure image are of same size, else pad (with zeros).
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
    
    // STEP 3: Cross-Correlate images and find maximum correlation
    image CC := CrossCorrelate( src, ref )
    ShowImage(CC)                               //Show the cross correlation. 
    number mpX, mpY
    max( CC, mpX, mpY )                         //Position of max pixel is at (mpX, mpY)
    number sX = cx - mpX 
    number sY = cy - mpY 
    Result( "Relative image shift: (" + sX + "/" + sY + ") pixels \n" )

    //Return the current STEM field-of-view (FOV) in calibrated units according to the stored calibration.
    scaleX = img2.imageGetDimensionScale(0)  // Returns the scale of the given dimension of image.  
    scaleY = img2.imageGetDimensionScale(1)   
    shiftX = sX*scaleX
    shiftY = sY*scaleY                           

}