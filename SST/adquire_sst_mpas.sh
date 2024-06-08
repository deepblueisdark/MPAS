#!/bin/sh

convert_julian() {
# convert Gregorian calendar date to Julian Day Number 
# convert Julian Day Number to Gregorian calendar date 
#
# algorithm source:
# http://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
# 
# examples:
# $ ./script.sh 15 5 2013
# 2456428
# $ ./script.sh 2456428
# 15/5/2013
#
# contact:
# milosz@sleeplessbeastie.eu
#


# gtojdn
# convert Gregorian calendar date to Julian Day Number
#
# parameters:
# day
# month
# year
# 
# example:
# gtojdn 15 5 2013
#
gtojdn() {
  if test  $2 -le 2 ;then
    y=$(($3 - 1))
    m=$(($2 + 12))
  else
    y=$3
    m=$2
  fi
  d=$1

  x=$(echo "2 - $y / 100 + $y / 400" | bc)
  x=$(echo "($x + 365.25 * ($y + 4716))/1" | bc) 
  x=$(echo "($x + 30.6001 * ($m + 1))/1" | bc)
  
  echo $(echo "($x + $d - 1524.5)" | bc)
}


# jdntog
# convert Julian Day Number to Gregorian calendar
#
# parameters:
# jdn
#
# example:
# jdntog 2456428
#
# notes:
# algorithm is simplified
# loses accuracy for years less than in 1582
#
jdntog() {
  z=$(echo "($1+0.5)" | bc)
  w=$(echo "(($z - 1867216.25)/36524.25)/1" | bc)
  x=$(echo "$w / 4" | bc)
  a=$(echo "$z + 1 + $w - $x" | bc)
  b=$(echo "$a + 1524" | bc)
  c=$(echo "(($b - 122.1) / 365.25)/1" | bc)
  d=$(echo "(365.25 * $c)/1" | bc)
  e=$(echo "(($b - $d) / 30.6001)/1" | bc)
  f=$(echo "(30.6001 * $e)/1" | bc)

  md=$(echo "($b - $d - $f)/1" | bc)
  if [ $e -le 13 ]; then
    m=$(echo "$e - 1" | bc)
  else
    m=$(echo "$e - 13" | bc)
  fi

  if [ $m -le 2 ]; then
    y=$(echo "$c - 4715" | bc)
  else
    y=$(echo "$c - 4716" | bc)
  fi
 
  #echo $y" "$m" "$md 
  printf "%d %02d %02d 00\n" "$y" "$m"  "$md"
  if [ "$y" -lt 1582 ]; then
    echo "not accurate as year < 1582"
  fi
}


#
# process the command-line arguments
#
if [ "$#" -eq 1 ]; then
  jdntog $1
elif [ "$#" -eq 3 ]; then
  gtojdn $1 $2 $3
else
  d=`date +%d`
  m=`date +%m`
  y=`date +%Y`
  gtojdn $d $m $y
fi

}




inicio=`convert_julian  31 05 2024 | cut -d"." -f1`
let inicio=$inicio+1
let final=$inicio+5
echo $inicio
echo $final

convert_julian $inicio 
convert_julian $final




ano0=`convert_julian $inicio | cut -d" " -f1` 
mes0=`convert_julian $inicio | cut -d" " -f2` 
dia0=`convert_julian $inicio | cut -d" " -f3` 

data_run=$ano0$mes0$dia0"18" 
for day in `seq $inicio $final` 
do
   for hora in `seq --format=%02g 0 6 18`
   do
echo `convert_julian $day`   
ano=`convert_julian $day | cut -d" " -f1` 
mes=`convert_julian $day | cut -d" " -f2` 
dia=`convert_julian $day | cut -d" " -f3` 
echo $ano$mes$dia 
echo $ano0$mes0$dia0 
if test $dia = "00" ;then 
dia="31"
fi 
   
filesst="https://www.ncei.noaa.gov/data/climate-forecast-system/access/operational-9-month-forecast/6-hourly-ocean/"$ano0"/"$ano0$mes0"/"$ano0$mes0$dia0"/"$ano0$mes0$dia0"18/ocnf"$ano$mes$dia$hora".01."$data_run".grb2" 
wget -nc $filesst
echo $filesst 
done
done 


