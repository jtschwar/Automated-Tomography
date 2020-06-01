from matplotlib import pyplot as plt
from scipy import optimize
import numpy as np
import time
import os
import sys
import uncertainties.unumpy as unp
import uncertainties as unc


# Pathing/Listening Information
local_path = os.getcwd()
myFile = 'Coordinate.txt'
fullpath = os.path.join(local_path, myFile)
myOutput = 'model_fit.txt'
outputPath = os.path.join(local_path, myOutput)
oldTime = 0

def error_plotting(myData,myAlpha,myAxis,myFunc):
    #Get Curve Fit using function
    myParams,myCov = optimize.curve_fit(myFunc, myAlpha,myData,maxfev=5000)
    
    #Get RMSE and Rsquared by math defintion
    modelPredictions = myFunc(myAlpha,*myParams)
    absError = modelPredictions - myData
    squareError = np.square(absError)
    meansquareError = np.mean(squareError)
    rootmeansquareError = np.sqrt(meansquareError) #np.sqrt(((modelPredictions-myData)**2).mean())
    
    
    Rsquared = 1.0 - (np.var(absError)/np.var(myData))
    
    # Plot on given axis
    alpha_full = np.linspace(-90,90)
    myAxis.plot(alpha_full,myFunc(alpha_full,*myParams), label = "Fitted")
    myAxis.set(ylim=(min(myData),max(myData)))
    
    myAxis.legend(loc='upper right')
    myAxis.text(0.5,0.1,'R^2 = %.4f\nRMSE = %.4f'%(Rsquared,rootmeansquareError),va='center',ha='center',transform=myAxis.transAxes,multialignment='left')
    
    ##Confidence Interval Code
    #myCorr = unc.correlated_values(myParams, myCov)
    #print(myCorr)
    #py = myFunc(alpha_full,*myCorr)
    #nom = unp.nominal_values(py)
    #std = unp.std_devs(py)  
    #myAxis.fill_between(alpha_full, nom - 1.96*std,nom+1.96*std, color = "black", alpha=.15)

    
    return myParams
    
    

def check_coord():

    # Check for Updates
    for file in os.listdir():

        if(file == myFile):
            fileOBJ = os.stat(fullpath)
            newTime = fileOBJ.st_mtime
            global oldTime
            if(newTime != oldTime):
                print("Modifications Detected; remodel...")
                fit_curve(newTime)
                oldTime = newTime


def fit_curve(newTime):
    # Coordinates are saved as (alpha,x,y,z,beta) => (microns, degrees)
    coord = np.loadtxt(fullpath, delimiter=',', usecols=range(8))
    if(coord.ndim == 1):
        print("Need more than one coordinate!")
        return
    
    
    x_coord = coord[:, 0]
    y_coord = coord[:, 1]
    z_coord = coord[:, 2]
    alpha_coord = coord[:, 3]
    df_coord = coord[:,5]

    # #Plot Data Model
    fig, (ax1, ax2, ax3, ax4) = plt.subplots(4, 1, figsize=(6, 12))
    fig.subplots_adjust(hspace=0.1, left=0.15)
    x = np.linspace(-90, 90)
    
    ax1.scatter(alpha_coord, x_coord,label='Data')
    ax1.set_title('X Fitting')
    
    ax2.scatter(alpha_coord, y_coord,label='Data')
    ax2.set_title('Y Fitting')

    ax3.scatter(alpha_coord, z_coord,label='Data')
    ax3.set_title('Z Fitting')
    
    ax4.scatter(alpha_coord, df_coord, label ='Data')
    ax4.set_title('Defocus Fitting')
    
    
    plt.tight_layout(pad=2.0)
    fig.text(0.5, 0.00, 'Angle (degrees)', ha='center')
    fig.text(0.00, 0.5, 'Location (microns)', va='center', rotation='vertical')
    
    # #Plot Curve Fit based on chosen model
    global modelSetting
    if(modelSetting == "L"):
        if(len(x_coord) < 2):
            print("Too few points--need at least 2!\n")
            return
        x_params = error_plotting(x_coord,alpha_coord,ax1,fit_lin)
        y_params = error_plotting(y_coord,alpha_coord,ax2,fit_lin)
        z_params = error_plotting(z_coord,alpha_coord,ax3,fit_lin)
        df_params = error_plotting(df_coord,alpha_coord,ax4,fit_lin)
            
    elif(modelSetting =="S"):
        if(len(x_coord) < 4):
            print("Too few points--need at least 4!\n")
            return
        x_params = error_plotting(x_coord,alpha_coord,ax1,fit_cos)
        y_params = error_plotting(y_coord,alpha_coord,ax2,fit_cos)
        z_params = error_plotting(z_coord,alpha_coord,ax3,fit_cos)
        df_params = error_plotting(df_coord,alpha_coord,ax4,fit_cos)
        
    else:
        print("Model choice not recognized")
        sys.exit()
    
    plt_title = "plot_{}.png".format(len(x_coord))
    fig1 = plt.gcf()
    plt.show()
    fig1.savefig(plt_title)
    
    global f
    try:
        f = open(outputPath, 'w')
    except FileNotFoundError:
        f = open(outputPath, 'x')

    
    np.savetxt(outputPath,(x_params, y_params, z_params,df_params),delimiter='\n')

    f.close()


def fit_lin(x, a, b):
    return a*x+b
def fit_cos(x,a,b,c,d):
	return a*np.cos(b*x*np.pi/180+c)+d

modelSetting = input("Sinusoidal (S) or Linear model (L)? Enter character: ")
#Time arbitrarily set right now, a break will be needed in actual use
for i in range(1): 

    check_coord()
    time.sleep(5)
    
    
