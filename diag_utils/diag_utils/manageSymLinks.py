from operator import itemgetter
import os
import traceback

try:
    import lxml.etree as etree
except:
    import xml.etree.ElementTree as etree

#
# installed dependencies
#
import jinja2
from cesm_utils import cesmEnvLib

class ManageSymLinks(object):

    def __init__(self):
        pass

    def create(self, comp, in_path):
        """
        Loop through the in_path creating symbolic links in given component path
        """
        

    def delete(self, comp):
        pass
