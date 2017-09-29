#!/bin/bash
set -x

USER=$1
LICIP=$2
HOST=`hostname`
DOWN=$3
echo $USER,$LICIP,$HOST,$DOWN

wget -q http://azbenchmarkstorage.blob.core.windows.net/foambenchmarkstorage/20170524_PE_OpenFOAM.tgz -O /mnt/resource/scratch/INSTALLERS/OF_IMPI.tgz
tar -xzf /mnt/resource/scratch/INSTALLERS/OF_IMPI.tgz -C /mnt/resource/scratch/applications/
rm /mnt/resource/scratch/INSTALLERS/*.tgz

echo source /mnt/resource/scratch/applications/OpenFOAM/OpenFOAM-4.x/etc/bashrc >>  /home/$USER/.bashrc



chown -R $USER:$USER /mnt/resource/scratch/*
chown -R $USER:$USER /mnt/nfsshare