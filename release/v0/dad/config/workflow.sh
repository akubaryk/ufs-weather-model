#!/bin/sh
CONFIGDIR=`pwd`/config
# --- orion
#. /apps/lmod/init/sh
# --- hera
 . /apps/lmod/lmod/init/sh

# modules
# --- orion
#module use -a ../../../modulefiles/orion.intel
#module load fv3
# --- hera
 module use -a ../../../NEMS/src/conf
 module load modules.nems

##-------------------------------------------------------
## configuration for FV3 model run
##-------------------------------------------------------
# experiment configuration, most user settings are in here
. $CONFIGDIR/../$1
# set defaults for stuff not listed in user.config
. $CONFIGDIR/default.config
# resolution specific configurations
. $CONFIGDIR/res.config
# machine-specific directory structure, experiment dircetories, etc.
. $CONFIGDIR/dir.config
# point to forecast, remap, chgres scripts
. $CONFIGDIR/scripts.config
# configure computational settings
. $CONFIGDIR/compute.config
# configure chgres
. $CONFIGDIR/chgres.config
# remap configuration (if performing based on exp.config)
if [ $REMAP = "YES" ] ; then
. $CONFIGDIR/remap.config
fi
. $CONFIGDIR/multi_gases.config

