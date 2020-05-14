from matplotlib import pyplot as plt
from scipy import optimize
import numpy as np
import time
import os

# Pathing/Listening Information
local_path = os.getcwd()
myFile = 'Coordinate.txt'
fullpath = os.path.join(local_path, myFile)
myOutput = 'model_fit.txt'
outputPath = os.path.join(local_path, myOutput)
oldTime = 0


def check_coord():

    # Check for Updates
    for file in os.listdir():

        if(file == myFile):
            fileOBJ = os.stat(fullpath)
            newTime = fileOBJ.st_mtime
            global oldTime
            if(newTime != oldTime):
                print("Modifications Detected; remodel...")
                fit_curve()
                oldTime = newTime


def fit_curve():
    # Coordinates are saved as (alpha,x,y,z,beta) => (microns, degrees)
    coord = np.loadtxt(fullpath, delimiter=',', usecols=range(5))
    alpha_coord = coord[:, 0]
    x_coord = coord[:, 1]
    y_coord = coord[:, 2]
    z_coord = coord[:, 3]

    # # Curve Fitting
    x_params, x_covar = optimize.curve_fit(fit_lin, alpha_coord, x_coord)
    y_params, y_covar = optimize.curve_fit(fit_lin, alpha_coord, y_coord)
    z_params, z_covar = optimize.curve_fit(fit_lin, alpha_coord, z_coord)

    # #Plot Fitted Model
    fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(6, 6))
    fig.subplots_adjust(hspace=0.1, left=0.15)
    x = np.linspace(-90, 90)
    
    ax1.scatter(alpha_coord, x_coord,label='Data')
    ax1.plot(x,fit_lin(x,x_params[0],x_params[1]),label='Fitted')
    ax1.set_title('X Fitting')
    ax1.legend()
    
    ax2.scatter(alpha_coord, y_coord,label='Data')
    ax2.plot(x,fit_lin(x,y_params[0],y_params[1]),label='Fitted')
    ax2.set_title('Y Fitting')
    ax2.legend()

    ax3.scatter(alpha_coord, z_coord,label='Data')
    ax3.plot(x,fit_lin(x,z_params[0],z_params[1]),label='Fitted')
    ax3.set_title('Z Fitting')
    ax3.legend()
    
    plt.show()
    
    global f
    try:
        f = open(outputPath, 'w')
    except FileNotFoundError:
        f = open(outputPath, 'x')

    
    #np.savetxt(outputPath,(x_params, y_params, z_params),delimiter='\n')
    #xString = np.array2string(x_params)
    #yString = np.array2string(y_params)
    #zString = np.array2string(z_params)
    #f.write(xString)
    #f.write(yString)
    #f.write(zString)

    f.close()


def fit_lin(x, a, b):
    return a*x+b

#Time arbitrarily set right now, a break will be needed in actual use
for i in range(10): 

    check_coord()
    time.sleep(5)
    
    
