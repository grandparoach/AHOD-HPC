#!/bin/bash
set -x

USER=$1
LICIP=$2
HOST=`hostname`
DOWN=$3
echo $USER,$LICIP,$HOST,$DOWN
touch HELLO
export SHARE_DATA=$SHARE_DATA
export SHARE_HOME=/home/$USER

wget -q http://azbenchmarkstorage.blob.core.windows.net/foambenchmarkstorage/20170524_PE_OpenFOAM.tgz -O $SHARE_DATA/INSTALLERS/OF_IMPI.tgz
tar -xzf $SHARE_DATA/INSTALLERS/OF_IMPI.tgz -C $SHARE_DATA/applications/
#rm $SHARE_DATA/INSTALLERS/*.tgz

echo source $SHARE_DATA/applications/OpenFOAM/OpenFOAM-4.x/etc/bashrc >>  /home/$USER/.bashrc

chown -R $USER:$USER $SHARE_DATA/*
chown -R $USER:$USER /mnt/nfsshare