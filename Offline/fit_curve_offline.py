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

    #Coordinates are saved as (alpha,x,y,z,beta) => (microns, degrees)
    coord = np.loadtxt('coordinates.txt', delimiter=',', usecols=range(5))
    alpha_coord = coord[:,0]
    x_coord = coord[:,1]
    y_coord = coord[:,2]
    z_coord = coord[:,3]
    

    # # Curve Fitting
    defocus_params, _ = optimize.curve_fit(fit_defocus, alpha_coord, z_coord, p0=(alpha_coord[-1], z_coord[-1]))
    n0 = defocus_params[0]*10**3 
    print('n0: ' + str(n0) + '[nm]  df0: ' + str(df0))
    df0 = defocus_params[1]*10**3

    x_params, _ = optimize.curve_fit(fit_x, alpha_coord, x_coord, bounds=(0,[n0*2, df0*2, np.pi/30]))
    y_params, _ = optimize.curve_fit(fit_y, alpha_coord, y_coord, bounds=(0,[n0*2, df0*2, np.pi/30]))
    print('Parameter order: 1. n0, 2. df0, 3. theta')
    print(x_params)
    print(y_params)

    df_form = r'$dF = n0sin(\theta) + df0cos(\theta)$'
    x_form = r'$X = n0cos(\theta)cos(\alpha) - df0sin(\theta)cos(\alpha)$'
    y_form = r'$Y = n0sin(\theta)sin(\alpha) - df0cos(\theta)sin(\alpha)$'

    # #Plot Fitted Model
    fig, (ax1, ax2, ax3) = plt.subplots(3,1, figsize=(6,6))
    fig.subplots_adjust(hspace=0.1,left=0.15)
    x = np.linspace(-90, 90)

    #Plot X - Coordinate
    ax1.scatter(alpha_coord, x_coord, label='Data')
    ax1.plot(x,fit_lin(x, lin_params[0], lin_params[1]), color='r', label='Fitted Function')
    ax1.set_ylabel('X-Coordinate (Microns)',fontweight='bold', fontsize=11)
    ax1.set_xticklabels([])
    ax1.set_title(lin_form,loc='left',fontsize=10)
    ax1.legend()

    #Plot Data Points. 
    ax2.scatter(alpha_coord, y_coord, label='Data')
    ax2.plot(x, fit_cos(x, cos_params[0], cos_params[1], cos_params[2]), color='r', label='Fitted Function')
    ax2.set_xlabel('Tilt Angle (Degrees)',fontweight='bold', fontsize=11)
    ax2.set_ylabel('Y-Coordinate (Microns)',fontweight='bold', fontsize=11)
    ax2.set_title(cos_form,loc='left',fontsize=10)

    plt.tight_layout()
    plt.pause(5)
    plt.close(fig)

#Functional Form
def fit_defocus(x,a,b):
    # a is the original offset between tilt and optical axis
    # b is the defocus at starting tilt (theta = 0)
	return a*np.sin(x*np.pi/180) + b*np.cos(x*np.pi/180)

def fit_x(x,a,b,c):
    # a is the original offset between tilt and optical axis
    # b is the defocus at starting tilt (theta = 0)
    # c is the tilt axis misalignment
    return (a*np.cos(x*np.pi/180) - b*np.sin(x*np.pi/180))*np.cos(c)

def fit_y(x,a,b):
    # a is the original offset between tilt and optical axis
    # b is the defocus at starting tilt (theta = 0)
    # c is the tilt axis misalignment
    return (a*np.sin(x*np.pi/180) - b*np.cos(x*np.pi/180))*np.sin(c)



### Main loop #####
while True:
    
    check_coord()    
    time.sleep(5)

