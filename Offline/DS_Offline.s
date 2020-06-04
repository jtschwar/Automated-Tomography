// Faux DigiScan Library

// This script contains all the Gatan DigiScan commands current to GMS 2.3. Some of the commands herein may not be
// supported on older DigiScan I systems. Use this script to enable offline development of DigiScan-based scripts.
// This will avoid having to do all the script writing on a STEM-based system. Only the final testing and thread timing
// will require time on the microscope's DigitalMicrograph system. 

// D. R. G. Mitchell, adminnospam@dmscripting.com (remove the nospam to make this work).
// version:20160112, v1.0, www.dmscripting.com.

// In most cases, the faux commands simply avoid generating errors when you run your script on a system without DigiScan.
// In most cases, prompts appear in the Output window saying which command has been called. Where commands return images/values
// then empty images or suitable values are returned to keep things working.
 
// This script may be included at the start of your own script during development. However, all the DS . . . ()  functions
// defined here MUST be removed before testing the script on a microscope-based system. An alternative is to install this 
// script as a library on your offline sytem (File/Install Script/Library). Your script will then call on these library functions.
// When you move your script to the microscope-based systems for testing - your script will then call DigiScan directly. 



/*   
This command acquires data into a pre-defined, existing image. The image has to be of type unsigned-integer. The signal, a pixel dwell-time, the scan rotation, and synchronization with the line mains are defined in the according parameters. The scanned area matches the current FOV for the larger image dimension and clips along the shorter image dimension to maintain square pixels. The function returns after the data has completely been acquired. The return value of the function is the pixel dwell-time used during acquisition. Too low or too high dwell-times are automatically clipped into the valid range. After the acquisition, the beam position is set to the default park position and scan control is restored to the situation before the acquisition.
Number Pixel dwell-time in microseconds, as used
BasicImage image Pre-defined image into which data is acquired
Number signalIndex Signal ID as defined DigiScan setup
Number pixelTime Pixel dwell-time in microseconds
Number rotation Scan rotation in degree
Boolean lineSync Activate synchronization with line mains
*/
   
Number DSAcquireData( image dsimage, Number signalIndex, Number pixelTime, Number rotation, number lineSync )
	{
		number xsize, ysize
		getsize(dsimage, xsize, ysize)
		dsimage=sin(icol)+sin(irow)
		number imagecomplete=1
		Result("\nAcquiring DigiScan Data.")
		return imagecomplete
	}
 


// Transform point coordinates from the coordinate system of the given reference image to the DigiScan (DS) coordinate system.

//BasicImage dsRefImage  Reference image, acquired using DigiScan
// Number img_x  X coordinate in coordinate system of reference image
// Number img_y  Y coordinate in coordinate system of reference image
// NumberVariable ds_x  Return: X coordinate in DS coordinate system
// NumberVariable ds_y  Return: Y coordinate in DS coordinate system

void DSCalcDSCoordFromImage( image dsRefImage, Number img_x, Number img_y, Number &dsx, Number &dsy ) 
	{
		number xsize, ysize, xoffset, yoffset
		getsize(dsrefimage, xsize, ysize)
		if(xsize>=1024) xoffset=11264
		else xoffset=11520
		if(ysize>=1024) yoffset=11264
		else yoffset=11520

		dsx=(((xsize/2)-img_x)/(xsize/2))*xoffset
		dsy=(((ysize/2)-img_y)/(ysize/2))*yoffset
		result("\nDS coordinates : x = "+dsx+" y = "+dsy)
	}


/*
Transform point coordinates from the DigiScan (DS) coordinate system to the coordinate system of the given reference image.
BasicImage dsRefImage  Reference image, acquired using DigiScan
Number ds_x  X coordinate in DS coordinate system
Number ds_y  Y coordinate in DS coordinate system
NumberVariable img_x  Return: X coordinate in coordinate system of reference image
NumberVariable img_y Return: Y coordinate in coordinate system of reference image
*/

