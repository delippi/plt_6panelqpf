#! bin/ksh
#set -x
export ndate=/home/Donald.E.Lippi/bin/ndate

# Source the setup script for file names and paths!
. setup.ksh 
echo ""
echo "This is the beginning of scp"
# The rest here is the scp script! This puts things in a sinlge directory
# so it can be scp'd easily to a local machine!
if [[ `echo $field | cut -c 3-7` == 'hrpcp' && `echo $type` == qpf ]]; then
   #obs=/scratch4/NCEPDEV/stmp4/Donald.E.Lippi/pyplot_nest_obsqpf.${PDY}/${field}_${dom}_Obs_${vymdh}*
   obs=${pyplot_dir}/pyplot_nest_obsqpf.${PDY}/${field}_${dom}_Obs_${vymdh}*
   echo "obs = $obs"
fi
if [[ `echo $field` == 'tmp' && `echo $type` == 'tmp' ]]; then
   echo "***WARNING*** NEED TO REDO THIS!"
   exit
fi


#scpfigs=/scratch4/NCEPDEV/meso/noscrub/Donald.E.Lippi/figs/scp_figs
scpfigs=${scp_figs_dir}/figs/scp_figs
mkdir -p $scpfigs 

if [ $field == 'refc' ]; then
   echo "***WARNING*** NEED TO REDO THIS!"
   exit
   cp $ctl0 ${scpfigs}/${field}_${ymdhcyc}_${fhr}_${vymdh}_ctl0.png
   cp $exp1 ${scpfigs}/${field}_${ymdhcyc}_${fhr}_${vymdh}_exp1.png
   cp $exp2 ${scpfigs}/${field}_${ymdhcyc}_${fhr}_${vymdh}_exp2.png
   cp $exp3 ${scpfigs}/${field}_${ymdhcyc}_${fhr}_${vymdh}_exp3.png
   cp $obs  ${scpfigs}/${field}_${ymdhcyc}_${fhr}_${vymdh}_obs.png
fi

hrpcp=`echo $field | cut -c 3-7`
#if [ $hrpcp == 'hrpcp'  ]; then
   filename="${field}_${dom}_${vymdh}"

   i=0
   for exp in $exps_gen; do
      echo "$i $exp"
      if [[ $i -eq 0 ]]; then
         cp $ctl0 ${scpfigs}/${filename}_ctl${i}.png
      else
         eval "expi=\$exp$i"
         echo "cp $expi ${scpfigs}/${filename}_exp${i}.png"
         cp $expi ${scpfigs}/${filename}_exp${i}.png
      fi
      ((i=i+1))
   done
   cp $obs ${scpfigs}/${filename}_obs.png
#   i=0
#   for exp in $exps; do
#      eval "blah=\$exp$i"
#      if [[ $i -eq 0 ]]; then
#         echo "cp $blah ${scpfigs}/${filename}_ctl0"
#         cp $blah ${scpfigs}/${filename}_ctl0
#      else
#         echo "cp $blah ${scpfigs}/${filename}_exp${i}"
#         cp $blah ${scpfigs}/${filename}_exp${i}
#      fi
#      ((i=i+1))
#   done
#fi

echo "your files are located here:"
echo "    $scpfigs"
echo ""
echo "scp_figs.ksh done!"

