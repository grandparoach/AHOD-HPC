#!/bin/bash
#set -x

USER=$1
LICIP=$2
HOST=`hostname`
DOWN=$3
echo $USER,$LICIP,$HOST,$DOWN

VERSION=echo $DATA | awk -F'-' '{print $2}'

export SHARE_DATA=/mnt/resource/scratch
export SHARE_HOME=/home/$USER

sudo yum install -y libXext libXt

axel -q -n 50 http://azbenchmarkstorage.blob.core.windows.net/cdadapcobenchmarkstorage/runAndRecord.java --output=$SHARE_DATA/benchmark/runAndRecord.java
axel -q -n 50 http://azbenchmarkstorage.blob.core.windows.net/cdadapcobenchmarkstorage/STAR-CCM+12.04.010_01_linux-x86_64.tar.gz --output=$SHARE_DATA/INSTALLERS/STAR-CCM+12.04.010_01_linux-x86_64.tar.gz
axel -q -n 50 http://azbenchmarkstorage.blob.core.windows.net/cdadapcobenchmarkstorage/$DOWN --output=$SHARE_DATA/benchmark/$DOWN

tar -xf $SHARE_DATA/benchmark/$DOWN -C $SHARE_DATA/benchmark
tar -xzf $SHARE_DATA/INSTALLERS/STAR-CCM+12.04.010_01_linux-x86_64.tar.gz -C $SHARE_DATA/INSTALLERS/

cd $SHARE_DATA/INSTALLERS/starccm+_12.04.010/

#SET ENV VARS
cat << EOF >> /home/$USER/.bashrc
export PODKey=$LICIP
export CDLMD_LICENSE_FILE=1999@flex.cd-adapco.com
export PATH=$SHARE_DATA/applications/12.04.010/STAR-CCM+12.04.010/star/bin:$PATH
EOF

sh $SHARE_DATA/INSTALLERS/starccm+_12.04.010/STAR-CCM+12.04.010_01_linux-x86_64-2.5_gnu4.8.bin -i silent -DINSTALLDIR=$SHARE_DATA/applications -DNODOC=true -DINSTALLFLEX=false
