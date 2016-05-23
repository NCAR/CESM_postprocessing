# -*- mode: Makefile -*-
#
# NOTES:
#
# - To use virtualenv in a make file:
#
#	. test-env/bin/activate; pip install grako
#
#   I don't think we want to do that because we want to use a
#   requirements.txt file.
#
# - On machine without virtualenv
#
#   pip install --user virtualenv
#   export PATH=$(PATH):$(HOME)/.local/bin
#   virtualenv --system-site-packages ENVNAME
#
ENVNAME=cesm-env2

SUBDIRS = \
	cesm_utils \
	diag_utils \
	mpi_utils \
	reshaper \
	averager \
	timeseries \
	diagnostics \

# MAKECMDGOALS is the make option: make 'clobber' or 'all'
TARGET = $(MAKECMDGOALS)

# if target is undefined (i.e. MAKECMDGOALS is undefined), target = all
ifeq (,$(TARGET))
	TARGET = all
endif

#
# macro for executing TARGET in all SUBDIRS
#
ifdef SUBDIRS
$(SUBDIRS) : FORCE
	@if [ -d $@ ]; then \
		$(MAKE) --directory=$@ $(TARGET); \
	fi	
	@echo Build complete: $@ : $(TARGET) : $(shell date)
endif	

#
# all - Make everything in the listed sub directories
#

all : $(SUBDIRS)

test : all py-unit

py-unit : FORCE
	python -m unittest discover
	PYTHONPATH="${PYTHONPATH}:.." python -m unittest discover

#
# virtual environments and installation
#
#env : cesm-env2 cesm-env3

env : $(ENVNAME)/bin/activate

$(ENVNAME)/bin/activate : 
	virtualenv --system-site-packages -p python2 $(ENVNAME)

cesm-env2 :
	virtualenv -p python2 $@

cesm-env3 :
	virtualenv -p python3 $@

#env-conda : anaconda python version installation of virtaul env
env-conda : 
	conda create -p ./$(ENVNAME) python=2.7 anaconda

cesm-env2-conda :
#	virtualenv -p python2 $@

cesm-env3-conda :
#	virtualenv -p python3 $@


develop : $(SUBDIRS)

install : $(SUBDIRS)

#
# release info
#
#version : FORCE
#	@git describe --always 2>/dev/null > VERSION

#
# clean - Clean up the directory.
#
clean : $(SUBDIRS)
	-rm -f *~ *.CKP *.ln *.BAK *.bak .*.bak \
		core errs \
		,* .emacs_* \
		tags TAGS \
		make.log MakeOut \
		*.tmp tmp.txt

#
# clobber - Really clean up the directory.
#
clobber : clean $(SUBDIRS)
	-rm -f .Makedepend *.o *.mod *.il *.pyc *.so
	-rm -rf *.egg-info build


clobber-env : FORCE
	-rm -rf cesm-env2
#	-rm -rf cesm-env2 cesm-env3 

#
# FORCE - Null rule to force things to happen.
#
FORCE :

