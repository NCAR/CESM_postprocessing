import os, glob, datetime

def create_plotset_html(html_file, new_fn, env):

    # Suffix of image files
    img_t = env['PLOT_FORMAT']

    # If new htm file exists, remove it
    if os.path.isfile(new_fn):
        os.remove(new_fn)
    new_html = open(new_fn,'w')
    print('DEBUG: create_ice_html new_html = {0}'.format(new_html))

    web_path = os.path.dirname(new_fn)+'/'
    print('DEBUG: create_ice_html web_path = {0}'.format(web_path))

    # Open html template
    print('DEBUG: create_ice_html html_file = {0}'.format(html_file))
    data = open(html_file)

    # Loop through lines in partial html file.  If a href (image link) check to see
    # if image exists and handle correctly
    for line in data.readlines():
        if 'CASENAME' in line:
            line = line.replace('CASENAME',env['CASE_TO_CONT'])
        elif 'HREF' in line:
            # Split the element up
            elements = line.split('>')
            i = 0
            for elem in elements:
                if 'HREF' in elem:
                    link_tag_parts = elements[i].split('HREF=')
                    image_name = link_tag_parts[1].replace('\"','')
                i = i+1
            if 'png' in image_name:
                image_name = image_name.replace('png',img_t)
                if not os.path.isfile(web_path+'/'+image_name):
                    print("NOT FOUND: "+web_path+'/'+image_name)
                    for ln in ('JFM','AMJ','JAS','OND','ANN','FM','ON','plot'):
                        if ln in line:
                            line = line.replace(ln,'----')
                else:
                    line = line.replace('png',img_t)

        new_html.write(line)
    new_html.write('<b> Plots Created </b><br>')
    date = datetime.datetime.now().strftime("%a %b %d %H:%M:%S %Y")
    new_html.write(date)
    new_html.close()
