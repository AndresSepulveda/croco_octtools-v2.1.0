#!/bin/bash
set -e
#source ../../myenv_mypath.sh
##########################
# python
# ======
#   python version >= 3.9 & <3.12
#
# motuclient
# ==========
# 1- Use copernicusmarine client ...
#### USER INFORMATIONS ####
user='XXXXXXXXX'
password='XXXXXXXXX'
###
### Copernicus marine client ###
# this is the pathCMC (described on the readme file Copernicus_Marine_Toolbox_installation.md)
path_to_cmt="/home/to/your/bin/copernicusmarine" 
### 
YEAR_START=2017
MONTH_START=1
DAY_START=1

YEAR_END=2017
MONTH_END=1
DAY_END=1

DT_TIME=   # Value in days. Default value when empty is 1 month. 
           # If dataset is to big adjust this value. 
           # Cannot handle values bigger than a month
           # Automaticaly adjust for 1 month
#
### KIND OF DATA ###
kdata="MONTHLY" # DAILY or MONTHLY
####################
READ_GRD=1 # read croco_grid to find lon/lat min-max
#INPUT_GRD="${OCE_FILES_DIR}/croco_grd.nc"
INPUT_GRD="CROCO_FILES/croco_grd.nc"
# In case you don't want to read croco_grd
# Please use -180/180 -90/90 format
lon_min="-90"
lon_max="0"
lat_min="0"
lat_max="40"
####################
OUTDIR="./" # where to put data
PREFIX="mercator" # prefix for raw data

###################################################################
########## END USER CHANGES #######################################
###################################################################

### vars to download ###
vars="zos uo vo thetao so"
variables=""
for field in ${vars}; do
    variables="${variables} -v ${field} "
done
###

if [[ -z ${path_to_cmt} ]]; then
	echo "You need to define your path_to_cmt variable ..."
	exit 12
else
    command_line=${path_to_cmt}" "
fi

## cmt info
if [[ ${kdata} == "DAILY" ]]; then
    product_id_reana='cmems_mod_glo_phy_my_0.083deg_P1D-m'
elif [[ ${kdata} == "MONTHLY" ]]; then
    product_id_reana='cmems_mod_glo_phy_my_0.083deg_P1M-m'
else
    echo "Please specify what kind of data you want (DAILY or MONTHLY), exit...."; exit 1
fi
###

#### READ GRID data #####
if [[ ${READ_GRD} == 1 ]]; then
    ncap2 -O -v -s 'latmin=lat_rho.min();latmax=lat_rho.max();lonmin=lon_rho.min();lonmax=lon_rho.max()' ${INPUT_GRD} tmp.nc
    ncap2 -O -s 'where(lonmin >= 180) lonmin=lonmin-360; where(lonmax >= 180) lonmax=lonmax-360;' tmp.nc tmp.nc
    lon_min=$( ncdump -v lonmin tmp.nc  | grep "lonmin =" | cut -d ' ' -f 4)
    lat_min=$( ncdump -v latmin tmp.nc  | grep "latmin =" | cut -d ' ' -f 4)
    lon_max=$( ncdump -v lonmax tmp.nc  | grep "lonmax =" | cut -d ' ' -f 4)
    lat_max=$( ncdump -v latmax tmp.nc  | grep "latmax =" | cut -d ' ' -f 4)
    rm -f tmp.nc
    lon_min=`echo "scale=4; ${lon_min} - 1" | bc `
    lat_min=`echo "scale=4; ${lat_min} - 1" | bc `
    lon_max=`echo "scale=4; ${lon_max} + 1" | bc `
    lat_max=`echo "scale=4; ${lat_max} + 1" | bc `
    echo "Data will be download on W:${lon_min} E:${lon_max} S:${lat_min} N:${lat_max}"
fi
###

### loop ###
lmonth=( 1 3 5 7 8 10 12 )
for YEAR in `seq ${YEAR_START} ${YEAR_END}`; do
    [[ ${YEAR} == ${YEAR_START} ]] && mstart=${MONTH_START} || mstart=1 
    [[ ${YEAR} == ${YEAR_END} ]] && mend=${MONTH_END} || mend=12
    [[ $(($YEAR % 4)) -eq 0  && ( $(($YEAR % 100)) -ne 0  ||  $(($YEAR % 400)) -eq 0 )]] && { leapyear=1 ;} || { leapyear=0 ;}
    for MONTH in `seq ${mstart} ${mend}`; do
## handle leap year
        [[ ${lmonth[@]} =~ $MONTH ]] && { maxendday=31 ;} || { maxendday=30 ;} 
        [[ $MONTH == 2 && $leapyear == 1 ]] && { maxendday=29 ;}
        [[ $MONTH == 2 && $leapyear == 0 ]] && { maxendday=28 ;}
        [[ $YEAR == ${YEAR_START} && $MONTH == ${MONTH_START} ]] && { dstart=${DAY_START} ;} || { dstart=1 ;}
        [[ $YEAR == ${YEAR_END} && $MONTH == ${MONTH_END} ]] && { dend=${DAY_END} ;} || { dend=$maxendday ;}