void DSCalcImageCoordFromDS( Image dsRefImage, Number ds_x, Number ds_y, Number &img_x, Number &img_y )
	{
		number xsize, ysize, xoffset, yoffset

		getsize(dsrefimage, xsize, ysize)
		if(xsize>=1024) xoffset=11264
		else xoffset=11520
		if(ysize>=1024) yoffset=11264
		else yoffset=11520

		img_x=(abs(ds_x-xoffset)/((2*xoffset)+1))*xsize
		img_y=(abs(ds_y-yoffset)/((2*yoffset)+1))*ysize // +1 to allow for position 0
		result("\nImage coordinates ; x = "+img_x+" y = "+img_y)
	}


/*

Create a parameter set for acquiring DigiScan images. You need to specify the width, height, rotation, sample time per pixel and whether to synchronize with the line mains. These parameters are all equivalent to what you would do when setting up an acquisition from the DigiScan user interface. The function does not verify validity of all parameters. The function returns the ID of the parameter set it has generated. This value is needed in the other functions. Note that a created parameter set and the according ID stay in memory until deleted with DSDeleteParameters() or until DigitalMicrograph is closed.
Number  ID of the created parameter set
Number width  Scan width in pixels
Number height  Scan height in pixels
Number rotation  Scan rotation in degrees
Number pixelTime  Pixel dwell-time in microseconds
Boolean lineSynchEnabled  Activate synchronization with line mains
*/

Number DSCreateParameters( Number width, Number height, Number rotation, Number pixelTime, number lineSynchEnabled )
	{
		number paramid=123 // just a number - cannot emulate a parameter set
		result("\nParameter set created with ID : "+paramid)
		result("\nWidth = "+width+"  Height = "+height)
		result("\nRotation = "+rotation+"  Dwell (us) = "+pixeltime)
		result("\nLinesynch = "+linesynchenabled)
		return paramid
	}


/*
Return number of available signals from the DigiScan unit. 
Number  Number of available signals 
*/

Number DSCountSignals( )
	{
		number signals=3 // simply return an arbitrary number
		result("\nNumber of DigiScan signals = "+signals)
		return signals
	}


/*
Delete the parameter set with the parameter ID provided. After deleting it you can not re-use the parameter ID.
Number paramID ID number of parameter set
*/

void DSDeleteParameters( Number paramID )
	{
		result("\ndeleting DigiScan parameter set : "+paramid)
	}


/*
Enable or disable all dialog buttons and fields in the DigiScan tool dialog. This is useful to prevent user interaction during scripted acquisition.
Boolean enabled Enable (1) or disable (0) DigitScan-tool dialog elements
*/

void DSDialogEnabled( number enabled ) 
	{
		result("\nDigiScan Dialog enabled set to : "+enabled)
	}

  
/*
Stop the currently running acquisition when the frame has finished. The command returns immediately. Note that the current acquisition can be stopped immediately with DSStopAcquisition(-1).
*/

void DSFinishAcquisition( ) 
	{
		result("\nFinished DigiScan acquisition.")
	}


/*
Return the current beam position in the DigiScan (DS) coordinate system. Note that the beam will only be there, if DigiScan is controlling the beam. See also DSHasScanControl() and DSSetScanControl().
NumberVariable ds_x  Return: X coordinate in DS coordinate system
NumberVariable ds_y  Return: Y coordinate in DS coordinate system
*/

void DSGetBeamDSPosition( Number &ds_x, Number &ds_y ) 
	{
		// return arbitrary digiscan beam positions anywhere within a typical range
		// of +11000 to -11000
		ds_x=100 // zero in x and y is close to the centre of the image
		ds_y=-100
		result("\nDigiScan beam position : x = "+ds_x+"  y="+ds_y)
	}


/*
Return the device location of the scan device. The returned string is needed as input in some script commands, i.e. in EMGetCalibratedFieldOfView().
String 'Device location' identifier string for the scanning device
*/

String DSGetDeviceLocation( )
	{
		return("DigiScan")
	}


 
/*
Return the globally defined value of the “Flip Horizontal Scan” property as defined in the DigiScan advanced setup dialog. If true (1), images are horizontally mirrored along the fast scan direction.
Boolean Flip Horizontal Scan property. Either activated (1) or not (0) 
*/

number DSGetDoFlip( )
	{
		number doflip=0 // can be either 0 or 1
		Result("\nDigiScan Do Flip = "+doflip)
		return doflip
	}


/* 
Return the globally defined “Flyback Time” in microseconds as defined in the DigiScan advanced setup dialog. 
Number Flyback Time in microseconds 
*/

