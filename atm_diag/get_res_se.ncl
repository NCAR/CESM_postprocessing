load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
  ne = dataFile@ne
  system("echo "+ne+" > "+ resFile) 
end