##
        if [[ ${kdata} == "MONTHLY" ]]; then
            daystrt=1
            start_date=$( printf "%04d-%02d-%02d" $YEAR $MONTH $daystrt)
            end_date=$(printf `date +"%Y-%m-%d" -d "${start_date} +1 month - 1 day"`) 
            OUTNAME="${OUTDIR}/raw_${PREFIX}_Y${YEAR}M${MONTH}.nc"
			echo "${command_line} subset -i ${product_id_reana} -x ${lon_min} -X ${lon_max} -y ${lat_min} -Y ${lat_max} -t "${start_date}" -T "${end_date}" -z 0.493 -Z 5727.918 ${variables} -o ./ -f ${OUTNAME} --username ${user} --password ${password} --force-download"
            ${command_line} subset -i ${product_id_reana} -x ${lon_min} -X ${lon_max} -y ${lat_min} -Y ${lat_max} -t "${start_date}" -T "${end_date}" -z 0.493 -Z 5727.918 ${variables} -o ./ -f ${OUTNAME} --username ${user} --password ${password} --force-download

        elif [[ ${kdata} == "DAILY" ]]; then
            if [ -z ${DT_TIME} ]; then
                start_date=$( printf "%04d-%02d-%02d" $YEAR $MONTH $daystrt)
                end_date=$(printf `date +"%Y-%m-%d" -d "${start_date} +1 month - 1 day"`)
                OUTNAME="${OUTDIR}/raw_${PREFIX}_Y${YEAR}M${MONTH}.nc"
				echo "${command_line} subset -i ${product_id_reana} -x ${lon_min} -X ${lon_max} -y ${lat_min} -Y ${lat_max} -t "${start_date}" -T "${end_date}" -z 0.493 -Z 5727.918 ${variables} -o ./ -f ${OUTNAME} --username ${user} --password ${password} --force-download"
                ${command_line} subset -i ${product_id_reana} -x ${lon_min} -X ${lon_max} -y ${lat_min} -Y ${lat_max} -t "${start_date}" -T "${end_date}" -z 0.493 -Z 5727.918 ${variables} -o ./ -f ${OUTNAME} --username ${user} --password ${password} --force-download
            else
                for DAY in `seq ${dstart} ${DT_TIME} ${dend}`; do
                    tmpoutname="${OUTDIR}/raw_${PREFIX}_Y${YEAR}M${MONTH}D${DAY}.nc"
                    start_date=$( printf "%04d-%02d-%02d" $YEAR $MONTH $DAY )
                    end_date=$( date +"%Y-%m-%d" -d "${start_date} +${DT_TIME} day - 1 day" )
                    tmpsdate=$( echo `date -d ${start_date} +"%Y%m"` )
                    tmpedate=$( echo `date -d ${end_date} +"%Y%m"` )
                    if [[ ${tmpedate} > ${tmpsdate} ]]; then
                        # compute time dist to month end
                        tmpdate=$( printf "%04d-%02d-01" $YEAR $MONTH )
                        first_date=$( date +%s -d "${tmpdate} +1 month - 1 day" )
                        second_date=$( date +%s -d "${end_date}" ) 
                        nbdays=$(( (${second_date} - ${first_date})/86400 ))
                        end_date=$( date +"%Y-%m-%d" -d "${end_date} - ${nbdays} day" )
                    fi
					echo "${command_line} subset -i ${product_id_reana} -x ${lon_min} -X ${lon_max} -y ${lat_min} -Y ${lat_max} -t "${start_date}" -T "${end_date}" -z 0.493 -Z 5727.918 ${variables} -o ./ -f ${tmpoutname} --username ${user} --password ${password} --force-download"
                    ${command_line} subset -i ${product_id_reana} -x ${lon_min} -X ${lon_max} -y ${lat_min} -Y ${lat_max} -t "${start_date}" -T "${end_date}" -z 0.493 -Z 5727.918 ${variables} -o ./ -f ${tmpoutname} --username ${user} --password ${password} --force-download 
                    ncks -O -F --mk_rec_dmn time ${tmpoutname} ${tmpoutname}
                done
                cd ${OUTDIR}
                ncrcat -O raw_${PREFIX}_Y${YEAR}M${MONTH}D*.nc raw_${PREFIX}_Y${YEAR}M${MONTH}.nc
                rm -r raw_${PREFIX}_Y${YEAR}M${MONTH}D*.nc
                cd -
            fi
        fi  
    done 
done
