#!/bin/ksh
echo
echo "This is the beginning of setup."
export ndate=/home/Donald.E.Lippi/bin/ndate

################# USER INPUT! #############################
# FILEDS: 1) refc, 2) 06hrpcp, 3) 3hrpcp                 ##
export type='qpf'                                        ##
export date=20151030                                     ##
export cyc=12                                            ##
export fhr=09 # fhr=06 for '06hrpcp'                     ##
export field="09hrpcp"                                   ##
Cn0='Control';     C0='c003' #c002,c003                  ## 
Xn1='w_only';      X1=010   #003,010                     ##
#Xn2='w_so_elev5';  X2=011   #008,011                     ##
#Xn3='w_so_elev10'; X3=012   #006,012                     ##
#Xn4='so_elev10';   X4=013   #009,013                     ##
charmax=15 #must be bigger than experiment names         ##
export dom='SC4'                                         ##
export clevsOBS="0.01,0.75,4.0"      # no spaces         ##
export OB_lines=.true. # .true. if you want ob contours  ####################################
export diff=.true.   # compute pcp difference plots, if true                               ##
export diff_grid="_g221" # the NCEP grid in which the difference is to be computed  _g221  ##
export plt_obs_dir=/home/Donald.E.Lippi/plotting/python/plt_6panel${type}/plt_obs${type}/  ##
export plt_mdl_dir=/home/Donald.E.Lippi/plotting/python/plt_6panel${type}/plt_mdl${type}/  ##
export plt_pcp_dif=/home/Donald.E.Lippi/plotting/python/plt_6panel${type}/plt_diff${type}/ ##
export scp_figs_dir=/home/Donald.E.Lippi/plotting/python/plt_6panel${type}                 ##
export montage_dir=/home/Donald.E.Lippi/plotting/python/plt_6panel${type}                  ##
#export work_dir=/home/Donald.E.Lippi/plotting/python/plt_6panel${type}                    ##
export work_dir=/home/Donald.E.Lippi/plotting/python/plt_6panel${type}                     ##
export ccpa_dir=/home/Donald.E.Lippi/imagemagic/data/                                      ##
export figout_dir=/scratch4/NCEPDEV/stmp4/Donald.E.Lippi/                                  ##
export pyplot_dir=/scratch4/NCEPDEV/stmp4/Donald.E.Lippi/                                  ##
#############################################################################################

# check for fhr and field consistency.
f=`echo $field | cut -c 1-2`
if [[ $fhr -ne $f ]]; then
   echo "$fhr and $field are not consistent. exiting..."
   exit
fi

export ymdhcyc=${date}${cyc}
export vymdh=`${ndate} +${fhr} ${ymdhcyc}`
export PDY=`echo $vymdh | cut -c 1-8`
export FIGDIR=/scratch4/NCEPDEV/stmp4/Donald.E.Lippi/
####### GET NUM EXPERIMETS + CTL #############
i=0
num=0
exps=""; expsn=""
echo "###################################"
while [[ i -lt 10 ]]; do
    eval "blahC=\$C$i" #check for control run -- hint: this is a string
    eval "blahX=\$X$i" #check for experimental run -- hint: this is a number.
    eval "blahCn=\$Cn${i}"
    eval "blahXn=\$Xn${i}"
    if   [[ $blahC  != "" ]]; then # != for strings
       n=`echo $blahCn | wc -c`; ((n = charmax-n))
       printf "# %5s $blahC %4s $blahCn %${n}s #\n"
       exps=`echo $exps $blahC`
       expsn=`echo $expsn $blahCn`
       ((num=num+1))
    elif [[ $blahX -ne "" ]]; then # -ne for numbers
       n=`echo $blahXn | wc -c`; ((n = charmax-n))
       printf "# %5s $blahX %5s $blahXn %${n}s #\n"
       exps=`echo $exps $blahX`
       expsn=`echo $expsn $blahXn`
       ((num=num+1))
    fi
    ((i=i+1))
done
echo "###################################"
echo "number of experiments + control = $num"
export num
export exps; export expsn
#echo "exps  = $exps"
#echo "expsn = $expsn"
##############################################


####### MAKE THE EXPS "ARRAY" ################
i=0
exps_gen=""
#echo "exps_gen: $exps_gen"
while [[ i -lt $num ]]; do
   if [[ $i -eq 0 ]]; then
      exps_gen=`echo ctl0`
   else
      exps_gen=`echo $exps` 
   fi
#echo "exps_gen: $exps_gen"
   ((i=i+1))
done
export exps_gen
echo "exps array: $exps_gen" #debug
#############################################


######## DYNAMICALLY SET THE ctl0, exp1, etc.'s file paths ####################
i=0
for exp in $exps; do
   if [[ $i -eq 0 ]]; then
      #echo "ctl$i=${FIGDIR}/pyplot_nest_rw_${C0}.${date}/${field}_${dom}_${C0}_${ymdhcyc}00v${vymdh}.png"
      export eval "ctl$i=${FIGDIR}/pyplot_nest_rw_${C0}.${date}/${field}_${dom}_${C0}_${ymdhcyc}00v${vymdh}.png"
   else
      eval "X=\$X$i"
      export eval "exp$i=${FIGDIR}/pyplot_nest_rw_${X}.${date}/${field}_${dom}_${X}_${ymdhcyc}00v${vymdh}.png" 
   fi
   ((i=i+1))
done

export obs=/scratch4/NCEPDEV/stmp4/Donald.E.Lippi/pyplot_nest_obsrefd.${PDY}/${field}_${dom}_Obs_${vymdh}*
###############################################################################

#### THIS IS REALLY COOL!! #####
#i=1                           #
#exps=""                       #
#while [[ $i -lt $num ]]; do   #
#   eval "blah=\$exp$i"        #
#   exps=`echo $exps $blah`    #
#   ((i=i+1))                  #
#done                          #
#export exps=`echo $ctl0 $exps`#
################################
echo "This is the end of setup."
echo "************************************"
echo