Number DSGetFlyBackTime( )
	{
		number flyback=500
		result("\nDigiScan flyback time = "+flyback+" us")
		return flyback
	}

/*
Return the scan height value (in pixels) of the specified parameter set of given ID. 
Number Scan height in pixels
Number paramID ID number of parameter set

*/

Number DSGetHeight( Number paramID )
	{
		number scanheight=1024 
		result("\nScan height = "+scanheight)
		return scanheight
	}
	
	
/*
Return the scan width value (in pixels) of the specified parameter set of given ID. 
Number Scan width in pixels
Number paramID ID number of parameter set

*/
	
Number DSGetWidth( Number paramID )
	{
		number scanwidth=1024 
		result("\nScan width = "+scanwidth)
		return scanwidth
	}


/* 
Return the image of the last image into which data of the specified signal was stored, independent of how this acquisition was started (script or user-interface button). The function throws an error message, if no such image could be found. 
BasicImage Image reference  of image containing signal
Number signalIndex  Signal ID as defined DigiScan setup
*/

Image DSGetLastAcquiredImage( Number signalIndex ) 
	{
		image dsimage=integerimage("",4, 0, 512, 512)
		dsimage=sin(icol)+sin(irow)
		result("\nDigiScan - getting the last acquired image.")
		return dsimage
	}


/*
Return the image ID of the last image into which data of the specified signal was stored, independent of how this acquisition was started (script or user-interface button). The function returns the value -1 if no such image could be found. 
Number ImageID of image containing signal. -1 if no image was found
Number signalIndex Signal ID as defined DigiScan setup
*/

Number DSGetLastAcquiredImageID( Number signalIndex )
	{
		number imageid=123
		result("\nDigiScan getting the ID of the last acquired image = "+imageid)
		return imageid
	}
 
/*
Return the globally defined “Line frequency” in Hertz as defined in the DigiScan advanced setup dialog. 
Number  Line frequency in Hertz
*/

Number DSGetLineFrequency( )
	{
		number frequency=50
		result("\nDigiScan line frequency = "+frequency)
		return frequency
	}
 
/* 
Return whether or not LineSynch is enabled in the specified parameter set of given ID.
Boolean True (1) if LineSynch is enabled
Number paramID ID number of parameter set
*/

number DSGetLineSynch( Number paramID )
	{
		number linesynchon=0
		result("\nDigiScan Line Synch = "+linesynchon)
		return linesynchon
	}


/*
Return the longest pixel dwell-time (in microseconds) allowed for the device. 
Number Pixel dwell-time in microseconds
*/

Number DSGetMaxPixelTime( ) 
	{
		number maxpixeldwell=419430
		result("\nDigiScan maximum pixel dwell time = "+maxpixeldwell+" us")
		return maxpixeldwell
	}

 
/*
Return the maximum signal value which may be returned for an acquisition of given pixel dwell-time (in microseconds) and data depth (1, 2 or 4 byte). The parameter CardID is only used for DigiScan1 devices. 
Number Maximum signal value
Number card CardID (DigiScan1 only)
Number depth Data depth of digitized signal
Number dwellTime Pixel dwell-time in microseconds
*/

Number DSGetMaxSignal( Number card, Number depth, Number dwellTime )
	{
		number maxsignal
		if(depth==1) maxsignal=160
		if(depth==2) maxsignal=40960
		if(depth==4) maxsignal=163840
		if(maxsignal==0)
			{
				result("\nDSGetMaxSignal() error - depth must be 1, 2 or 4.")
				return maxsignal
			}
		
		maxsignal=maxsignal*dwelltime
		result("\nDigiScan maximum signal value : Card = "+card+"  Depth = "+depth+" Dwell Time = "+dwelltime+" us")
		return maxsignal
	}



/*
Return the shortest pixel dwell-time (in microseconds) allowed for the device for the given data depth (1, 2 or 4 byte) 
and number of digitized signals.
Number Pixel dwell-time in microseconds
Number signal_depth Data depth of digitized signal
*/

