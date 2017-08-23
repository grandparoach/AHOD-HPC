#!/bin/bash
SOLVER=$1
USER=$2
PASS=$3
DOWN=$4
LICIP=$5


IP=`ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
localip=`echo $IP | cut --delimiter='.' -f -3`
myhost=`hostname`

echo User is: $USER
echo Pass is: $PASS
echo License IP is: $LICIP
echo Model is: $DOWN

cat << EOF >> /etc/security/limits.conf
*               hard    memlock         unlimited
*               soft    memlock         unlimited
EOF

#Create directories needed for configuration
mkdir -p /home/$USER/.ssh
mkdir -p /home/$USER/bin
mkdir -p /mnt/resource/scratch/applications
mkdir -p /mnt/resource/scratch/INSTALLERS
mkdir -p /mnt/resource/scratch/benchmark

#Following lines are only needed if the head node is an RDMA connected VM
#impi_version=`ls /opt/intel/impi`
#source /opt/intel/impi/${impi_version}/bin64/mpivars.sh
#ln -s /opt/intel/impi/${impi_version}/intel64/bin/ /opt/intel/impi/${impi_version}/bin
#ln -s /opt/intel/impi/${impi_version}/lib64/ /opt/intel/impi/${impi_version}/lib

#Install needed packages
yum install -y -q epel-release
yum install -y -q nfs-utils sshpass nmap htop pdsh screen git psmisc
yum groupinstall -y "X Window System"

#Use ganglia install script to install ganglia, this is downloaded via the ARM template
chmod +x install_ganglia.sh
./install_ganglia.sh $myhost azure 8649

#Setup the NFS server
echo "/mnt/resource/scratch $localip.*(rw,sync,no_root_squash,no_all_squash)" | tee -a /etc/exports
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
systemctl restart nfs-server

mv clusRun.sh cn-setup.sh /home/$USER/bin
chmod +x /home/$USER/bin/*.sh
chown $USER:$USER /home/$USER/bin
nmap -sn $localip.* | grep $localip. | awk '{print $5}' > /home/$USER/bin/hostips

sed -i '/\<'$IP'\>/d' /home/$USER/bin/hostips

echo -e  'y\n' | ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''
echo 'Host *' >> /home/$USER/.ssh/config
echo 'StrictHostKeyChecking no' >> /home/$USER/.ssh/config
chmod 400 /home/$USER/.ssh/config
chown $USER:$USER /home/$USER/.ssh/config

mkdir -p ~/.ssh
echo 'Host *' >> ~/.ssh/config
echo 'StrictHostKeyChecking no' >> ~/.ssh/config
chmod 400 ~/.ssh/config

for NAME in `cat /home/$USER/bin/hostips`; do sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'hostname' >> /home/$USER/bin/hosts;done
NAMES=`cat /home/$USER/bin/hostips` #names from names.txt file

for name in `cat /home/$USER/bin/hostips`; do
        sshpass -p "$PASS" ssh $USER@$name "mkdir -p .ssh"
        cat /home/$USER/.ssh/config | sshpass -p "$PASS" ssh $USER@$name "cat >> .ssh/config"
        cat /home/$USER/.ssh/id_rsa | sshpass -p "$PASS" ssh $USER@$name "cat >> .ssh/id_rsa"
        cat /home/$USER/.ssh/id_rsa.pub | sshpass -p "$PASS" ssh $USER@$name "cat >> .ssh/authorized_keys"
        sshpass -p "$PASS" ssh $USER@$name "chmod 700 .ssh; chmod 640 .ssh/authorized_keys; chmod 400 .ssh/config; chmod 400 .ssh/id_rsa"
        cat /home/$USER/bin/hostips | sshpass -p "$PASS" ssh $USER@$name "cat >> /home/$USER/hostips"
        cat /home/$USER/bin/hosts | sshpass -p "$PASS" ssh $USER@$name "cat >> /home/$USER/hosts"
        cat /home/$USER/bin/cn-setup.sh | sshpass -p "$PASS" ssh $USER@$name "cat >> /home/$USER/cn-setup.sh"
        sshpass -p $PASS ssh -t -t -o ConnectTimeout=2 $USER@$NAME 'echo "'$PASS'" | sudo -S sh /home/'$USER'/cn-setup.sh '$IP $USER $myhost &
done

cp /home/$USER/bin/hosts /mnt/resource/scratch/hosts
chown -R $USER:$USER /home/$USER/.ssh/
chown -R $USER:$USER /home/$USER/bin/
chown -R $USER:$USER /mnt/resource/scratch/
chmod -R 744 /mnt/resource/scratch/

# Don't require password for HPC user sudo
echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    
# Disable tty requirement for sudo
sed -i 's/^Defaults[ ]*requiretty/# Defaults requiretty/g' /etc/sudoers

chmod +x install-$SOLVER.sh
source install-$SOLVER.sh $USER $LICIP $DOWN


