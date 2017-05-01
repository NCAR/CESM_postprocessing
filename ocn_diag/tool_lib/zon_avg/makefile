
#  FC, INCLUDE, LIBS obtained with command
#  nc-config --fc --includedir --flibs

FC = ifort
FFLAGS = -c -g -O2
INCLUDE = -I/glade/u/apps/ch/opt/netcdf/4.4.1.1/intel/16.0.3/include
LIBS = -L/glade/u/apps/ch/opt/netcdf/4.4.1.1/intel/16.0.3/lib -lnetcdff -lnetcdf

.SUFFIXES:            # Delete the default suffixes
.SUFFIXES: .F .F90 .o # Define our suffix list

.F.o:
	$(FC) $(FIXED) $(FFLAGS) $(INCLUDE) $<

.F90.o:
	$(FC) $(FREE) $(FFLAGS) $(INCLUDE) $<

OBJECTS = main.o kinds_mod.o constants.o arg_wrap.o nf_wrap.o nf_wrap_stubs.o msg_mod.o sphere_area_mod.o POP_grid_mod.o zonal_avg_mod.o

za: $(OBJECTS)
	$(FC) $(OBJECTS) $(LIBS) -o za

kinds_mod.o: kinds_mod.F90
arg_wrap.o: arg_wrap.F90 kinds_mod.o
constants.o: constants.F90 kinds_mod.o
msg_mod.o: msg_mod.F90 kinds_mod.o
nf_wrap_stubs.o: nf_wrap_stubs.F90 kinds_mod.o
sphere_area_mod.o: sphere_area_mod.F90 kinds_mod.o constants.o
nf_wrap.o: nf_wrap.F90 kinds_mod.o msg_mod.o nf_wrap_stubs.o
POP_grid_mod.o: POP_grid_mod.F90 kinds_mod.o constants.o nf_wrap.o sphere_area_mod.o
zonal_avg_mod.o: zonal_avg_mod.F90 kinds_mod.o constants.o nf_wrap.o POP_grid_mod.o sphere_area_mod.o
main.o: main.F90 kinds_mod.o constants.o msg_mod.o arg_wrap.o sphere_area_mod.o POP_grid_mod.o zonal_avg_mod.o

clean:
	rm -f *.o *.mod *.l *.lis *.lst