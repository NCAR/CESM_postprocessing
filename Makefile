SRC_SUBDIRS = \
	cesm_utils 
#	pyTools \
#	pyReshaper \
#	pyAverager \
#	timeseries \
#	diagnostics \
#	ocn_diag

# MAKECMDGOALS is the make option: make 'clobber' or 'all'
TARGET = $(MAKECMDGOALS)

# if target is undefined (i.e. MAKECMDGOALS is undefined), target = all
ifeq (,$(TARGET))
	TARGET = all
endif

#
# macro for executing TARGET in all SUBDIRS
#
ifdef SRC_SUBDIRS
$(SRC_SUBDIRS) : FORCE
	@if [ -d $@ ]; then \
		$(MAKE) --directory=$@ $(TARGET); \
	fi	
	@echo Build complete: $@ : $(TARGET) : $(shell date)
endif	

#
# all - Make everything in the listed sub directories
#
#all : $(SRC_SUBDIRS)
all :

#test : all py-unit

#py-unit : FORCE
#	python -m unittest discover
#	PYTHONPATH="${PYTHONPATH}:.." python -m unittest discover

#
# virtual environments and installation
#
#env : cesm-env2 cesm-env3
env : cesm-env2

cesm-env2 :
	virtualenv -p python2 $@

cesm-env3 :
	virtualenv -p python3 $@

develop : $(SRC_SUBDIRS)

#
# release info
#
#version : FORCE
#	@git describe --always 2>/dev/null > VERSION

#
# clean - Clean up the directory.
#
clean : $(SRC_SUBDIRS)
	-rm -f *~ *.CKP *.ln *.BAK *.bak .*.bak \
		core errs \
		,* .emacs_* \
		tags TAGS \
		make.log MakeOut \
		*.tmp tmp.txt

#
# clobber - Really clean up the directory.
#
clobber : clean $(SRC_SUBDIRS)
	-rm -f .Makedepend *.o *.mod *.il *.pyc
	-rm -rf *.egg-info build


clobber-env : FORCE
	-rm -rf cesm-env2
#	-rm -rf cesm-env2 cesm-env3 

#
# FORCE - Null rule to force things to happen.
#
FORCE :

