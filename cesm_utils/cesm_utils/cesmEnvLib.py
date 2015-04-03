#!/usr/bin/env python2
"""
This module provides utility functions for working with the $CASEROOT/env_*.xml files
except the env_archive.xml file which is parsed in the cesm_tseries_generate.py
__________________________
Created on Apr 30, 2014
Updated Sept 4, 2014 - make sure execute permission is allowed

@author: NCAR - CSEG
"""
import os
import re
import xml.etree.ElementTree as ET

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
      xml_tree = ET.ElementTree()
      xml_tree.parse(env_file)
      for entry_tag in xml_tree.findall('entry'):
        output[entry_tag.get('id')] = entry_tag.get('value')
    else:
      err_msg = 'cesmEnvLib.py ERROR: {0} does not exist or cannot be read'.format(env_file)
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
    os.environ[k] = v
