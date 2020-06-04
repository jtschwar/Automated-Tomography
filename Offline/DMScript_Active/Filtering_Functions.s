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
