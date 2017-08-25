#!/bin/bash
USER=$1
LICIP=$2
HOST=`hostname`
DOWN=$3
echo $USER,$LICIP,$HOST,$DOWN

wget -q http://azbenchmarkstorage.blob.core.windows.net/foambenchmarkstorage/20170524_PE_OpenFOAM.tgz -O /mnt/resource/scratch/INSTALLERS/OF_IMPI.tgz
tar -xzf /mnt/resource/scratch/INSTALLERS/OF_IMPI.tgz -C /mnt/resource/scratch/applications/
rm /mnt/resource/scratch/INSTALLERS/*.tgz

echo export HOSTS=/home/$USER/bin/nodenames.txt >> /home/$USER/.bashrc
echo export INTELMPI_ROOT=/opt/intel/impi/5.1.3.181 >> /home/$USER/.bashrc
echo export I_MPI_FABRICS=shm:dapl >> /home/$USER/.bashrc
echo export I_MPI_DAPL_PROVIDER=ofa-v2-ib0 >> /home/$USER/.bashrc
echo export I_MPI_ROOT=/opt/intel/compilers_and_libraries_2016.2.181/linux/mpi >> /home/$USER/.bashrc
echo export I_MPI_DYNAMIC_CONNECTION=0 >> /home/$USER/.bashrc
echo export I_MPI_PIN_PROCESSOR=8 >> /home/$USER/.bashrc
echo export MPI_ROOT='$I_MPI_ROOT' >>  /home/$USER/.bashrc
echo export I_MPI_DAPL_TRANSLATION_CACHE=0 >>  /home/$USER/.bashrc
echo source /mnt/resource/scratch/applications/OpenFOAM/OpenFOAM-4.x/etc/bashrc >>  /home/$USER/.bashrc

NAMES=`cat /home/$USER/bin/nodeips.txt` #names from names.txt file
for NAME in $NAMES; do
    ssh -o ConnectTimeout=2 $USER@$NAME 'echo export MPI_ROOT=$I_MPI_ROOT >>  /home/'$USER'/.bashrc'
    ssh -o ConnectTimeout=2 $USER@$NAME 'echo export I_MPI_DAPL_TRANSLATION_CACHE=0 >>  /home/'$USER'/.bashrc'
    #ssh -o ConnectTimeout=2 $USER@$NAME 'echo export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/mnt/resource/scratch/applications/intel2/compilers_and_libraries_2016.4.258/linux/compiler/lib/intel64_lin >>  /home/'$USER'/.bashrc'
    #ssh -o ConnectTimeout=2 $USER@$NAME "sed -i 's/FOAM_INST_DIR\=\/opt\/\$WM_PROJECT/FOAM_INST_DIR\=\/mnt\/resource\/scratch\/applications\/\$WM_PROJECT/' /mnt/resource/scratch/applications/OpenFOAM/OpenFOAM-4.0/etc/bashrc"
    ssh -o ConnectTimeout=2 $USER@$NAME 'echo source /mnt/resource/scratch/applications/OpenFOAM/OpenFOAM-4.x/etc/bashrc >>  /home/'$USER'/.bashrc'
    
done

chown -R $USER:$USER /mnt/resource/scratch/*
chown -R $USER:$USER /mnt/nfsshare