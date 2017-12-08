#!/bin/bash
set -x

USER=$1
LICIP=$2
HOST=`hostname`
DOWN=$3
echo $USER,$LICIP,$HOST,$DOWN

export SHARE_DATA=/mnt/resource/scratch
export SHARE_HOME=/home/$USER

sudo yum install -y libXext libXt

axel -q -n 50 http://azbenchmarkstorage.blob.core.windows.net/cdadapcobenchmarkstorage/runAndRecord.java --output=$SHARE_DATA/benchmark/runAndRecord.java
axel -q -n 50 http://azbenchmarkstorage.blob.core.windows.net/cdadapcobenchmarkstorage/STAR-CCM+12.02.010_01_linux-x86_64.tar.gz --output=$SHARE_DATA/INSTALLERS/STAR-CCM+12.02.010_01_linux-x86_64.tar.gz
axel -q -n 50 http://azbenchmarkstorage.blob.core.windows.net/cdadapcobenchmarkstorage/$DOWN --output=$SHARE_DATA/benchmark/$DOWN

tar -xf $SHARE_DATA/benchmark/$DOWN -C $SHARE_DATA/benchmark
tar -xzf $SHARE_DATA/INSTALLERS/STAR-CCM+12.02.010_01_linux-x86_64.tar.gz -C $SHARE_DATA/INSTALLERS/

cd $SHARE_DATA/INSTALLERS/starccm+_12.02.010/

#SET ENV VARS
cat << EOF >> /home/$USER/.bashrc
    echo export PODKey=$LICIP >> $SHARE_HOME/.bashrc
    echo export CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com >> $SHARE_HOME/.bashrc
    echo export PATH=$SHARE_DATA/applications/12.02.010/STAR-CCM+12.02.010/star/bin:$PATH >> $SHARE_HOME/.bashrc
EOF

sh $SHARE_DATA/INSTALLERS/starccm+_12.02.010/STAR-CCM+12.02.010_01_linux-x86_64-2.5_gnu4.8.bin -i silent -DINSTALLDIR=$SHARE_DATA/applications -DNODOC=true -DINSTALLFLEX=false

chown -R $USER:$USER /mnt/resource/scratch/
chown -R $USER:$USER /mnt/nfsshare
