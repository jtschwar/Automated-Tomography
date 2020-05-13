# -*- coding: utf-8 -*-
"""
Created on Fri Sep  6 15:43:05 2019

@author: jacob
"""

from matplotlib import pyplot as plt
import numpy as np

coord = np.loadtxt('Blender_Coord.txt', delimiter=',', usecols=range(3))
x_coord = coord[:,0]
y_coord = coord[:,1]
z_coord = coord[:,2]
frame = list(range(1,360+1))

fig, (ax1,ax2,ax3,ax4) = plt.subplots(4,1, figsize=(6,6))
fig.subplots_adjust(hspace=0.1,left=0.15)

x = np.linspace(-90, 90)
ax1.scatter(frame, x_coord, label='Data')
ax1.set_ylabel('X-Position',fontweight='bold', fontsize=11)
ax1.set_xticklabels([])
ax1.legend()

ax2.scatter(frame,y_coord,label='Data')
ax2.set_ylabel('Y-Position',fontweight='bold',fontsize=11)
ax2.set_xticklabels([])
ax2.legend()

ax3.scatter(frame,z_coord,label='Data')
ax3.set_ylabel('Z-Position',fontweight='bold',fontsize=11)
ax3.set_xticklabels([])
ax3.set_xlabel('Frame',fontweight='bold',fontsize=11)
ax3.legend()

ax4.scatter(x_coord,z_coord)
plt.tight_fit()
plt.show()