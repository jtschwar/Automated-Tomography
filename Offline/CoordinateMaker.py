# -*- coding: utf-8 -*-
"""
Created on Tue May 19 19:41:51 2020

@author: jacob
"""

import matplotlib.pyplot as plt
import numpy as np
import mrcfile 
from scipy import optimize
import uncertainties.unumpy as unp
import uncertainties as unc

fname=  'NiSi-1.mrc'

tomo = mrcfile.open(fname)

ntilts = len(tomo.extended_header)
#print((tomo.extended_header))
#tomo.print_header()

alpha = np.zeros(ntilts,dtype=np.float32)
beta = np.zeros(ntilts,dtype=np.float32)
xx = np.zeros(ntilts,dtype=np.float32)
yy = np.zeros(ntilts,dtype=np.float32)
zz = np.zeros(ntilts,dtype=np.float32)
px = np.zeros(ntilts,dtype=np.float32)
py = np.zeros(ntilts,dtype=np.float32)
df = np.zeros(ntilts,dtype=np.float32)
mag = np.zeros(ntilts,dtype=np.float32)
soffx = np.zeros(ntilts,dtype=np.float32)
soffy = np.zeros(ntilts,dtype=np.float32)
sx = np.zeros(ntilts,dtype=np.float32)
sy = np.zeros(ntilts,dtype=np.float32)

for ii in range(ntilts):
	 
    alpha[ii] = tomo.extended_header[ii]['Alpha tilt']
    beta[ii] = tomo.extended_header[ii]['Beta tilt']
    xx[ii] = tomo.extended_header[ii]['X-Stage']
    yy[ii] = tomo.extended_header[ii]['Y-Stage']
    zz[ii] = tomo.extended_header[ii]['Z-Stage']
    px[ii] = tomo.extended_header[ii]['Pixel size X']
    py[ii] = tomo.extended_header[ii]['Pixel size Y']
    df[ii] = tomo.extended_header[ii]['Defocus']
    mag[ii] = tomo.extended_header[ii]['Magnification']
    soffx[ii] = tomo.extended_header[ii]['Shift offset X']
    soffy[ii] = tomo.extended_header[ii]['Shift offset Y']
    sx[ii] = tomo.extended_header[ii]['Shift X']
    sy[ii] = tomo.extended_header[ii]['Shift Y']


outputString = ''
weightInput = input('Weighted with extrema (W)?')
if weightInput == 'W':    
    for ii in (np.int(0),np.int(ntilts/2),np.int(ntilts-1)):
        print(ii)
        string_list = [str(xx[ii]*10**6), str(yy[ii]*10**6), str(zz[ii]*10**6), str(alpha[ii]), str(beta[ii]), str(df[ii]*10**6), '0', '0']
        outputString = outputString + ','.join(string_list) +'\n'
else:
    print('No weighting; continuing...')
for ii in range(ntilts):
    string_list = [str(xx[ii]*10**6), str(yy[ii]*10**6), str(zz[ii]*10**6), str(alpha[ii]), str(beta[ii]), str(df[ii]*10**6), '0', '0']
    outputString = outputString + ','.join(string_list) +'\n'
    with open('Coordinate.txt', 'w') as f:
        f.write(outputString)
    input('Press Enter for next coordinate!')