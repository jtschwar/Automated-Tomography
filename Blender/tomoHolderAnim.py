#This code will allow for tilt and exportation of parameters for the region of interest sphere as transforms occur
import bpy

def ROIExport_v2():
    roi_object = bpy.data.objects["ROI"]
    world_matrix = roi_object.matrix_world.to_translation()
    return world_matrix

print(ROIExport_v2())

#MAIN CODE BODY

startFrame = 
#with file as open('Blend_Coord.txt',mode='w+'): 
    