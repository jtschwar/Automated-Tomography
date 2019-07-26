from matplotlib import pyplot as plt
from scipy import optimize
import numpy as np 
import pysftp
import os

#Tomography Directory.  
tomo_dir = 'Jonathan/XXXXX'

#Information to log into server. 
myHostname = 'emalserver.engin.umich.edu'
myUsername = 'emal'
myPassword = 'emalemal'
hovden_lab_dir = '/Volumes/Old EMAL Server Data/NewEMALServer2/JEOL 3100R05/Users/Hovden_Lab/'
local_dir = os.getcwd()

# Download coordinates.txt file from server.
with pysftp.Connection(host=myHostname, username=myUsername, password=myPassword) as sftp:
	print("Downloading Coordinates Text File")

	##Download Coordinates. 
	sftp.get(hovden_lab_dir + tomo_dir, local_dir + '/coordinates.txt')

#Coordinates are saved as (x,y,z,alpha,beta) => (microns, degrees)
coord = np.loadtxt('coordinates.txt', delimiter=',', usecols=range(5))
y_coord = coord[:,1]
alpha_coord = coord[:,3] * np.pi/180

#Plot Data Points. 
plt.scatter(alpha_coord, y_coord, label='Data')

#Functional Form
def fit_cos(x,a,b,c):
	return a*np.cos(b*x+c)

# Curve Fitting
params, params_covariance = optimize.curve_fit(fit_cos, alpha_coord, y_coord)
np.savetxt('model_fit.txt', params) #Save parameters
print('Fitted Parameters: ' + str(params))

# Upload coordinates.txt file to server.
with pysftp.Connection(host=myHostname, username=myUsername, password=myPassword) as sftp:
	print("Uploading Model-Parameters")

	##Upload model_fix.txt. 
	sftp.put(local_dir + '/model_fit.txt', hovden_lab_dir + tomo_dir + '/model_fit.txt')

# #Plot Fitted Model
x = np.linspace(-np.pi/2, np.pi/2)
plt.plot(x, fit_cos(x, params[0], params[1], params[2]), color='r', label='Fitted Function')
plt.xlabel('Theta (Radians)')
plt.ylabel('Y-Coordinate (Microns)')
plt.legend()
plt.show()
