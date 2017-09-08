#! bin/ksh

set -x

export ndate=/home/Donald.E.Lippi/bin/ndate

# Source the setup script for file names and paths!
. setup.ksh

# The rest here is the view figs script!
i=0
for exp in $exps; do
   if [[ $i -eq 0 ]]; then
      echo "$i control"
      ln -sf $ctl0 ./ctl0
      display $ctl0 &
   else
      echo "$i exp"
      eval "expi=\$exp$i"
      ln -sf $expi ./exp${i}
      display $expi &
   fi
   ((i=i+1))
done
obs=/scratch4/NCEPDEV/stmp4/Donald.E.Lippi/pyplot_nest_obsrefd.${PDY}/${field}_${dom}_Obs_${vymdh}*
if [ $field != 'refc' ]; then
   obs=/scratch4/NCEPDEV/stmp4/Donald.E.Lippi/pyplot_nest_obsqpf.${PDY}/${field}_${dom}_Obs_${vymdh}*
fi

ln -sf $obs  ./obs

echo 'obs'
display ./obs &
sleep 0.25
