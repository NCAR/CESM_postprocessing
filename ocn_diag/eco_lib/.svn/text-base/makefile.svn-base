all:	remap

remap:
	f2py -c --fcompiler=gfortran --f77exec=/usr/bin/gfortran -m remap remap.f

clean:
	rm -r *.so
