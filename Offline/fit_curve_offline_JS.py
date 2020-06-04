from matplotlib import pyplot as plt
from scipy import optimize, stats
import time, os, sys
import numpy as np
np.seterr(divide='ignore')

# Pathing/Listening Information
local_path = os.getcwd()
myFile = 'Coordinate.txt'
fullpath = os.path.join(local_path, myFile)
myOutput = 'model_fit.txt'
outputPath = os.path.join(local_path, myOutput)
oldTime = 0

def error_plotting(myData,myAlpha,myAxis,myFunc,myFit):
    predict = ()
    bounding =((),())
    if myFit == 0:
        shiftGuess = myData[0]
        slopeGuess = 1
        predict=(slopeGuess,shiftGuess)
        bounding=((-np.inf,-np.inf),(np.inf,np.inf))
    elif myFit == 1:
        ampGuess = np.max((np.max(myData)-np.min(myData),10)) #Basic heuristic
        shiftGuess = np.mean((np.max(myData),np.min(myData)))
        predict=(ampGuess,1,0,shiftGuess)
        bounding=((-np.inf,.85,-np.inf,-np.inf),(np.inf,1.15,np.inf,np.inf))
    
    
    #Get Curve Fit using myFunc
    myParams,myCov = optimize.curve_fit(myFunc, myAlpha, myData,maxfev=10000,p0=predict,bounds=bounding)
    
    #Get R^2 
    modelPredictions = myFunc(myAlpha,*myParams)
    r2 = 1 - np.var(myData - modelPredictions) / np.var(myData)

    # Edge Case if there's no variance. 
    if r2 == -np.inf or r2 == np.nan: 
        r2 = 1

    myAxis.text(0.02,0.02,'R^2 = %.4f'%(r2),transform=myAxis.transAxes,multialignment='left')
 
    # Plot on given axis
    alphaFull = np.linspace(-90,90)
    myPrediction = myFunc(alphaFull,*myParams)
    myAxis.plot(alphaFull,myPrediction, label = "Model Fit")
    
    # Quantile of t distribution for 95%
    dof = np.size(myData) - np.size(myParams)
    t = stats.t.ppf(0.975, dof)

    residual = myData-modelPredictions
    chi2 = sum((residual/modelPredictions)**2)/dof
    s_err = np.sqrt(np.sum(residual**2)/dof)

    x = myAlpha
    x2 = alphaFull
    y2 = myPrediction

    # Plot Confidence Interval 
    n = len(myData)   
    ci = t * s_err * np.sqrt(1/n + (x2 - np.mean(x))**2 / np.sum((x - np.mean(x))**2))
    myAxis.fill_between(x2, y2 + ci, y2 - ci, color="gray", edgecolor="",label='Con. Int.',alpha = .20)

    # Plot Prediction Interval
    pi = t * s_err * np.sqrt(1 + 1/n + (x2 - np.mean(x))**2 / np.sum((x - np.mean(x))**2))   
    myAxis.plot(x2, y2 + pi, x2, y2 - pi, color="red", linestyle="--",label='Pred. Int.')

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
                fit_curve()
                oldTime = newTime


def fit_curve():
    # Coordinates are saved as (alpha,x,y,z,beta) => (microns, degrees)
    coord = np.loadtxt(fullpath, delimiter=',', usecols=range(8))
    if(coord.ndim == 1):
        print("Need more than one coordinate!")
        return    
    
    # Extra Coordinates from Experiment.
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
    
    fig.text(0.5, 0.00, 'Angle (degrees)', ha='center')
    fig.text(0.00, 0.5, 'Location (microns)', va='center', rotation='vertical')
    plt.tight_layout()

    # #Plot Curve Fit based on chosen model
    functionalFit = [fit_lin, fit_cos]
    if(modelSetting == "L"):
        if(len(x_coord) < 2):
            print("Too few points--need at least 2!\n")
            return
        fit = 0
            
    elif(modelSetting =="S"):
        if(len(x_coord) < 4):
            print("Too few points--need at least 4!\n")
            return
        fit = 1
        
    else:
        print("Model choice not recognized")
        sys.exit()

    # Plot Upper / Lower Bounds
    functionalFit = [fit_lin, fit_cos]
    x_params = error_plotting(x_coord,alpha_coord,ax1,functionalFit[fit],fit)
    y_params = error_plotting(y_coord,alpha_coord,ax2,functionalFit[fit],fit)
    z_params = error_plotting(z_coord,alpha_coord,ax3,functionalFit[fit],fit)
    df_params = error_plotting(df_coord,alpha_coord,ax4,functionalFit[fit],fit)
    ax4.legend(edgecolor='k')

    # Render the Figure
    #plt.pause(1)
    #plt.clf()
    
    plt_title = "plot_{}.png".format(len(x_coord))
    fig1 = plt.gcf()
    plt.show()
    fig1.savefig(plt_title)
    
    # Save model parameters. 
    # global f
    # try:
    #     f = open(outputPath, 'w')
    # except FileNotFoundError:
    #     f = open(outputPath, 'x')
    # np.savetxt(outputPath,(x_params, y_params, z_params,df_params),delimiter='\n')
    # f.close()

# Fit Linear Model
def fit_lin(x, a, b):
    return a*x+b

# Fit Cosine (Sinusoidal) Model
def fit_cos(x,a,b,c,d):
	return a*np.cos(b*x*np.pi/180+c)+d

# Input Desired Model.
modelSetting = input("Sinusoidal (S) or Linear model (L)? Enter character: ")

# Main Loop
for i in range(40): 

    check_coord()
    time.sleep(1)
