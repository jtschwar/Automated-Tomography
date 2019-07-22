from matplotlib import pyplot as plt
from scipy import optimize
import numpy as np 

#Theta(Degrees), Y-Coordinate(Micron)
coord = np.loadtxt('y_coordinates.txt', delimiter=',', usecols=range(2))

#Convert from Degrees or Radians. 
coord[:,0] *= np.pi/180

#Plot Data Points. 
plt.scatter(coord[:,0], coord[:,1], label='Data')

#Functional Form
def fit_cos(x,a,b,c):
	return a*np.cos(b*x+c)

# Curve Fitting
params, params_covariance = optimize.curve_fit(fit_cos, coord[:,0], coord[:,1])
print('Fitted Parameters' + str(params))

# #Plot Fitted Model
x = np.linspace(-np.pi/2, np.pi/2)
plt.plot(x, fit_cos(x, params[0], params[1], params[2]), color='r', label='Fitted Function')

plt.xlabel('Theta (Radians)')
plt.ylabel('Y-Coordinate (Microns)')
plt.legend()
plt.show()