Number DSGetMinPixelTime( Number signal_depth, Number nSignals )
	{
			number minpixtime=0.5
			
			if(signal_depth!=1 && signal_depth!=2 && signal_depth!=4)
				{
					result("\nDSGetMinPixelTime() error - signal bit depth must be 1, 2 or 4.")
					return minpixtime
				}
			
			if(signal_depth==4)  minpixtime=0.8
			result("\nDigiScan minimum pixel dwell time = "+minpixtime+" us"+" Depth = "+signal_depth+" Signals = "+nsignals)
			return minpixtime
	}

 
 /*
Return the parameters of the specified parameter set of given ID into the according variables. The function returns false (0) if no parameter set of given ID is found and true (1) otherwise.
number boolean=true of false if paramid exists
Number paramID  ID number of parameter set
NumberVariable width  Return: scan width in pixels 
NumberVariable height Return: scan height in pixels
NumberVariable rotation Return: scan rotation in degree
NumberVariable pixelTime Return: pixel dwell-time in microseconds
NumberVariable lineSynchEnabled Return: synchronization with line mains active (1) or not (0)
*/

number DSGetParameters( Number paramID, Number &width, Number &height, Number &rotation, Number &pixelTime, Number &lineSynchEnabled )
	{
		width=1024
		height=1024
		rotation=0
		pixeltime=20
		lineSynchEnabled=1
		Result("\nDigiScan Getting Parameters : Parameter ID = "+paramid+"  Width = "+width+"  Height = "+height)
		result("\nRotation = "+rotation+" Pixel Dwell Time = "+pixeltime+" us  Line Synch = "+linesynchenabled)
		return 1
	}


/*
Return the pixel dwell time (in us) of the specified parameter set of given ID. 
Number Pixel dwell-time in microseconds
Number paramID ID number of parameter set
*/

Number DSGetPixelTime( Number paramID )
	{
		number pixeltime=20
		result("\nDigiScan Pixel Dwell Time = "+pixeltime)
		return pixeltime
	}
 

/*
Return the rotation value that is currently displayed in the DigiScan floating window. The angle specifies the rotation of the scan with respect to the image. A positive value results in clock-wise rotation of the image if Flip Horizontal Scan is switched off. 
Number Rotation value in degree
*/

Number DSGetRotation( ) 
	{
		number rotation=0
		result("\nDigiScan Rotation = "+rotation)
		return rotation
	}


/*
Return the rotation value (in degree) of the specified parameter set of given ID. Do not confuse this with the command DSGetRotation() without a parameter. 
Number Scan rotation in degree
Number paramID ID number of parameter set
*/

Number DSGetRotation( Number paramID )
	{
		number rotation=0
		result("\nDigiScan Rotation = "+rotation+" for parameter set = "+paramid)
		return rotation
	}

/*
Return the globally defined “Rotation Offset” in degree as defined in the DigiScan advanced setup dialog. The angle specifies the rotation of the scan with respect to the image. A positive value results in clock-wise rotation of the image if Flip Horizontal Scan is switched off. 
Number Rotation Offset in degree 
*/

Number DSGetRotationOffset( ) 
	{
		number rotationoffset=180
		result("\nDigiScan Rotation Offset = "+rotationoffset)
		return rotationoffset
	}

/*
Return if the specified signal is acquired in the specified parameter set of given ID. 
function returns true or false if the signal is acquired in the parameter set
Number paramID ID number of parameter set
Number signalIndex Signal ID as defined DigiScan setup
*/
 
number DSGetSignalAcquired( Number paramID , Number signalIndex )
	{
		number boolean=0
		result("\nDigiScan Signal = "+signalindex+" was acquired = "+boolean+" for parameter set = "+paramid)
		return boolean
	}
 
/*
Return the name of the DigiScan signal at given index.
String  Name of signal
Number index Index of signal
*/

String DSGetSignalName( Number index ) 
	{
		string signame
		if(index==0) signame="ADF"
		if(index==1) signame="BF"
		if(index==2) signame="BEI"
		result("\nDigiScan Signal Name with Index = "+index+" = "+signame)
		return signame
	}


/*
Return whether or not the beam is currently controlled by DigiScan.
Boolean True (1)  if DigiScan is controlling the beam
*/

number DSHasScanControl( ) 
	{
		number hascontrol=0
		result("\nDigiScan has control = "+hascontrol)
		return hascontrol
	}


/*
This function is the same as pressing a button in the DigiScan tool dialog. The function returns immediately. 
Number buttonID
0 … Restart
1 … Search
2 … Preview
3 … Record
4 … Restart
5 … Stop
6 … Waveform Monitor
7 … Control Beam
*/

