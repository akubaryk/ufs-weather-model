#!/bin/sh

SCRIPTSDIR=`pwd`
CONFIGDIR=$SCRIPTSDIR/config
CONFIG=$1

## source config
. $CONFIGDIR/workflow.sh $1
export ACCT_SLURM=${ACCT_SLURM:-$ACCT_PBS}

## create job file
rm -rf temp_job.sh
touch temp_job.sh
chmod +x temp_job.sh

cat >> temp_job.sh << EOF
#!/bin/sh -l
#SBATCH -J $PSLOT
#SBATCH -o %x.o%j
#SBATCH -A $ACCT_SLURM
# --- orion then turn on -p
# #SBATCH -p $PARTITION 
#SBATCH -q $QUEUE 
#SBATCH -n $tasks --ntasks-per-node=$task_per_node
#SBATCH -t $WALLCLOCK
# walltime should be a resolution and fcst length thing imo
set -ax
# ---- orion
#. /apps/lmod/init/sh
# ---- hera
 . /apps/lmod/lmod/init/sh

cd $SCRIPTSDIR
CONFIGDIR=$CONFIGDIR
##-------------------------------------------------------
## source config file
##-------------------------------------------------------

. $CONFIGDIR/workflow.sh $1

##-------------------------------------------------------
## perform chgres if necessary
##-------------------------------------------------------

if [ $CHGRES != "NO" ] ; then
module purge
# ---- orion
#source $GLOBAL_WORKFLOW_DIR/modulefiles/fv3gfs/global_chgres.theia
# ---- hera
 source $GLOBAL_WORKFLOW_DIR/modulefiles/fv3gfs/global_chgres.hera

export OUTDIR=$IC_DIR/IDVT${IDVT}/L${LEVS}/CASE_$CASE
. $CHGRESWRAPPER
fi

##-------------------------------------------------------
## execute FV3 forecast
##-------------------------------------------------------
if [ ${CHGRES_ONLY:-"NO"} != "YES" ] ; then
export VERBOSE=YES
export CCPP_SUITE=$BASEDIR/FV3/ccpp/suites/suite_FV3_GFS_2017_fv3wam.xml
module purge
module unuse ../../../NEMS/src/conf
module use -a $BASEDIR/NEMS/src/conf
module load modules.nems
. $FCSTSH

##-------------------------------------------------------
## convert 6-tile output to global array in netCDF format
##-------------------------------------------------------
cd $SCRIPTSDIR
sbatch < remap_job_$PSLOT.sh

rm -f remap_job_$PSLOT.sh

fi

exit $status
EOF

cat >> remap_job_$PSLOT.sh << EOF
#!/bin/sh -l
#SBATCH -o %x.o%j
#SBATCH -J remap_task
#SBATCH -A $ACCT_SLURM
#SBATCH -q batch
#SBATCH -D .
#SBATCH -n $REMAP_TASKS
#SBATCH -t 00:20:00
set -ax
# ---- orion
#. /apps/lmod/init/sh
# ---- hera
 . /apps/lmod/lmod/init/sh

cd $SCRIPTSDIR
CONFIGDIR=$CONFIGDIR

##-------------------------------------------------------
## source config file
##-------------------------------------------------------

. $CONFIGDIR/workflow.sh $1

export DATA=${MEMDIR:-$ROTDIR/${PREINP:-"gfs"}.${yyyymmdd:-`echo $CDATE | cut -c1-8`}/${hh:-`echo $CDATE | cut -c9-10`}/${MEMCHAR:-""}}
# ---- orion
#source $GLOBAL_WORKFLOW_DIR/modulefiles/fv3gfs/fre-nctools.orion
# ---- hera
 source $GLOBAL_WORKFLOW_DIR/modulefiles/fv3gfs/fre-nctools.hera

. $REMAPSH

exit $status
EOF

# submit job file
sbatch < temp_job.sh

# remove temp job file
#rm -f temp_job.sh

exit
