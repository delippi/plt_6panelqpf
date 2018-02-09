#!/bin/ksh --login

export ndate=/home/Donald.E.Lippi/bin/ndate
. setup.ksh

cd ${scp_figs_dir}/figs/scp_figs/
#typeset -Z2 cyc 
#typeset -Z2 fhr 
#typeset -Z8 PDY 
#### FROM SETUP KSH ###############
field=$field                      #
PDY=$date                         #
cyc=$cyc   #starting hour         #
fhr=$fhr #endhr = starthour + fhr #
dom=$dom                          #
exps=$exps                        #
###################################
valtime=`${ndate} +${fhr} ${PDY}${cyc}`
#e.x. 03hrpcp_SC4_2015103018_obs.png

test0=
test1=
test2=
test3=
test4=
test5=

i=0
for exp in $exps; do
  if [[ $i -eq 0 ]]; then
     eval "test$i=${field}_${dom}_${valtime}_ctl0*"
  else
     eval "test$i=${field}_${dom}_${valtime}_exp${i}*"
  fi
  ((i=i+1))
done
obs=${field}_${dom}_${valtime}_obs*
echo $figs

montage -tile 3x2 -geometry +4+4  $test0 $test1 $obs $test2 $test3 $test4 ./${field}_${dom}_${PDY}${cyc}v${valtime}_6panel.png

