all : develop

test : FORCE
	python -m unittest discover --start-directory mpi_utils/tests

develop : FORCE
	python setup.py $@

install : FORCE
	python setup.py $@

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
