#!/bin/csh -f
#
#  Generates Temperature plots for each WOCE WHP Track in
#  ${WOCE_LINE}.  
#
#  Usage:
#   woce_TS_plots.csh CASE NCYCLE BEGYR MODBEGYR VAR
#	where	CASE == casename
#		NCYCLE == # of years in forcing cycle (eg, 43)
#		BEGYR  == first year of forcing (eg, 1958)
#		MODBEGYR == model year corresponding to first year
#			of forcing
#		VAR == T or S
#
#  Assumes defined:  MSROOT
#


#--------------------------------------------------------------------#

set CASE = $1
set NCYCLE = $2
set BEGYR = $3
set MODBEGYR = $4
set VAR = $5
set MSSPATH   = /${MSROOT}/${CASE}/ocn/hist

set WOCE_LINE = ( a01e a01ew a01w a02a a02b a03 a05 a06 a07 a08 a09 a10 a11 a12 a13 a14 a15 \
	          a16c a16n a16s a17 a20 a21 a22 a23 a24 a25 i01e i01w i02e i02w i03 i04 \
		  i05e i05p i06sa i06sb i07n i08s i09n i10 p01 p01w p02c p02e p02t p02w \
		  p03a p04c p04e p04w p05h p06c p06e p06w p08n_a p08n_b p08n_c p08s p09 p10 \
		  p11a p11s p13ca p13cb p13 p13j p14c p14n p14s p15na p15nb p16a p16c \
		  p16n p16s p17c p17e p17n p18 p19a p19c p21 p24 p31 s03 s04 s04a s04i s04p \
		  s05 )

set NLINE = ${#WOCE_LINE}

#--------------------------------------------------------------------#
#----------------- END USER DEFINED INPUT ---------------------------#
#--------------------------------------------------------------------#

@ iwl = 1
foreach wl ($WOCE_LINE)

set PSOUT = ${wl}_${VAR}woce.ps
set GIFOUT = ${wl}_${VAR}woce.gif
set WOCE_CDF = ${WOCE_TS_DATA_DIR}/${wl}_ctd.nc

# Get WOCE Track month and year
if !(-e $WOCE_DATE_FILE) then
  echo "No WOCE date file found"
  exit
else
  echo '/WOCE_LINE / {print $5}' >! tmp.com
  sed "s/WOCE_LINE/${wl}/g" tmp.com >! awk.com
  set WOCE_DATE = `awk -f awk.com ${WOCE_DATE_FILE}`
  echo '/WOCE_LINE / {print int($5/100)}' >! tmp.com
  sed "s/WOCE_LINE/${wl}/g" tmp.com >! awk.com
  set WOCE_YEAR = `awk -f awk.com ${WOCE_DATE_FILE}`
  echo '/WOCE_LINE / {print (($5/100)-int($5/100))*100}' >! tmp.com
  sed "s/WOCE_LINE/${wl}/g" tmp.com >! awk.com
  set WOCE_MONTH = `awk -f awk.com ${WOCE_DATE_FILE}`
  \rm tmp.com
endif 

# Convert to model month and year
if ($NCYCLE > 1) then 
  @ FINYR  = $BEGYR + $NCYCLE - 1
  if ($WOCE_YEAR < $BEGYR || $WOCE_YEAR > $FINYR) then
    echo "WOCE Track year out of bounds.  Skipping ${wl}"
    continue
  endif
endif
@ MOD_YEAR = ($WOCE_YEAR - $BEGYR) + $MODBEGYR
@ MOD_MONTH = $WOCE_MONTH
if ($MOD_MONTH < 10) set MOD_MONTH = 0${MOD_MONTH}
if ($MOD_YEAR < 1000) set MOD_YEAR = 0${MOD_YEAR}
if ($MOD_YEAR < 100) set MOD_YEAR = 0${MOD_YEAR}
if ($MOD_YEAR < 10) set MOD_YEAR = 0${MOD_YEAR}

set MOD_CDF = ${CASE}.pop.h.${MOD_YEAR}-${MOD_MONTH}.nc
set MOD_TAR = ${CASE}.pop.h.${MOD_YEAR}.tar
if !(-e ${MOD_CDF}) then
  msls ${MSP}/${CASENAME}.pop.h.${year}-01.nc
  if ($status == 0) then
    set filesize = `msls -l ${MSP}/${CASENAME}.pop.h.${year}-01.nc | awk '{print $5}'`
    msrcp "mss:${MSSPATH}/${MOD_CDF}" .
  else
    msrcp "mss:${MSSPATH}/${MOD_TAR}" .
    tar xvf ${MOD_TAR}
    rm -f *.tar
  endif
endif

echo $MOD_CDF >! woceplot.in
echo ${WOCE_CDF} >> woceplot.in
echo ${wl} >> woceplot.in
echo ${WOCE_DATE} >> woceplot.in
echo ${VAR} >> woceplot.in
echo ${PSOUT} >> woceplot.in

echo "plotting ${VAR} for track ${wl} , file = ${MOD_CDF}"
# Invoke IDL track sampling routine
echo "@$IDLPATH/pro/set_path" >! idl.run
cat >> idl.run << EOF
tracksample_tsplot,"woceplot.in"
EOF
idl < idl.run

if ($CLEAN == 1) \rm -f ${CASE}.pop.h.${MOD_YEAR}-*.nc

@ iwl++
end

echo "Done plotting WOCE ${VAR} comparisons"
