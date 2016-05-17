#!/usr/bin/env python
"""FIXME: A nice python program to do something useful.

Author: Ben Andre <andre@ucar.edu>

"""

from __future__ import print_function

import sys

if sys.hexversion < 0x02070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 2.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

#
# built-in modules
#
import argparse
import os
import traceback

import xml.etree.ElementTree as ET


if sys.version_info[0] == 2:
    from ConfigParser import SafeConfigParser as config_parser
else:
    from configparser import ConfigParser as config_parser

#
# installed dependencies
#

#
# other modules in this package
#


# -------------------------------------------------------------------------------
#
# XML processing classes
#
# -------------------------------------------------------------------------------
class PostProcessingXML(object):
    """NOTE(bja, 201605) not sure how much resuable code there will be
    between different xml versions.

    """

    prefix_map = []

    def __init__(self):
        """
        """
        pass


class PostProcessingXML_v1(PostProcessingXML):
    """
    """
    def __init__(self):
        """
        """
        """
        NOTE(bja, 201605) v1 doesn't have sub-versions to worry about.
        """
        pass

    def xml_to_dict(self, tree, envDict):
        """
        """
        for entry_tag in xml_tree.findall('entry'):
            envDict[entry_tag.get('id')] = entry_tag.get('value')
        # expand and cleanup?

    def write(self, tree, filename):
        """TODO(bja, 201605) jinja2 processing here
        """
        pass


class PostProcessingXML_v2(PostProcessingXML):
    """

    """
    def __init__(self, version_list):
        """NOTE(bja, 201605) Backward compatible minor oversions. Not sure if
        they need special logic....

        """
        self._minor_version = None
        self._patch_version = None

        if len(version_list) > 1:
            self._minor_version = version_list[1]
        if len(version_list) > 2:
            self._minor_version = version_list[2:]

    def xml_to_dict(self, tree, envDict):
        """NOTE(bja, 201605) not sure how the groups are handled here.... Are
        they going into the dict?

        """
        for entry_group in xml_tree.findall('group'):
            for entry_tag in xml_tree.findall('entry'):
                envDict[entry_tag.get('id')] = entry_tag.get('value')
        # expand and cleanup?

    def write(self, tree, filename):
        """TODO(bja, 201605) jinja2 processing here
        """
        pass


# -------------------------------------------------------------------------------
#
# XML processing factory
#
# -------------------------------------------------------------------------------
def post_processing_xml_factory(xml_tree):
    """Determine what version of the xml file we are using and create the
    appropriate class

    NOTE(bja, 201605) pseudo code, actual xml queries will depend on actual xml

    """
    processor = None
    version = xml_tree.findall('/cime_xml_version[@version]')
    if len(version) == 1:
        version_list = version[0].split('.')
        major_version = version_list[0]
        if (major_version == '2'):
            processor = PostProcessingXML_v2(version_list)
        else:
            # Unsupported version, error!
            raise RuntimeError("ERROR: Unsupported XML version : {0}".format(major_version))
    elif len(version) == 0:
        processor = PostProcessingXML_v1()
    else:
        # would valid xml have multiple version tags...?
        raise RuntimeError("ERROR: XML file has multiple version tags!")
    if !processor:
        raise RuntimeError("ERROR: couldn't create xml processing class!")
    return processor

# -------------------------------------------------------------------------------
#
# dummy main, this would go into pp_var_get and pp_var_set
#
# -------------------------------------------------------------------------------
def main():
    # FIXME(bja, 201605) should actually generate from a glob?
    xml_filenames = ['env_postprocess.xml', 'env_run.xml']
    # FIXME(bja, 201605) verify the file exists if hard coded list....

    case_dir = '/path/to/case/dir'
    xml_trees = []
    for filename in xml_filenames:
        file_path = os.path.join(case_dir, filename)
        file_path = os.path.abspath(file_path)
        xml_trees.append(ET.parse(file_path).getroot())

    # FIXME(bja, 201605) do we want to assume all files are the same xml version?
    xml_processor = post_processing_xml_factory(xml_trees[0])

    envDict = {}
    for tree in xml_trees:
        xml_processor.xml_to_dict(tree, envDict)

    #
    # 'get' user input
    #
    entry_id = "DIAG_PREFIX_some_tag"
    print("{0} = {1}".format(entry_id, envDict[entry_id]))

    #
    # 'set' user input
    #
    entry_id = 'DIAG_PREFIX_some_tag'
    entry_value = 'some_value'
    envDict[entry_id] = entry_value

    xml_processor.write(envDict)


if __name__ == "__main__":
    try:
        status = main()
        sys.exit(status)
    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)
