import os, urllib, glob, datetime

def create_plotset_html(html_file_prefix,web_path,set_name, env):

    # Suffix of image files
    img_t = env['p_type']

    # Get list of htm files that will need to be combined
    html_files = glob.glob(html_file_prefix+'*')

    # Derive the new htm file name
    if 'sets' in set_name:
        new_fn =  web_path + '/index.html'
    else:
        new_fn = web_path + '/' + set_name + '.htm'
   
    # If new htm file exists, remove it
    if os.path.isfile(new_fn): 
        os.remove(new_fn)
    new_html = open(new_fn,'w')

    if env['MODEL_VS_OBS'] == 'True':
        title = env['test_casename'] + '<br>and<br> OBS data (<a href="http://climatedataguide.ucar.edu/category/data-set-variables/model-diagnostics/atmosdiagnostics">info</a>)'
    else:
        title = env['test_casename'] + '<br>and<br>' + env['cntl_casename']

    # Loop through web files and append correctly
    for n in range(1,len(html_files)+1):
        html_file = html_file_prefix+'_'+str(n)+'.htm' 
        data = urllib.urlopen(html_file)

        # Loop through lines in partial html file.  If a href (image link) check to see 
        # if image exists and handle correctly
        for line in data.readlines():
            if 'sets' in set_name:
                if 'test_run' in line:
                    line = line.replace('test_run',title)
                elif 'test_ctrl_runs' in line:
                    line = line.replace('test_ctrl_runs',title)
                   
            elif n > 1:
                if 'HREF' in line:
                    # Split the element up    
                    elements = line.split('>')
                    i = 0
                    for elem in elements:
                        if 'HREF' in elem:
                            link_tag_parts = elements[i].split('HREF=')
                            image_name = link_tag_parts[1].replace('\"','')
                        i = i+1 
                    if 'xxx' in image_name:
                        image_name = image_name.replace('xxx',img_t)
                        if not os.path.isfile(web_path+'/'+image_name):
                            line = line.replace('plot','----') 
                        else:
                            line = line.replace('xxx',img_t)
         
            new_html.write(line)
        if n == 1:
            if 'sets' in set_name:
                new_html.write('<b> Plots Created </b><br>')
                date = datetime.datetime.now().strftime("%a %b %d %H:%M:%S %Y")
                new_html.write(date)
            else:
                new_html.write(title)
    new_html.close() 

