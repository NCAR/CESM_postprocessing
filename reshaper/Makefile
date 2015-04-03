all : develop

test : FORCE
	python -m unittest discover --start-directory pyReshaper/tests/yellowstone

develop : install

# NOTE: need to cd to pyReshaper dir first before setup because
# the Makefile can't live in the same dir as pyReshaper due to 
# different SVN repos (CESM and CISL). The setup.py operates
# on relative paths so must be called from the pyReshaper dir.
install : FORCE
	cd pyReshaper; python setup.py install

#
clean : 
	-rm -f *~ *.CKP *.ln *.BAK *.bak .*.bak \
		core errs \
		,* .emacs_* \
		tags TAGS \
		make.log MakeOut \
		*.tmp tmp.txt

#
# clobber - Really clean up the directory.
#
clobber : clean
	-rm -f .Makedepend *.o *.mod *.il *.pyc
	-rm -rf *.egg-info build

#
# FORCE - Null rule to force things to happen.
#
FORCE :
