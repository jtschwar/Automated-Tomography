from matplotlib import pyplot as plt
from scipy import optimize
import numpy as np 
import pysftp
import time
import os

#Tomography Directory.  
tomo_path = 'Jonathan Schwartz/server'

#Information to log into server. 
myHostname = 'emalserver.engin.umich.edu'
myUsername = 'emal'
myPassword = 'emalemal'
hovden_lab_path = '/Volumes/Old EMAL Server Data/NewEMALServer2/JEOL 3100R05/Users/Hovden_Lab/'
local_path = os.getcwd()
remote_path = hovden_lab_path + tomo_path

# Download coordinates.txt file from server.
sftp = pysftp.Connection(host=myHostname, username=myUsername, password=myPassword)
sftp.cwd(remote_path)

def check_coord():

    #Check if Coordinates has been updates. 
    for f in sftp.listdir_attr():

        if (f.filename == 'coordinates.txt'):
            if ((not os.path.isfile(f.filename)) or
                (f.st_mtime > os.path.getmtime(f.filename))):

                print("Downloading %s..." % f.filename)
                sftp.get(f.filename, f.filename)

                fit_curve()
                sftp.put('model_fit.txt', 'model_fit.txt')


def fit_curve():

    #Coordinates are saved as (x,y,z,alpha,beta) => (microns, degrees)
    coord = np.loadtxt('Coordinate.txt', delimiter=',', usecols=range(5))
    y_coord = coord[:,1]
    alpha_coord = coord[:,3] * np.pi/180

    #Plot Data Points. 
    plt.scatter(alpha_coord, y_coord, label='Data')

    # Curve Fitting
    params, params_covariance = optimize.curve_fit(fit_cos, alpha_coord, y_coord)
    np.savetxt('model_fit.txt', params) #Save parameters
    print('Fitted Parameters: ' + str(params))

    # #Plot Fitted Model
    x = np.linspace(-np.pi/2, np.pi/2)
    plt.plot(x, fit_cos(x, params[0], params[1], params[2]), color='r', label='Fitted Function')
    plt.xlabel('Theta (Radians)')
    plt.ylabel('Y-Coordinate (Microns)')
    plt.legend()
    plt.pause(0.0001)
    plt.clf()


#Functional Form
def fit_cos(x,a,b,c):
	return a*np.cos(b*x+c)

### Main loop #####
while True:
    
    check_coord()    
    time.sleep(5)

