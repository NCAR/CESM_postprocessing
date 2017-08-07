all : develop

test : FORCE
	cd ilamb/test; nosetests test_run_script.py

develop : install

# NOTE: need to cd to ilamb dir first before setup because
# the Makefile to build and install in the virtualenv is
# different from the distibution Makefile.

install : FORCE
	cd ilamb; python setup.py install

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
	-rm -rf ilamb/*.egg-info 
	-rm -rf ilamb/build

#
# FORCE - Null rule to force things to happen.
#
FORCE :
