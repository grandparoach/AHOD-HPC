#!/bin/bash
echo ##################################################
echo ############# Compute Node Setup #################
echo ##################################################
IPPRE=$1
USER=$2
GANG_HOST=$3
HOST=`hostname`
if grep -q $IPPRE /etc/fstab; then FLAG=MOUNTED; else FLAG=NOTMOUNTED; fi


if [ $FLAG = NOTMOUNTED ] ; then 
    echo $FLAG
    echo installing NFS and mounting
    yum install -y -q nfs-utils
    mkdir -p /mnt/nfsshare
    mkdir -p /mnt/resource/scratch
    chmod 777 /mnt/nfsshare
    systemctl enable rpcbind
    systemctl enable nfs-server
    systemctl enable nfs-lock
    systemctl enable nfs-idmap
    systemctl start rpcbind
    systemctl start nfs-server
    systemctl start nfs-lock
    systemctl start nfs-idmap
    localip=`hostname -i | cut --delimiter='.' -f -3`
    echo "$IPPRE:/mnt/nfsshare    /mnt/nfsshare   nfs defaults 0 0" | tee -a /etc/fstab
    echo "$IPPRE:/mnt/resource/scratch    /mnt/resource/scratch   nfs defaults 0 0" | tee -a /etc/fstab
    mount -a
    df | grep $IPPRE
    impi_version=`ls /opt/intel/impi`
    source /opt/intel/impi/${impi_version}/bin64/mpivars.sh
    ln -s /opt/intel/impi/${impi_version}/intel64/bin/ /opt/intel/impi/${impi_version}/bin
    ln -s /opt/intel/impi/${impi_version}/lib64/ /opt/intel/impi/${impi_version}/lib
    

    #SET ENV VARS
    cat << EOF >> /home/$USER/.bashrc
        if [ -d "/opt/intel/impi" ]; then
            source /opt/intel/impi/*/bin64/mpivars.sh
        fi
        export FLUENT_HOSTNAME=$HOST
        export PATH=/home/$USER/bin:/mnt/resource/scratch/scripts:\$PATH
        export INTELMPI_ROOT=/opt/intel/impi/${impi_version}
        export I_MPI_FABRICS=shm:dapl
        export I_MPI_DAPL_PROVIDER=ofa-v2-ib0
        export I_MPI_DYNAMIC_CONNECTION=0
        #export I_MPI_DAPL_TRANSLATION_CACHE=0 only un comment if you are having application stability issues
        echo export WCOLL=/mnt/resource/scratch/hosts >> /home/$USER/.bashrc
        #export I_MPI_PIN_PROCESSOR=8 
EOF
    #chown -R $USER:$USER /mnt/resource/

    sh /mnt/resource/scratch/scripts/install_ganglia.sh $GANG_HOST azure 8649
    ln -s /mnt/resource/scratch/ /home/$USER/scratch

    # Don't require password for HPC user sudo
    echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

else
    echo already mounted
    df | grep $IPPRE
fi
