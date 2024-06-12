#!/bin/sh 

#
#
#  SST FILE NEED LANDMASK !!!

if [ $1 == "" ];then 
echo "Usage:  put_land.sh [ GDAS_ANALISE FILE PATH ] "
exit
fi  

for file in `ls -1 SST_CFS/ocnf*`
do 
 wgrib2 $1 -match LAND -append -grib_out $file 
done

