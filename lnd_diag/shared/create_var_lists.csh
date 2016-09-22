#!/bin/csh

#*************************************************
# create variable_master.ncl 
#*************************************************
# Add all regular clm variables
cat $INPUT_FILES/set1_clm.txt                                    > ${WKDIR}master_set1.txt
cat $INPUT_FILES/set2_clm.txt                                         > ${WKDIR}master_set2.txt
cat $INPUT_FILES/set3_*.txt                                           > ${WKDIR}master_set3.txt
cat $INPUT_FILES/set5_clm.txt    $INPUT_FILES/set5_hydReg.txt              > ${WKDIR}master_set5.txt
cat $INPUT_FILES/set6_*.txt                                           > ${WKDIR}master_set6.txt

# If CN is on, add all regular cn variables
if ($CN == 1) then
   if ($C13 == 1) then
      echo 'CN + C13 Active'
      cat $INPUT_FILES/set1_cn.txt $INPUT_FILES/set1_c13.txt >> ${WKDIR}master_set1.txt
      cat $INPUT_FILES/set2_cn.txt $INPUT_FILES/set2_c13.txt >> ${WKDIR}master_set2.txt
      cat $INPUT_FILES/set5_cn.txt $INPUT_FILES/set5_c13.txt >> ${WKDIR}masterCN_set5.txt
      cat $INPUT_FILES/set5_cn.txt $INPUT_FILES/set5_c13.txt >> ${WKDIR}master_set5.txt
    else
      echo 'CN Active; C13 Inactive'
      cat $INPUT_FILES/set1_cn.txt                           >> ${WKDIR}master_set1.txt
      cat $INPUT_FILES/set2_cn.txt                           >> ${WKDIR}master_set2.txt
      cat $INPUT_FILES/set5_cn.txt                              >> ${WKDIR}masterCN_set5.txt
      cat $INPUT_FILES/set5_cn.txt                           >> ${WKDIR}master_set5.txt
    endif
endif

if ($CLAMP == 1) then
       echo 'CLAMP Active'
       # Add clamp variables
       cat $INPUT_FILES/set1_clm-clamp.txt $INPUT_FILES/set1_cn-clamp.txt  >> ${WKDIR}master_set1.txt
       cat $INPUT_FILES/set2_clm-clamp.txt $INPUT_FILES/set2_cn-clamp.txt  >> ${WKDIR}master_set2.txt
       cat $INPUT_FILES/set5_cn-clamp.txt                             >> ${WKDIR}masterCN_set5.txt
       cat $INPUT_FILES/set5_cn-clamp.txt                             >> ${WKDIR}master_set5.txt
       cat $INPUT_FILES/set5_clm-clamp.txt                            >> ${WKDIR}master_set5.txt
endif

if ($CASA == 1) then
      echo 'CASA active'
      cat $INPUT_FILES/set1_casa.txt  $INPUT_FILES/set1_clm.txt          >> ${WKDIR}master_set1.txt
      cat $INPUT_FILES/set2_casa.txt  $INPUT_FILES/set2_clm.txt          >> ${WKDIR}master_set2.txt
      cat $INPUT_FILES/set5_casa.txt                             >> ${WKDIR}masterCASA_set5.txt
      cat $INPUT_FILES/set5_casa.txt                             >> ${WKDIR}master_set5.txt
endif

cat $INPUT_FILES/set8_zonal.txt                                 > ${WKDIR}master_set8_zonal.txt
cat $INPUT_FILES/set8_zonal_lnd.txt                             > ${WKDIR}master_set8_zonal_lnd.txt
cat $INPUT_FILES/set8_trends.txt                                > ${WKDIR}master_set8_trends.txt
cat $INPUT_FILES/set8_contour.txt                               > ${WKDIR}master_set8_contour.txt
cat $INPUT_FILES/set8_ann_cycle.txt                             > ${WKDIR}master_set8_ann_cycle.txt
cat $INPUT_FILES/set8_ann_cycle_lnd.txt                         > ${WKDIR}master_set8_ann_cycle_lnd.txt
cat $INPUT_FILES/set8_contour_DJF-JJA.txt                       > ${WKDIR}master_set8_contourDJF-JJA.txt