void DSInvokeButton( Number buttonID ) 
	{
		string button="Null Selection"
		if(buttonid==0) button="Restart"
		if(buttonid==1) button="Search"
		if(buttonid==2) button="Preview"
		
		if(buttonid==3) button="Record"
		if(buttonid==4) button="Restart"
		if(buttonid==5) button="Stop"
		
		if(buttonid==6) button="Waveform Monitor"
		if(buttonid==7) button="Control Beam"
		result("\nDigiScan "+button+" pressed.")
		return
	}


/*
This function is the same as pressing a button in the DigiScan tool dialog. The function returns immediately. For Waveform Monitor (6) and Control Beam (7), the option parameter may be set to 0 (deactivate) or 1 (activate). For Restart (0/4), the option parameter may be set to 0 (same as before), 1 (single frame) or 2 (continuous) scan mode. For the other buttons the option parameter does not have an effect. 
 
Number buttonID
0 … Restart
1 … Search
2 … Preview
3 … Record
4 … Restart
5 … Stop
6 … Waveform Monitor
7 … Control Beam
Number option Optional value for some buttons
*/

void DSInvokeButton( Number buttonID, number option ) 
	{
		string button="Null Selection"
		if(buttonid==0) button="Restart"
		if(buttonid==1) button="Search"
		if(buttonid==2) button="Preview"
		
		if(buttonid==3) button="Record"
		if(buttonid==4) button="Restart"
		if(buttonid==5) button="Stop"
		
		if(buttonid==6) button="Waveform Monitor"
		if(buttonid==7) button="Control Beam"
		result("\nDigiScan "+button+" pressed.")
		return
	}


/*
Return if DigiScan is actively acquiring data.
returns boolean True (1) if DigiScan is currently acquiring
*/

number DSIsAcquisitionActive( ) 
	{
		number isactive=0
		result("\nDigiScan is acquisition active = "+isactive)
		return isactive
	}


/*
Verify (by checking the according tags) if the image has been acquired with the DigiScan device. This command is useful to check if an image can be used in script commands which require a DigiScan image as input.
Returns boolean True (1) for images acquired with DigiScan
BasicImage image Image to be checked
*/

number DSIsValidDSImage( image myimage )
	{
		// Note this function looks for several DigiScan tags. Image height may not be one of the
		// sought after tags, but it is always present on DS images and so is used here
		
		number imageheight
		number hasdstag=getnumbernote(myimage, "DigiScan:Image Height", imageheight)
		if(imageheight>0) hasdstag=1
		else hasdstag=0
		result("\nDigiScan is valid image (looking for DigiScan Image Height tag) = "+hasdstag)
		return hasdstag
	}


/*
See if a set of parameters with the id paramid exists
returns boolean Parameter set of given ID does exist
Number paramID ID number of parameter set
*/

number DSParametersExist( Number paramID )
	{
		number paramsexist=0
		result("\nDigiScan parameters exist = "+paramsexist)
		return paramsexist
	}


/*
Set the beam to the specified position given by the pixel X/Y in the reference image which has to be an image acquired with DigiScan. It is possible to use non-integer values for X and Y. Note that the beam will only be physically moved, if DigiScan is controlling the beam. See also DSHasScanControl() and DSSetScanControl().
void No return value
BasicImage dsRefImage Reference image, acquired using DigiScan
Number x  X coordinate in pixels
Number y Y coordinate in pixels
*/

void DSPositionBeam( image dsRefImage, Number x, Number y ) 
	{
		result("\nDigiScan Setting beam to x: "+x+"  y: "+y)
		return
	}


/*
Restart acquisition in the front image. This is identical to hitting the Restart button in the DigiScan tool dialog, except that it is possible to change the scanMode, i.e. whether single frame or continuous. The function returns immediately. 
void No return value
Number scanMode
0 … same as before
1 … single frame
2 … continuous
*/

