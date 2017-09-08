#!/bin/ksh -ex
#PBS -N genplots
#PBS -l walltime=0:30:00
#PBS -l nodes=5:ppn=4
#PBS -q debug
#PBS -A ren
#PBS -o genplots.out
#PBS -j oe

#set -x
cd /home/Donald.E.Lippi/plotting/python/plt_6panelqpf
. setup.ksh

echo "Before you begin, make sure all scripts are correct. A list follows to check:"
echo "${plt_obs_dir}/pyplot_obs${type}.ksh"
echo "${plt_mdl_dir}/pyplot_mdl${type}.ksh"
echo "${scp_figs_dir}/scp_figs.ksh"
echo "${montage_dir}/montage_${type}.ksh"
echo "*****************************************************************************"

echo "Have you double checked each script (y/n)"
#read ans0
ans0='y'; ans1='y'; ans2='y'; ans3='y'; ans4='y'
#ans0='y'; ans1='y'; ans2='n'; ans3='n'; ans4='n'
#ans0='y'; ans1='n'; ans2='n'; ans3='y'; ans4='y'

if [ $ans0 == 'n' ]; then
   exit
fi

echo "Step 1. Would you like to generate plots for observations (y/n)?"
#read ans1

echo "Step 2. Would you like to generate plots for experiments (y/n)?"
#read ans2

echo "Step 3. Would you like to put all figs in the scp directory (y/n)?"
#read ans3

echo "Setp 4. Would you like to generate a 6 panel fig (y/n)?"
#read ans4


if [ $ans1 == 'y' ]; then
   ksh ${plt_obs_dir}/pyplot_obs${type}.ksh > pltobs${type}.txt
fi

if [ $ans2 == 'y' ]; then
   ksh ${plt_mdl_dir}/pyplot_mdl${type}.ksh
fi

if [ $ans3 == 'y' ]; then
   ksh ${scp_figs_dir}/scp_figs.ksh
fi

if [ $ans4 == 'y' ]; then
   ksh ${montage_dir}/montage_${type}.ksh
fi





