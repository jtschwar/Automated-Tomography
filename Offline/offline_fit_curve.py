from matplotlib import pyplot as plt
from scipy import optimize
import numpy as np 

#Theta(Degrees), Y-Coordinate(Micron)
coord = np.loadtxt('Coordinate.txt', delimiter=',', usecols=range(5))
print(coord)
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

# #Plot Fitted Model
x = np.linspace(-np.pi/2, np.pi/2)
plt.plot(x, fit_cos(x, params[0], params[1], params[2]), color='r', label='Fitted Function')

plt.xlabel('Theta (Radians)')
plt.ylabel('Y-Coordinate (Microns)')
plt.legend()
plt.show() 