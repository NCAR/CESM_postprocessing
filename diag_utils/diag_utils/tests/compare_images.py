import glob
import os
from itertools import izip
import Image

def compare(t_path, c_path, image):
    
    ti = t_path+'/'+image
    ci = c_path+'/'+image

    if os.path.isfile(ti) and os.path.isfile(ci):
        i1 = Image.open(ti)
        i2 = Image.open(ci)

        pairs = izip(i1.getdata(), i2.getdata())
        dif = sum(abs(c1-c2) for p1,p2 in pairs for c1,c2 in zip(p1,p2))
        ncomponents = i1.size[0] * i1.size[1] * 3

        difference = (dif / 255.0 * 100) / ncomponents
        if difference > 1:
            print "Difference in ",image," (percentage):", difference
    else:
        print 'File ',image, 'does not exist in one case.'

##################### User Set #########################################
cont = '/Users/mickelso/Desktop/new_diags/images_to_compare/old_images/' 
test = '/Users/mickelso/Desktop/new_diags/images_to_compare/new_images/' 
########################################################################

images = glob.glob(cont+'/*.png')

for image in images:
    split_n = image.split('/')
    fn = split_n[-1]
    compare(test, cont, fn) 

tables = glob.glob(cont+'/*.asc')
for table in tables:
    split_n = table.split('/')
    fn = split_n[-1]
    command = 'diff '+cont+'/'+fn+' '+test+'/'+fn
    print command
    os.system(command)