void DSRestart( Number scanMode ) 
	{
		string mode="Null mode"
		if(scanmode==0) mode="same as before"
		if(scanmode==1) mode="single frame"
		if(scanmode==2) mode="continuous"
		result("\nDigiScan Resarting scan in "+mode+" mode.")
		return
	}


 
 /*
 Acquire a linescan
 This command acquires data into a pre-defined, existing image. The signal of the reference image (refImage)
is used in the destination image (dstImage), and both images have to be of matching data type and data depth. 
A new line scan  is defined by two points in the reference image which has to be an image acquired with DigiScan. 
The destination image has to be a 1D image and its size defines the sampling along the scan. 
The dwell-time of the scan is specified by the parameter pixelTime. 
The function returns after the data has completely been acquired. 
The return value of the function is the pixel dwell-time used during acquisition. 
Too low or too high dwell-times are automatically clipped into the valid range. 
After the acquisition, the beam position is set to the default park position and scan control is restored to 
the situation before the acquisition.

 Return value and parameters 

Number Pixel dwell-time in microseconds, as used
BasicImage refImage Reference image, acquired using DigiScan
BasicImage dstImage Pre-defined image into which data is acquired
Number y0 y coordinate of first point defining the profile in the reference image
Number x0 x coordinate of first point defining the profile in the reference image
Number y1 y coordinate of second point defining the profile in the reference image
Number x1 x coordinate of second point defining the profile in the reference image
Number pixelTime Pixel dwell-time in microseconds
 */
 

Number DSScanProfile( image refImage, image dstImage, Number y0, Number x0, Number y1, Number x1, Number pixelTime)
	{
		result("\nDigiScan Acquiring a linescan.")
		dstimage=icol // add some data to the passed in target image
		return 1 // I assume 1 is returned if no error is encountered
	}



/*
This command acquires data into a pre-defined, existing image. 
The signal of the reference image (refImage) is used in the destination image (dstImage), and both images
have to be of matching data type and data depth. The new scan area is defined by the specified, 
rectangular sub area in the reference image, which has to be an image acquired with DigiScan. 
The sampling of the scan is defined by the size of the destination image. The dwell-time of the scan is
specified by the parameter pixelTime. If the aspect ratio of the specified area and the aspect ratio of the
destination image differ, sampling distance in X and Y differs resulting in “non-square” pixels. 
Note that the general image calibration is then no longer valid, as calibration of x and y direction differs.
The function returns after the data has completely been acquired.
After the acquisition, the beam position is set to the default park position and scan control is restored
to the situation before the acquisition.

image refImage Reference image, acquired using DigiScan
image dstImage Pre-defined image into which data is acquired
Number top Top coordinate of rectangular sub region
Number left Left coordinate of rectangular sub region
Number bottom Bottom coordinate of rectangular sub region
Number right Right coordinate of rectangular sub region
Number pixelTime Pixel dwell-time in microseconds
*/

void DSScanSubRegion( image refImage, image dstImage, Number top, Number left, Number bottom, Number right, Number pixelTime ) 
	{
		number xsize, ysize
		getsize(refimage, xsize, ysize)


		// Trap in case sub-area parameters are out of the bounds of the reference image

		try
			{
				dstimage=refimage[top, left, bottom, right]
				result("\nDigiScan Acquiring a sub-area scan ; t="+top+" l="+left+" b="+bottom+" r="+right)

			}
		catch
			{
				dstimage=refimage
				result("\nDigiScan Sub-area parameters were out of bounds.")
				dstimage=icol*irow // add some data to the passed in image
			}
	}


// This command aquires a sub-area image from the DigiScan reference image
// The top left corner of the sub-area is defined with the size set by the passed in image

// BasicImage refImage Reference image, acquired using DigiScan
// BasicImage dstImage Pre-defined image into which data is acquired
// Number X x coordinate of starting point of sub region
// Number Y y coordinate of starting point of sub region
// Number pixelTime Pixel dwell-time in microseconds
 

void DSScanSubRegion(Image refImage, Image dstImage, Number X, Number Y ) 
	{
		number dstx, dsty
		getsize(dstimage, dstx, dsty)

		try
			{
				dstimage=refimage[y, x, dsty, dstx]
				result("\nDigiScan scanning sub-region")

			}
		catch
			{
				dstimage=icol
				result("\nDigiScan Sub-area scan was outside the bounds of the reference image.")
			}
	}

