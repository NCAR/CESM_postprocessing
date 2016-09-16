
procedure readobs(extent)
begin

diag_obs = getenv("DIAGOBSROOT")

;***************************************************
; read in data 1981-2005, in million of square km
;***************************************************
; observed
; year mo   data_type region extent   area -> data type and region are strings, which will be ignored

  extent = new((/2,25,12/),float)
  ncols = 4    ; 
  nrows = 27 ; only up to (including) 2009
  ksoi1  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_01_area.txt",(/nrows,ncols/),"float")
  extent(0,:,0) = ksoi1(2:26,2)
  ksoi1  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_01_area.txt",(/nrows,ncols/),"float")
  extent(1,:,0) = ksoi1(2:26,2)
;-----------------------------------
 ksoi2  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_02_area.txt",(/nrows,ncols/),"float")
  extent(0,:,1) = ksoi2(2:26,2)
 ksoi2  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_02_area.txt",(/nrows,ncols/),"float")
  extent(1,:,1) = ksoi2(2:26,2)
;-----------------------------------
 ksoi3  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_03_area.txt",(/nrows,ncols/),"float")
  extent(0,:,2) = ksoi3(2:26,2)
 ksoi3  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_03_area.txt",(/nrows,ncols/),"float")
  extent(1,:,2) = ksoi3(2:26,2)
;-----------------------------------
 ksoi4  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_04_area.txt",(/nrows,ncols/),"float")
  extent(0,:,3) = ksoi4(2:26,2)
 ksoi4  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_04_area.txt",(/nrows,ncols/),"float")
  extent(1,:,3) = ksoi4(2:26,2)
;-----------------------------------
 ksoi5  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_05_area.txt",(/nrows,ncols/),"float")
  extent(0,:,4) = ksoi5(2:26,2)
 ksoi5  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_05_area.txt",(/nrows,ncols/),"float")
  extent(1,:,4) = ksoi5(2:26,2)
;-----------------------------------
 ksoi6  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_06_area.txt",(/nrows,ncols/),"float")
  extent(0,:,5) = ksoi6(2:26,2)
 ksoi6  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_06_area.txt",(/nrows,ncols/),"float")
  extent(1,:,5) = ksoi6(2:26,2)
;-----------------------------------
 ksoi7  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_07_area.txt",(/nrows,ncols/),"float")
  extent(0,:,6) = ksoi7(2:26,2)
 ksoi7  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_07_area.txt",(/nrows,ncols/),"float")
  extent(1,:,6) = ksoi7(2:26,2)
;-----------------------------------
 ksoi8  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_08_area.txt",(/nrows,ncols/),"float")
  extent(0,:,7) = ksoi8(2:26,2)
 ksoi8  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_08_area.txt",(/nrows,ncols/),"float")
  extent(1,:,7) = ksoi8(2:26,2)
;-----------------------------------
 ksoi9  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_09_area.txt",(/nrows,ncols/),"float")
  extent(0,:,8) = ksoi9(2:26,2)
 ksoi9  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_09_area.txt",(/nrows,ncols/),"float")
  extent(1,:,8) = ksoi9(2:26,2)
;-----------------------------------
 ksoi10  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_10_area.txt",(/nrows,ncols/),"float")
  extent(0,:,9) = ksoi10(2:26,2)
 ksoi10  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_10_area.txt",(/nrows,ncols/),"float")
  extent(1,:,9) = ksoi10(2:26,2)
;-------------------------------------------------------------
; November and December data starts in 1978 --> only grab 1979-2009
delete(nrows)
 nrows = 28 ; 
;-------------------------------------------------------------
 ksoi11  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_11_area.txt",(/nrows,ncols/),"float") ; 
  extent(0,:,10) = ksoi11(3:27:,2)
 ksoi11  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_11_area.txt",(/nrows,ncols/),"float") ; 
  extent(1,:,10) = ksoi11(3:27:,2)
;-----------------------------------
  ksoi12  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/N_12_area.txt",(/nrows,ncols/),"float")
  extent(0,:,11) = ksoi12(3:27,2)
  ksoi12  = asciiread(diag_obs+"/NSIDC_SeaIce_extent/S_12_area.txt",(/nrows,ncols/),"float")
  extent(1,:,11) = ksoi12(3:27,2)
end
