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

# -------------------------------------------------------------------------------
# XML processing classes
# -------------------------------------------------------------------------------
class XmlEntry(object):
    def __init__(self, id, value, desc):
        self._id = id
        self._value = value
        self._desc = desc

    def id(self):
        return self._id

    def value(self):
        return self._value

    def desc(self):
        return self._desc


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

    def xml_to_dict(self, xml_tree, envDict):
        """
        for the <entry id=value> xml files in casedir/env_file_list,
        returns a dictionary output["id"]="value"

        Arguments:
        casedir (string) - case root directory
        env_file_list - list of env_*.xml files to parse in the casedir

        Return:
        output (dictionary)
        """
        for entry_tag in xml_tree.findall('entry'):
            envDict[entry_tag.get('id')] = entry_tag.get('value')
    
    def write(self, envDict, comp, new_entry_id, new_entry_value):
        
        # assume writing env_postprocess.xml
        config_file = '{0}/Config/config_postprocess.xml'.format(envDict['POSTPROCESS_PATH'])
        template_file = 'env_postprocess.tmpl'
        env_file = '{0}/env_postprocess.xml'.format(envDict['PP_CASE_PATH'])

        if len(comp) > 0:
            if 'con' in comp:
                config_file = '{0}/Config/config_conform.xml'.format(envDict['POSTPROCESS_PATH'])
                template_file = 'env_postprocess.tmpl'
                env_file = '{0}/env_conform.xml'.format(envDict['PP_CASE_PATH'])
            else:
                # a component name was included in the entry_id so update env_diags_[comp].xml
                config_file = '{0}/diagnostics/diagnostics/{1}/Config/config_diags_{1}.xml'.format(envDict['POSTPROCESS_PATH'], comp)
                template_file = 'env_diags.tmpl'
                env_file = '{0}/env_diags_{1}.xml'.format(envDict['PP_CASE_PATH'], comp)

        # write out the correct file
        self.write_env_file(envDict, config_file, template_file, env_file, comp, new_entry_id, new_entry_value)


    def write_env_file(self, envDict, configFile, tmplFile, envFile, comp, new_entry_id, new_entry_value):
        """create the XML file in the CASEROOT

        Arguments:
        envDict (dictionary) - environment dictionary
        configFile (string) - full path to input config_[definition].xml file
        tmplFile (string) - template file for output [file].xml
        envFile (string) - output [file].xml name
        new_entry_id (string) - ID of value to be updated
        new_entry_value (string) - updated value
        """
        orig_env = dict()
        group_list = list()
        sorted_group_list = list()

        # check all the files are read and/or write
        rc, err_msg = cesmEnvLib.checkFile(configFile, 'read')
        if not rc:
            raise OSError(err_msg)
        
        rc, err_msg = cesmEnvLib.checkFile('{0}/Templates/{1}'.format(envDict['POSTPROCESS_PATH'], tmplFile), 'read')
        if not rc:
            raise OSError(err_msg)

        rc, err_msg = cesmEnvLib.checkFile(envFile, 'read')
        if not rc:
            raise OSError(err_msg)
        
        rc, err_msg = cesmEnvLib.checkFile(envFile, 'write')
        if not rc:
            raise OSError(err_msg)
         
        # read in the original env file
        orig_xml_tree = etree.ElementTree()
        orig_xml_tree.parse(envFile)

        for orig_entry_tag in orig_xml_tree.findall('entry'):
            orig_env[orig_entry_tag.get('id')] = orig_entry_tag.get('value')

        # load the original env file into a dict without expanding the values

        # read in the configFile
        xml_tree = etree.ElementTree()
        xml_tree.parse(configFile)

        for group_tag in xml_tree.findall('./groups/group'):
            xml_list = list()
            group_dict = dict()
            name = group_tag.get('name')
            order = int(group_tag.find('order').text)
            comment = group_tag.find('comment').text

            for entry_tag in group_tag.findall('entry'):
                if entry_tag.get('id') == new_entry_id:
                    xml_list.append(XmlEntry(new_entry_id,
                                             new_entry_value,
                                             entry_tag.get('desc')))
                else:
                    xml_list.append(XmlEntry(entry_tag.get('id'),
                                             orig_env[entry_tag.get('id')],
                                             entry_tag.get('desc')))

            group_dict = {'order': order,
                          'name': name,
                          'comment': comment,
                          'xml_list': xml_list}

            group_list.append(group_dict)

        sorted_group_list = sorted(group_list, key=itemgetter('order'))

        # add an additional entry for machine dependent input
        # observation files root path
        xml_list = list()
        if len(comp) > 0 and 'con' not in comp:
            if 'DIAGOBSROOT' in new_entry_id:
                xml_obs = XmlEntry('{0}DIAG_DIAGOBSROOT'.format(comp.upper()), 
                                   new_entry_value, 
                                   'Machine dependent diagnostics observation files root path')
            else:
                xml_obs = XmlEntry('{0}DIAG_DIAGOBSROOT'.format(comp.upper()), 
                                   orig_env['{0}DIAG_DIAGOBSROOT'.format(comp.upper())],
                                   'Machine dependent diagnostics observation files root path')
            xml_list.append(xml_obs)

        # the xml_list now contains a list of XmlEntry classes that
        # can be written to the template
        templateLoader = jinja2.FileSystemLoader(
            searchpath='{0}/Templates'.format(envDict['POSTPROCESS_PATH']))
        templateEnv = jinja2.Environment(loader=templateLoader)

        template = templateEnv.get_template(tmplFile)
        templateVars = { 'xml_list' : xml_list,
                         'group_list' : sorted_group_list }

        # render the template
        env_tmpl = template.render(templateVars)

        # write the env_file
        with open(envFile, 'w') as xml:
            xml.write(env_tmpl)

class PostProcessingXML_v2(PostProcessingXML):
    """

    """
    def __init__(self, version_list):
        """NOTE(bja, 201605) Backward compatible minor oversions. Not sure if
        they need special logic....

        """
        msg = "CIME xml v2 spec has not been implemented."
        raise RuntimeError(msg)

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
        pass

    def write(self, tree, filename):
        """TODO(bja, 201605) jinja2 processing here
        """
        pass


# -------------------------------------------------------------------------------
# XML processing factory
# -------------------------------------------------------------------------------
def post_processing_xml_factory(xml_tree):
    """Determine what version of the xml file we are using and create the
    appropriate class

    NOTE(bja, 201605) pseudo code, actual xml queries will depend on actual xml

    """
    processor = None
    version = xml_tree.findall('./config_definition[@version]')
    if len(version) == 1:
        version_list = version[0].split('.')
        major_version = version_list[0]
        if (major_version == '2'):
            processor = PostProcessingXML_v2(version_list)
        else:
            # Unsupported version, error!
            msg = "ERROR: Unsupported XML version : {0}".format(major_version)
            raise RuntimeError(msg)
    elif len(version) == 0:
        processor = PostProcessingXML_v1()
    else:
        # would valid xml have multiple version tags...?
        raise RuntimeError("pp_config ERROR: XML file has multiple version tags!")
    if not processor:
        raise RuntimeError("pp_config ERROR: couldn't create xml processing class!")
    return processor
