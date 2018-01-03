#!/bin/bash
#set -x

USER=$1
LICIP=$2
HOST=`hostname`
DOWN=$3
echo $USER,$LICIP,$HOST,$DOWN


export SHARE_DATA=/mnt/resource/scratch
export SHARE_HOME=/home/$USER

sudo yum install fontconfig freetype freetype-devel fontconfig-devel libstdc++ libXext libXt libXrender-devel.x86_64 libXrender.x86_64 mesa-libGL.x86_64

mkdir -p /mnt/resource/scratch/INSTALLERS/ANSYS

axel -q -n 10 http://azbenchmarkstorage.blob.core.windows.net/ansysbenchmarkstorage/$DOWN --output=$SHARE_DATA/benchmark/$DOWN
wget  https://raw.githubusercontent.com/tanewill/AHOD-HPC/master/scripts/run_fluent.jou -O $SHARE_DATA/benchmark/run_fluent.jou
axel -q -n 10 http://azbenchmarkstorage.blob.core.windows.net/ansysbenchmarkstorage/ANSYS_182.tgz --output=$SHARE_DATA/ANSYS.tgz

tar -xf $SHARE_DATA/ANSYS.tgz -C $SHARE_DATA/INSTALLERS
tar -xf $SHARE_DATA/benchmark/$DOWN -C $SHARE_DATA/benchmark

mv $SHARE_DATA/benchmark/bench/fluent/v6/*/cas_dat/*.dat.gz $SHARE_DATA/benchmark/benchmark.dat.gz
mv $SHARE_DATA/benchmark/bench/fluent/v6/*/cas_dat/*.cas.gz $SHARE_DATA/benchmark/benchmark.cas.gz

cd $SHARE_DATA/INSTALLERS/ANSYS/
mkdir -p $SHARE_DATA/applications/ansys_inc/shared_files/licensing/

echo SERVER=1055@$LICIP > $SHARE_DATA/applications/ansys_inc/shared_files/licensing/ansyslmd.ini
echo ANSYSLI_SERVERS=2325@$LICIP >> $SHARE_DATA/applications/ansys_inc/shared_files/licensing/ansyslmd.ini

cat << EOF >> /home/azureuser/.bashrc
export PATH=/mnt/resource/scratch/applications/ansys_inc/v182/fluent/bin:/opt/intel/impi/5.1.3.181/bin64:$PATH
EOF

chown -R $1:$1 $SHARE_DATA
sudo yum install -y fontconfig freetype freetype-devel fontconfig-devel libstdc++ libXext libXt libXrender-devel.x86_64 libXrender.x86_64 mesa-libGL.x86_64

source $SHARE_DATA/INSTALLERS/ANSYS/INSTALL -silent -install_dir "/mnt/resource/scratch/applications/ansys_inc/" -fluent
#source /mnt/resource/scratch/INSTALLERS/ANSYS/INSTALL -silent -install_dir "/mnt/resource/scratch/applications/ansys_inc/" -cfx
#fluent 3d -g -mpi=intel -pib.dapl -mpiopt="-genv I_MPI_DAPL_PROVIDER=ofa-v2-ib0" -ssh -t20 -cnf=/mnt/resource/scratch/hostips -i run_fluent.jou
#fluent 3d -g -mpi=pcmpi -pethernet -mpiopt="-genv I_MPI_FABRICS=shm:tcp" -ssh -t32 -cnf=/mnt/resource/scratch/hostips -i run_fluent.jou
