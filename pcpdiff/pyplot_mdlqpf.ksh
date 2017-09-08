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
      
      if [ ! -s ${gbfile[${i}]} ]; then
         htar -xvf /NCEPDEV/emc-meso/5year/Donald.E.Lippi/nwrw_${exp}/rh${yyyy}/${yyyy}${mm}/${PDY}/scratch4_NCEPDEV_meso_noscrub_Donald.E.Lippi_com_namrr_rw_${exp}_namrr.${PDY}${cyc}.conusnest.tar ./${gbfile[${i}]} 
      #/NCEPDEV/emc-meso/5year/Donald.E.Lippi/nwrw_002/rh2015/201510/20151030/
      #scratch4_NCEPDEV_meso_noscrub_Donald.E.Lippi_com_namrr_002_namrr.2015103018.conusnest.tar
      # ./namrr.t${cyc}z.conusnest.hiresf.tm00.grib2 
      fi 
      (( i  = i  + 1 ))
      (( hr = hr + 3 ))
   done
#   if [ ! -d ${pyplot_dir}/output/pyplot ]; then
#      mkdir -p ${TROOT}/ptmp/$USER/output/pyplot
#   fi

   export gbfile=${gbfile[${i}]}
   export valcyc=${valcyc}
   export valpdy=${valpdy}
   export domid=${domid}

   cd ${pyplotdir}
   cp ${plt_pcp_diff}/plt_diff${type}.py ./plt_mdl${type}_tmp.py

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
  
   python plt_mdl${type}_tmp.py ${valpdy} ${valcyc} ${domid} ${name} ${hr} ${hh} $clevsOBS $OB_lines ${gbfile[*]} ${obsfiles[*]}

   mv *png ${figout}/
done

exit
