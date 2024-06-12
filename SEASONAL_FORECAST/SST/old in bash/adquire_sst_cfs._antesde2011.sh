#!/bin/bash 



for ano in `seq $1  $2`
do
for mes in `seq --format=%02g $3 $4`
do
  echo $mes
   case $mes in
       01)  mes1=31
            ;;
       02)  mes1=29
            ;;
       03)  mes1=31
            ;;
       04)  mes1=30
             ;;
       05)  mes1=31
             ;;
       06)  mes1=30
             ;;
       07)  mes1=31
             ;;
       08)  mes1=31
             ;;
       09)  mes1=30
             ;;
       10)  mes1=31
             ;;
       11)  mes1=30
             ;;
       12)  mes1=31
             ;;
	*)
;;
    esac
	   


for dia in `seq --format=%02g 1 $mes1`
do
    hora="00"
	#for hora in `seq --format=%02g 0 6 18`
	#do

site_inv="https://www.ncei.noaa.gov/data/climate-forecast-system/access/reanalysis/6-hourly-ocean/"$ano"/"$ano$mes"/"$ano$mes$dia"/ocnh06.gdas."$ano$mes$dia$hora".inv"
site_grib="https://www.ncei.noaa.gov/data/climate-forecast-system/access/reanalysis/6-hourly-ocean/"$ano"/"$ano$mes"/"$ano$mes$dia"/ocnh06.gdas."$ano$mes$dia$hora".grb2"

file_grib="ocnh06.gdas."$ano$mes$dia$hora".grb2"
echo $ano$mes$dia$hora"--->"$mes1
name="SST_CFSR_OCN_"$ano$mes$dia$hora".grb2"

./get_inv.pl $site_inv | egrep ':(TMP|ICEC):' | ./get_grib.pl $site_grib $file_grib   > /dev/null 2>&1
if test -e $file_grib ;then 
	mv $file_grib $name 
	#echo $file_grib" "$name" "OK
    #     export FILESST=$name
    #     ncl meuunicogrib.ncl 
else
        echo $file_grib" "$name" "ERRO 
fi 


done
#done
done 
done

