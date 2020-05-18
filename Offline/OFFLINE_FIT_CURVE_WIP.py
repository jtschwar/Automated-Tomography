from matplotlib import pyplot as plt
from scipy import optimize
import numpy as np
import time
import os
import sys

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
    coord = np.loadtxt(fullpath, delimiter=',', usecols=range(8))
    
    x_coord = coord[:, 0]
    y_coord = coord[:, 1]
    z_coord = coord[:, 2]
    alpha_coord = coord[:, 3]
    df_coord = coord[:,5]

    # #Plot Data Model
    fig, (ax1, ax2, ax3, ax4) = plt.subplots(4, 1, figsize=(6, 12),sharex=True,sharey=True)
    fig.subplots_adjust(hspace=0.1, left=0.15)
    x = np.linspace(-90, 90)
    
    ax1.scatter(alpha_coord, x_coord,label='Data')
    ax1.set_title('X Fitting')
    ax1.legend()
    
    ax2.scatter(alpha_coord, y_coord,label='Data')
    ax2.set_title('Y Fitting')
    ax2.legend()

    ax3.scatter(alpha_coord, z_coord,label='Data')
    ax3.set_title('Z Fitting')
    ax3.legend()
    
    ax4.scatter(alpha_coord, df_coord, label ='Data')
    ax4.set_title('Defocus Fitting')
    
    
    plt.tight_layout(pad=2.0)
    fig.text(0.5, 0.00, 'Angle (degrees)', ha='center')
    fig.text(0.00, 0.5, 'Location (microns)', va='center', rotation='vertical')
    
    # #Plot Curve Fit based on chosen model
    global modelSetting
    if(modelSetting == "L"):
        x_params, x_covar = optimize.curve_fit(fit_lin, alpha_coord, x_coord)
        y_params, y_covar = optimize.curve_fit(fit_lin, alpha_coord, y_coord)
        z_params, z_covar = optimize.curve_fit(fit_lin, alpha_coord, z_coord)
        df_params, df_covar = optimize.curve_fit(fit_lin,alpha_coord,df_coord)
            
        ax1.plot(x,fit_lin(x,x_params[0],x_params[1]),label='Fitted')
        ax2.plot(x,fit_lin(x,y_params[0],y_params[1]),label='Fitted')
        ax3.plot(x,fit_lin(x,z_params[0],z_params[1]),label='Fitted')
        ax4.plot(x,fit_lin(x,df_params[0],df_params[1]),label='Fitted')
        
        ax1.legend()
        ax2.legend()
        ax3.legend()
        ax4.legend()
    elif(modelSetting =="S"):
        x_params, x_covar = optimize.curve_fit(fit_cos, alpha_coord, x_coord,maxfev=5000)
        y_params, y_covar = optimize.curve_fit(fit_cos, alpha_coord, y_coord,maxfev=5000)
        z_params, z_covar = optimize.curve_fit(fit_cos, alpha_coord, z_coord,maxfev=5000)
        df_params, df_covar = optimize.curve_fit(fit_cos,alpha_coord,df_coord,maxfev=5000)
            
        ax1.plot(x,fit_cos(x,x_params[0],x_params[1],x_params[2],x_params[3]),label='Fitted')
        ax2.plot(x,fit_cos(x,y_params[0],y_params[1],y_params[2],y_params[3]),label='Fitted')
        ax3.plot(x,fit_cos(x,z_params[0],z_params[1],z_params[2],z_params[3]),label='Fitted')
        ax4.plot(x,fit_cos(x,df_params[0],df_params[1],df_params[2],df_params[3]),label='Fitted')
        
        ax1.legend()
        ax2.legend()
        ax3.legend()
        ax4.legend()
    else:
        print("Model choice not recognized")
        sys.exit()
        
    plt.show()
    
    global f
    try:
        f = open(outputPath, 'w')
    except FileNotFoundError:
        f = open(outputPath, 'x')

    
    np.savetxt(outputPath,(x_params, y_params, z_params,df_params),delimiter='\n')
    #xString = np.array2string(x_params)
    #yString = np.array2string(y_params)
    #zString = np.array2string(z_params)
    #f.write(xString)
    #f.write(yString)
    #f.write(zString)

    f.close()


def fit_lin(x, a, b):
    return a*x+b
def fit_cos(x,a,b,c,d):
	return a*np.cos(b*x*np.pi/180+c)+d

modelSetting = input("Sinusoidal (S) or Linear model (L)? Enter character: ")
#Time arbitrarily set right now, a break will be needed in actual use
for i in range(3): 

    check_coord()
    time.sleep(5)
    
    
