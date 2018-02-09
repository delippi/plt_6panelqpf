#!/bin/ksh 
##-ex

export ndate=/home/Donald.E.Lippi/bin/ndate
. setup.ksh

#exps="rw_c002"
# 00z 5/20/2013
#### FROM SETUP KSH #############
PDY=$date                       #
cyc=$cyc   #starting hour       #
hh=$fhr #endhr = starthour + hh #
exps=$exps                      #
expsn=$expsn # exps names       #
#################################
echo "expsn = $expsn"
set -A expsn `echo $expsn`
j=0
for exp in $exps; do
   i=1
   hrly=03  #leave alone. this is the bucket size.
   hr=03    #leave alone.
   typeset -Z2 hr  
   (( numgrb=${hh}/${hrly} ))
   name=${expsn[${j}]} #; echo "domid = $domid"; sleep 5
   (( j = j + 1 ))

   while [ $i -le $numgrb ]; do
      echo ">>>Making plot for ${PDY}${cyc} ${hr} max hour $hh"
      pyplotdir=${pyplot_dir}/pyplot_work_rw_${exp}.${PDY}
      mkdir -p $pyplotdir

      figout=${figout_dir}/pyplot_nest_rw_${exp}.${PDY}
      mkdir -p $figout
      cd ${pyplotdir}



      domid=$exp
      valtime=`${ndate} +${hh} ${PDY}${cyc}`
      valpdy=`echo ${valtime} | cut -c 1-8`
      valcyc=`echo ${valtime} | cut -c 9-10`
      valyr=`echo ${valtime} | cut -c 1-4`
      valmon=`echo ${valtime} | cut -c 5-6`
      yyyy=`echo $PDY | cut -c 1-4`
      mm=`echo $PDY | cut -c 5-6`
      dd=`echo $PDY | cut -c 7-8`

      gbfile[${i}]=namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2
      
      
      if [ ! -s ${gbfile[${i}]} ]; then
         htar -xvf /NCEPDEV/emc-meso/5year/Donald.E.Lippi/nwrw_${exp}/rh${yyyy}/${yyyy}${mm}/${PDY}/scratch4_NCEPDEV_meso_noscrub_Donald.E.Lippi_com_namrr_rw_${exp}_namrr.${PDY}${cyc}.conusnest.tar ./${gbfile[${i}]} 
         if [ ! -s ${gbfile[${i}]} ]; then # Try WCOSS
            htar -xvf /NCEPDEV/emc-meso/5year/Donald.E.Lippi/nwrw_${exp}/rh${yyyy}/${yyyy}${mm}/${PDY}/meso2_noscrub_Donald.E.Lippi_com_namrr_rw_${exp}_namrr.${PDY}${cyc}.conusnest.tar ./${gbfile[${i}]}
         fi
      #/NCEPDEV/emc-meso/5year/Donald.E.Lippi/nwrw_002/rh2015/201510/20151030/
      #scratch4_NCEPDEV_meso_noscrub_Donald.E.Lippi_com_namrr_002_namrr.2015103018.conusnest.tar
      # ./namrr.t${cyc}z.conusnest.hiresf.tm00.grib2 
      fi
      if [[ $diff = ".false." ]]; then
         if [[ ! -s ${gbfile[${i}]}_apcp  ]]; then
            wgrib2 ${gbfile[${i}]} -match ":APCP:surface:" -grib ${gbfile[${i}]}_apcp
         fi
         gbfile[${i}]=${gbfile[${i}]}_apcp
      fi

      if [ $diff = ".true." ]; then 
         gbfile[${i}]=namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2${diff_grid}
         if [[ ! -s namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2${diff_grid} ]]; then
            echo "Hang on... I need to convert to ncep grid ${diff_grid} this will only take a moment."
            #             proj    nx   ny   lat1   lon1     lov     dx/dy        lad    latin1/latin2         
            if [[ $diff_grid == "_g221" ]]; then 
               GRIDSPEC_RGD="lambert 1473 1025 12.190 -133.459 -95.000 5.079 6371.2 25.000 25.000" #~ncep g227
            fi
            if [[ $diff_grid == "_g227" ]]; then 
               GRIDSPEC_RGD="lambert 1473 1025 12.190 226.5410 265.000 5.079 6371.2 25.000 25.000" #~ncep g227
            fi
            if [[ $diff_grid == "_3km" ]]; then 
               GRIDSPEC_RGD="lambert 1799 1059 21.138 231.2800 262.500 3.000 6371.2 38.500 38.500" #HRRR?
            fi
            set -A GRIDSPEC_ARRAY $GRIDSPEC_RGD
            proj=${GRIDSPEC_ARRAY[0]}
            lat1=${GRIDSPEC_ARRAY[3]}
            let lon1=${GRIDSPEC_ARRAY[4]}
            let lov=${GRIDSPEC_ARRAY[5]}
            lad=${GRIDSPEC_ARRAY[8]}
            latin1=${GRIDSPEC_ARRAY[9]}
            latin2=${GRIDSPEC_ARRAY[9]}
            nx=${GRIDSPEC_ARRAY[1]}
            ny=${GRIDSPEC_ARRAY[2]}
            let dx=${GRIDSPEC_ARRAY[6]}*1000
            let dy=${GRIDSPEC_ARRAY[6]}*1000
            echo "$proj:$lov:$latin1:$latin2:$lad $lon1:$nx:$dx $lat1:$ny:$dy"
            if [ ${diff_grid} == '_3km' ]; then
               wgrib2 namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2 -match ":APCP:surface:" -set_grib_type same -new_grid_winds earth -new_grid $proj:$lov:$latin1:$latin2:$lad $lon1:$nx:$dx $lat1:$ny:$dy namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2${diff_grid}
            fi
            if [ ${diff_grid} == '_g227' ]; then
               wgrib2 namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2 -match ":APCP:surface:" -set_grib_type same -new_grid_winds earth -new_grid $proj:$lov:$latin1:$latin2:$lad $lon1:$nx:$dx $lat1:$ny:$dy namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2${diff_grid}
            fi
            if [ ${diff_grid} == '_g221' ]; then
               #wgrib2 namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2 -set_grib_type same -new_grid ncep grid 221 namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2${diff_grid}
               wgrib2 namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2 -match ":APCP:surface:" -set_grib_type same -new_grid ncep grid 221 namrr.t${cyc}z.conusnest.hiresf${hr}.tm00.grib2${diff_grid}
            fi


         fi
      fi
      echo "**********************************************"
      echo "name  : $name"
      echo "EXP   : $exp  "
      echo "YYYY  : $yyyy "
      echo "MM    : $mm   "
      echo "DD    : $dd   "
      echo "CYC   : $cyc  "
      echo "fhr   : $hr   "
      echo "valid : ${valtime}" 
      echo "dir   : $pyplotdir  "
      echo "grb   : ${gbfile[${i}]} "
      echo "**********************************************"
      echo ""
      (( i  = i  + 1 ))
      (( hr = hr + 3 ))
   done

   export gbfile=${gbfile[${i}]}
   export valcyc=${valcyc}
   export valpdy=${valpdy}
   export domid=${domid}

   cd ${pyplotdir}
   cp ${plt_mdl_dir}/plt_mdl${type}.py ./plt_mdl${type}_tmp.py
   cp ${plt_mdl_dir}/plt_diff${type}.py ./plt_diff${type}_tmp.py
   #cp ${plt_mdl_dir}/colormap.py ./colormap.py

   echo ${gbfile[*]}
   (( hr = hr - 3 ))

   #GET OBS FILES
   #obsfiles_blackline_txt="/home/Donald.E.Lippi/plotting/python/plt_obsqpf/obsfiles_blackline.txt"
   obsfiles_blackline_txt="${work_dir}/obsfiles_blackline.txt"
   k=0
   while IFS= read -r line
   do
      obsfiles[${k}]=`echo "$line"`
      (( k = k + 1 ))
   done <"$obsfiles_blackline_txt" 
   echo "obsfiles = ${obsfiles[*]}"

   if [ $diff = ".false." ]; then 
      python plt_mdl${type}_tmp.py ${valpdy} ${valcyc} ${domid} ${name} ${hr} ${hh} $clevsOBS $OB_lines ${gbfile[*]} ${obsfiles[*]}
   else
      python plt_diff${type}_tmp.py ${valpdy} ${valcyc} ${domid} ${name} ${hr} ${hh} $clevsOBS $OB_lines ${gbfile[*]} ${obsfiles[*]}
   fi
   err=$?; if [ $err != 0 ]; then; printf "Error: [%d] when executing command on line $LINENO of $0 \n" $err; exit $err; fi
   mv *png ${figout}/
   err=$?; if [ $err != 0 ]; then; printf "Error: [%d] when executing command on line $LINENO of $0 \n" $err; exit $err; fi
done

exit
