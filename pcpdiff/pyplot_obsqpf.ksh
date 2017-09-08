#!/bin/ksh 
##-l
set -x

. setup.ksh

echo "Starting ${plt_obs_dir}/pyplot_obs${type}.ksh"
rm -f "${work_dir}/obsfiles_blackline.txt"
rm -f "${work_dir}/pyobs.log"
export ndate=/home/Donald.E.Lippi/bin/ndate

obstype=obs$type    

# 00z 5/20/2013

#### FROM SETUP KSH ##############
PDY=$date                        #
strthr=$cyc #starting hour from  #
endhr=$strthr                    #
hh=$fhr # endhr = starthour + hh #
##################################
hr=03 # 3-hr buckets. Leave alone.
offset=3
typeset -Z2 hr
typeset -Z2 hh
typeset -Z2 strthr
typeset -Z2 endhr
i=1
j=0
(( num=${hh}/${hr} ))
while [[ $i -le $num ]]; do
   echo $hr
   (( endhr=endhr + hr ))
   (( strthr=endhr - hr ))
   if [ $endhr -eq 24 ]; then
      endhr=00
      (( offset= offset + 12 ))
      (( j=j+1 ))   
   fi
   echo "end hour: $endhr"
   if [ $hr -eq 03  ]; then
      if [[ $strthr -ge 18 && $strthr -le 23 ]]; then
         dir=00
      fi
      if [[ $strthr -ge 12 && $strthr -le 17 ]]; then
         dir=18
      fi
      if [[ $strthr -ge 06 && $strthr -le 11 ]]; then
         dir=12
      fi
      if [[ $strthr -ge 00 && $strthr -le 05 ]]; then
         dir=06
      fi


   fi

   domid=Obs
   if [ ${i}%2 -ne 0 ]; then
      (( offset= offset + 3 ))
   fi
   PDY_dir=`${ndate} +${offset} ${PDY}${strthr}`
   PDY_dir=`echo $PDY_dir | cut -c 1-8`
   echo "###########################"
   valtime=`${ndate} +${hr} ${PDY_dir}${strthr}`
   valpdy=`echo ${valtime} | cut -c 1-8`
   echo "###########################"
   valcyc=`echo ${valtime} | cut -c 9-10`
   valyr=`echo ${valtime}  | cut -c 1-4`
   valmon=`echo ${valtime} | cut -c 5-6`
   
   #set -x
   #There's a bug that when hh=09 hours, it goes to the wrong directory fix here.
#   if [ $hh -eq 09 && $cyc -eq 12 || \
#        $hh -eq 03 && $cyc -eq 18 || \
#        $hh -eq 21 && $cyc -eq 00 || \
#        $hh -eq 15 && $cyc -eq 06 ]; then
   (( check = $hh + $cyc ))
   if [ $check -eq 21 ]; then
      (( offset = offset - 3 ))
      (( PDY_dir=`${ndate} +${offset}  ${PDY}${strthr}` ))
      PDY_dir=`echo $PDY_dir | cut -c 1-8`
   fi

   datadir=${ccpa_dir}/gefs.${PDY_dir}/${dir}/ccpa
   pyplotdir=${pyplot_dir}/pyplot_work_${obstype}.${PDY_dir}_${hr}
   mkdir -p $pyplotdir

   figout=${figout_dir}/pyplot_nest_${obstype}.${PDY_dir}
   mkdir -p $figout
   cd ${pyplotdir}
   
   #set +x   

   echo "Making plot of ${hh}-hr pcp over period $strthr - $endhr"
   echo "The directory for archived ccpa over this period is: ${dir}"
   gbfile[${i}]=${datadir}/ccpa_conus_0.125d_t${endhr}z_${hr}h
   echo "${gbfile[${i}]}" >> "${work_dir}/obsfiles_blackline.txt"
   echo "******************************************************"
   echo "grbfile  : ${gbfile[${i}]}"
   echo `wgrib ${gbfile[${i}]}`
   echo "For 3 hour buckets, bucket $i is..."
   echo "3hr pcp beginning $strthr and valid for $endhr stored in ${dir}"
   echo "Does this look correct (y/n)?"
   #read ans
   echo "******************************************************"

   #if [ $ans == 'n' ];then
   #   exit
   #fi

   echo "valcyc  : $valcyc"
   echo "valpdy  : $valpdy"
   echo "valtime : $valtime"
   echo "hr      : $hr"
   echo "!!!!!!!!!!!!!!!! Bottom of Loop !!!!!!!!!!!!!!!!!!!!!!"
   echo ""
 
   cd ${pyplotdir}

  (( i += 1 ))
done

set -x
cp ${plt_obs_dir}/plt_obs${type}.py ./plt_obs${type}_tmp.py
log_file="${work_dir}/pyobs.log"
python plt_obs${type}_tmp.py ${valpdy} ${valcyc} ${domid} ${num} $clevsOBS $OB_lines ${gbfile[*]} > ${log_file} #| tee -a "${log_file}"

echo "mv *png ${figout}"
mv *png ${figout}/
#rm -f ./plt_obs${type}_tmp.py

exit
