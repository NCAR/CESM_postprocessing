#!/usr/bin/env python2 

import pip
import pprint

installed_packages = pip.get_installed_distributions()
installed_packages_list = sorted(["%s==%s" % (i.key, i.version) for i in installed_packages])
pp = pprint.PrettyPrinter(indent=5)
pp.pprint(installed_packages_list)