/*
Set the beam to the specified position given by X/Y in the DigiScan (DS) coordinate system. Note that the beam will only be physically moved, if DigiScan is controlling the beam. See also DSHasScanControl() and DSSetScanControl(). There is a slight speed advantage of DSSetBeamDSPosition() over DSPositionBeam().
Number ds_x X coordinate in DS coordinate system
Number ds_y Y coordinate in DS coordinate system
*/
 

void DSSetBeamDSPosition( Number ds_x, Number ds_y )
	{
		result("\nDigiScan Beam position set to x="+ds_x+" y="+ds_y)
	}

 
/*
Set the beam to the Beam Safe Position as specified in the advanced DigiScan setup dialog. Note that the beam will only be physically moved, if DigiScan is controlling the beam. See also DSHasScanControl() and DSSetScanControl(). 
*/

void DSSetBeamToSafePosition( )
	{
		result("\nDigiScan Beam set to safe position.")
	}

 
/*
 Set the “Flyback Time” in microseconds. Note that this will change the globally defined “Flyback Time” which can also be set via the DigiScan advanced setup dialog. It will therefore be valid for all DigiScan acquisitions and not only for the currently scripted one.
Number FlybackTime Flyback Time in microseconds
*/

void DSSetFlybackTime( Number FlybackTime ) 
	{
		result("\nDigiScan Flyback time set to "+flybacktime)
	}


/* 
Add/Modify a specific signal in the specified, existing parameter set. The signal is specified by its index according to the DigiScan setup, and a data depth in bytes. 
To remove a signal from a parameter set, set the parameter selected to false. 
The imageID specifies the image into which the acquired data should be stored. 
If an ID of 0 (zero) is given, the system will either reuse an appropriate image or create a new one. 

Please note that there are certain restrictions on what combination of data types can be used when 
acquiring multiple signals (see the DigiScan set-up dialog). 
These restrictions may not be checked for by the software and you may get DMA error messages.

Boolean True (1)  if given parameter set could be successfully modified
Number paramID ID number of parameter set
Number signalIndex Signal ID as defined DigiScan setup
Number dataType Signal depth in bytes (1, 2 or 4)
Boolean selected Include this signal in acquisition
Number imageID ID of image into which should be acquired
If set to 0 (zero), reuse/create appropriate image.
*/

number DSSetParametersSignal( Number paramID, Number signalIndex, Number dataType, number selected, Number imageID )
	{
		result("\nDigiScan Modifying Parameter Set : Param ID = "+paramid+" Signal index = "+signalindex+" Data Type = "+datatype)
		result("\nSelected = "+selected+" Image ID = "+imageid)
		return 1 // assumes parameter set was correctly modified
	}

/*
Set or release DigiScan control of the electron beam. Control over the beam is needed for manual beam positioning.
Boolean control Grab (1) or release (0) DigitScan beam control
*/

void DSSetScanControl( number control ) 
	{
		if(control==0) result("\nDigiScan beam control released.")
		else result("\nDigiScan beam control grabbed.")
	}

 
/*
Start the acquisition with the parameter set of given ID.  Either acquire 1 frame (continuous = 0) or multiple frames (continuous = 1). The function can return immediately (synchronous = 0) or after the acquisition finishes (synchronous = 1). Note that calling the function with both continuous and synchronous activated at the same time is generally not advisable and will result in an indefinite loop. It may freeze the application when run from the main thread. 
Number paramID ID number of parameter set
Boolean continuous Continuous, repeated acquisition
Boolean synchronous Hold script execution until acquisition finishes
 */
 
void DSStartAcquisition( Number paramID, number continuous, number synchronous )
	{
	image dummy = NewImage("dummy",2,512,512,1)
	showImage(dummy)
	result("\nDigiScan acquisition started : Continuous = "+continuous+" Synchronous = "+synchronous)
	
	}


/*
Stop the acquisition belonging to the parameter sot of given ID. Use paramID = -1 to stop any currently running acquisition
Number paramID ID number of parameter set
*/

void DSStopAcquisition( Number paramID )
	{
		if(paramid==-1) result("\nDigiScan Stopping all running acquisitions.")
		else result("\nDigiScan Stopping acquisition with parameter ID = "+paramid)
	}


/*
Pause script until DigiScan acquisition has stopped.
*/

void DSWaitUntilFinished( )
	{
		result("\nDigiScan Waiting until acquisition has stopped.")
	}
