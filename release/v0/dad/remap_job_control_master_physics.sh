#!/bin/sh -l
#SBATCH -o %x.o%j
#SBATCH -J remap_task
#SBATCH -A nems
#SBATCH -q batch
#SBATCH -D .
#SBATCH -n 48
#SBATCH -t 00:20:00
set -ax
. /apps/lmod/lmod/init/sh

cd /scratch1/NCEPDEV/global/Henry.Juang/2019/NEMSfv3gfs/release/v0/dad
CONFIGDIR=/scratch1/NCEPDEV/global/Henry.Juang/2019/NEMSfv3gfs/release/v0/dad/config

##-------------------------------------------------------
## source config file
##-------------------------------------------------------

. /scratch1/NCEPDEV/global/Henry.Juang/2019/NEMSfv3gfs/release/v0/dad/config/workflow.sh repro.config-default-phys-test

export DATA=/scratch1/NCEPDEV/stmp2/Henry.Juang/C96control_master_physics2017011906/gfs.20170119/06/
source /scratch1/NCEPDEV/swpc/Adam.Kubaryk/global-workflow/modulefiles/fv3gfs/fre-nctools.hera
. /scratch1/NCEPDEV/swpc/Adam.Kubaryk/global-workflow/ush/fv3gfs_remap.sh

exit 
