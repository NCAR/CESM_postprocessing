#!/usr/bin/env python2
"""
This module provides utility functions for working with the CESM 
$CASEROOT post-processing  XML files
__________________________
Created on Apr 30, 2014
Updated Sept 4, 2014 - make sure execute permission is allowed

@author: NCAR - CSEG
"""
import os
import platform
import re
import subprocess

#
# installed dependencies
#
try:
    import lxml.etree as etree
except:
    import xml.etree.ElementTree as etree

re_val = re.compile(r'\$(\{([A-Za-z0-9_]+)\}|[A-Za-z0-9_]+)')

#==============================================================================
# expand recursive function
#==============================================================================
def expand (val, src):
  """
  Recursively traverse the environment dictionary to expand all environment variables
  
  Arguments
  val (string) - value to be expanded
  src (dictionary) -  source dictionary to search and resolve param val

  Return
  expanded value
  """
  return re_val.sub(lambda m: expand(src.get(m.group(1), ''), src), val)

#==============================================================================
# readXML - read and resolve an XML input file against a source directory
#==============================================================================
def readXML(casedir, env_file_list):
  """
  for the <entry id=value> xml files in casedir/env_file_list,
  returns a dictionary output["id"]="value"

  Arguments:
  casedir (string) - case root directory
  env_file_list - list of env_*.xml files to parse in the casedir

  Return:
  output (dictionary) 
  """
  output = os.environ.copy()
  for efile in env_file_list:
    env_file = '{0}/{1}'.format(casedir, efile)
    if os.path.isfile(env_file):
      xml_tree = etree.ElementTree()
      xml_tree.parse(env_file)
      for entry_tag in xml_tree.findall('entry'):
        output[entry_tag.get('id')] = entry_tag.get('value')
    else:
      err_msg = 'cesmEnvLib.readXML ERROR: {0} does not exist or cannot be read'.format(env_file)
      raise TypeError(err_msg)

  # expand nested environment variables
  for k,v in output.iteritems():
    output[k] = expand(v, output)

  # remove () in output dictionary values
  for k,v in output.iteritems():
    output[k] = re.sub('[()]', '', v)
    
  return output

#======================================================================================
# setXmlEnv - iterate thru a given dictionary of the form id=value and set the os.environ
#======================================================================================
def setXmlEnv(indict):
  """
  Takes a dictionary and sets the shell environment
  
  Arguments:
  indict (dictionary) - id=value pairs used to set environment variables
  """
  for k,v in indict.iteritems():
##    print('setXMLenv debug: key = {0}, value = {1}'.format(k,v))
      if not isinstance(v, basestring):
          os.environ[k] = str(v)
      else:
          os.environ[k] = v


#==============================================
# checkEnv - check if a XML env var is defined 
# WARNING - this doesn't work in virtual env because of perl XML::LibXML!!!
#==============================================
def checkEnv(varname, relpath):
    """checkEnv - check if an env var is defined
    and if not, try to retrieve it from the casedir xmlquery 

    Arguments:
    varname (string) - env var name to check

    relpath (string) - path to the casedir where xmlquery resides
    """
    if not os.environ.get(varname):
        cwd = os.getcwd()
        os.chdir(relpath)

        rc, err_msg = checkFile('./xmlquery','exec')
        if not rc:
          raise OSError(err_msg)

        command = './xmlquery -valonly {0}'.format(varname)
        output = subprocess.check_output(['./xmlquery','-valonly',varname])
        xmllist = output.split(' ')
        os.environ[varname] = (xmllist.pop()).rstrip('\n')
        if not os.path.isdir(os.environ[varname]) :
          err_msg = 'cesmEnvLib.checkEnv ERROR: {0} enviroment variable is not valid or does not exist.'.format(varname)
          raise OSError(err_msg)
        os.chdir(cwd)

    return True


#=======================================================
# checkFile - check if a file exists and mode is allowed
#=======================================================
def checkFile(filename, mode):
    """checkFile - check if a file exists and if it is readable
    
    Arguments:
    filename (string) - input full path filename
    mode (string) - checks for access mode - valid values are read, write, exec
    
    Returns:
    rc - return True if file exists and is accessible by mode
         return False if file does not exist or is not accessible by mode
    err_msg (string) - error message
    """
    modedict = {'read':os.R_OK, 'write':os.W_OK, 'exec':os.X_OK}
    rc = True
    err_msg = ''
    if not os.path.isfile(filename):
        rc = False
        err_msg = 'cesmEnvLib.checkFile ERROR: {0} file is not available.'.format(filename)
    elif not os.access(filename, modedict[mode] ):
        rc = False
        err_msg = 'cesmEnvLib.checkFile ERROR: {0} file does not allow mode {1}.'.format(filename,mode)

    return (rc, err_msg)


#==========================================
# purge - delete files that match a pattern
#==========================================
def purge(dir, pattern):
    """purge - Remove files that match RE pattern in dir

    Arguments:
    dir (string) - directory name to work in
    pattern (string) - RE file pattern to delete from dir
    """
    for f in os.listdir(dir) :
        if re.search(pattern, f) :
            os.remove(os.path.join(dir, f))
    return


#===========================================
# which - check if a file is in the sys.path
#===========================================   
def which(program):

    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None

#===========================================   
# get_hostname
#===========================================   
def get_hostname():
    """ get_hostname
        return the platform hostname
    """
    hostname = platform.node()
    index = hostname.find(".")
    if index > 0:
        hostname = hostname[0:index]
    else:
        hostname = re.split('(\d+)',hostname)[0]

    return hostname


#===========================================   
# get_machine_name
#===========================================   
def get_machine_name(hostname, xmlFile):
    """ get_machine_xml - return the machine name
    from the xmlFile given the hostname.

    Return:
    machine (string) - machine name
    """
    machine = None
    rc, err_msg = checkFile(xmlFile, 'read')
    if rc:
        xml_tree = etree.ElementTree()
        xml_tree.parse(xmlFile)

        # find the matching machine name
        for xmlmachine in xml_tree.findall("machine"):
            xmlhostname = xmlmachine.get("hostname")
            if (hostname.lower() in xmlhostname.lower() or
                xmlhostname.lower() in hostname.lower()):
                    machine = xmlmachine.get("name").lower()

    return machine

