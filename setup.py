#!/usr/bin/env python
from setuptools import setup
from codecs import open
import subprocess
import os

VERSION    = '2.3'

def git_version():
    """
    Return the sha1 of local git HEAD as a string.
    """
    def _minimal_ext_cmd(cmd):
        # construct minimal environment
        env = {}
        for k in ['SYSTEMROOT', 'PATH', 'PYTHONPATH']:
            v = os.environ.get(k)
            if v is not None:
                env[k] = v
        # LANGUAGE is used on win32
        env['LANGUAGE'] = 'C'
        env['LANG'] = 'C'
        env['LC_ALL'] = 'C'
        out = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            env=env
        ).communicate()[0]
        return out
    try:
        out = _minimal_ext_cmd(['git', 'rev-parse', 'HEAD'])
        git_revision = out.strip().decode('ascii')
    except OSError:
        git_revision = "unknown-git"
    return git_revision

def write_text(filename, text):
    try:
        with open(filename, 'w') as a:
            a.write(text)
    except Exception as e:
        print(e)
        
def write_version_py(filename=os.path.join('src/ILAMB', 'generated_version.py')):
    cnt = """
# THIS FILE IS GENERATED FROM ILAMB SETUP.PY
short_version = '%(version)s'
version = '%(version)s'
git_revision = '%(git_revision)s'
full_version = '%(version)s (%%(git_revision)s)' %% {
    'git_revision': git_revision}
release = %(isrelease)s
if not release:
    version = full_version
"""
    FULL_VERSION = VERSION
    if os.path.isdir('.git'):
        GIT_REVISION = git_version()
        ISRELEASED   = False
    else:
        GIT_REVISION = "RELEASE"
        ISRELEASED   = True

    FULL_VERSION += '.dev-' + GIT_REVISION
    text = cnt % {'version': VERSION,
                  'full_version': FULL_VERSION,
                  'git_revision': GIT_REVISION,
                  'isrelease': str(ISRELEASED)}
    write_text(filename, text)

    
here = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(here, 'README.rst'), encoding='utf-8') as f:
    long_description = f.read()

write_version_py()    
setup(
    name='ILAMB',
    version=VERSION,
    description='The International Land Model Benchmarking Package',
    long_description=long_description,
    url='https://bitbucket.org/ncollier/ilamb',
    author='Nathan Collier',
    author_email='nathaniel.collier@gmail.com',
    #license='MIT',
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Science/Research',
        'Topic :: Scientific/Engineering',
        #'License :: OSI Approved :: MIT License',
        'Operating System :: MacOS',
        'Operating System :: POSIX',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
    ],
    keywords=['benchmarking','earth system modeling','climate modeling','model intercomparison'],
    packages=['ILAMB'],
    package_dir={'ILAMB' : 'src/ILAMB'},
    scripts=['bin/ilamb-run','bin/ilamb-fetch','bin/ilamb-mean','bin/ilamb-doctor','bin/ilamb-table'],
    install_requires=['numpy>=1.11.0',
                      'matplotlib>=1.4.3',
                      #'basemap>=1.0.7', # basemap is in pypi but broken, need to manually install
                      'netCDF4>=1.1.4',
                      'cf_units>=2.0.0',
                      'sympy>=0.7.6',
                      'mpi4py>=1.3.1',
                      'scipy>=0.9.0']
)
