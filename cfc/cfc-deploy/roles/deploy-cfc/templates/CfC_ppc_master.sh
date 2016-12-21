#!/bin/bash
#-------------------------------------------------------------------------------
# The Master script to automate Spectrum Conductor for Containers installation
# Author: Ninad Sathaye
# Initial commit: Nov 11, 2016
# TODO: Needs more testing, documentation, to be revised further. 
# See Also: setup_passwordless_ssh, docker_installer.sh cfc_installer.sh
#-------------------------------------------------------------------------------

# echo "Shell script to automate Spectrum Conductor for Containers installation"
# echo "System assumptions: Ubuntu 16.04 on Power"
# echo "Make sure you login as root (sudo -i) on the master node before running this setup"
# echo "-------------------------------------------------------------------------"

# echo "Enter master node ip: "
# read m_ip
# echo "Enter worker node ip: "
# read w_ip
# echo "Master_ip: $m_ip, Worker ip: $w_ip"
# echo "Enter root password. Assumed identical for all the nodes (you can change it later): "
# read root_pw

m_ip=`getent hosts auto_master | awk '{ print $1 }'`
w_ip=`getent hosts auto_worker | awk '{ print $1 }'`
root_pw='XdsOeD0MgwCsxFjjGzJhteOdt8ws6j1OD0EqkJ1W'



# Working directory for CfC installation (can be a user input in future)
cfc_dir='/home/ubuntu/cfc'

#-------------------------------------------------------------------------------
# ssh commandline args. These basically ignore the one time  messages that
# asks user to permanently add the given node to the known_hosts.
# UPDATE [Nov 16, 2016]: 
#   Instead, use ssh-keyscan to copy the ip to the known_hosts file.
#   This eliminates the need of sshopts. Setting it to empty string. 
#-------------------------------------------------------------------------------
##ssh_opts='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
ssh_opts=''

# ------------------------------------------------------------------------------
# To avoid clutter, create a new variable to represent password-provided scp 
# and ssh with some optional args.
# TODO: shell doesn't seem to like the string. Perhaps echo it? Disabling it.
# ------------------------------------------------------------------------------
##SCP_CMD="sshpass -p$root_pw scp $ssh_opts"
##SSH_CMD="sshpass -p$root_pw ssh -t $ssh_opts"

# ------------------------------------------------------------------------------
# Remove the known_hosts file (perhaps required by the cfc_installer.sh)
# We are doing this on the master/boot node , make sure you are logged in as
# root using sudo su - command. 
# ------------------------------------------------------------------------------
# rm -rf /root/.ssh/known_hosts

# ------------------------------------------------------------------------------
# Re-add the ips to known hosts to avoid the prompt during ssh 
# ------------------------------------------------------------------------------
mkdir -p /root/.ssh
ssh-keyscan -H $m_ip >> /root/.ssh/known_hosts
ssh-keyscan -H $w_ip >> /root/.ssh/known_hosts

# ------------------------------------------------------------------------------
# Install sshpass first
# ------------------------------------------------------------------------------
# echo $root_pw | sudo -S apt-get update
# echo $root_pw | sudo -S apt install sshpass

#-------------------------------------------------------------------------------
# Setup the passwordless ssh
#-------------------------------------------------------------------------------
# ./setup_passwordless_ssh $m_ip $w_ip $root_pw
./ssh_key_auth.sh $m_ip $w_ip $root_pw

## debug--> ssh -vvv -i cluster/ssh_key root@9.126.171.224 2>&1  | tee out

# set +x

# Copy the required docker installer script in each master and worker nodes.
sshpass -p$root_pw scp $ssh_opts docker_installer.sh root@$m_ip:/home/ubuntu/
sshpass -p$root_pw scp $ssh_opts docker_installer.sh root@$w_ip:/home/ubuntu/

# Do the docker installation
sshpass -p$root_pw ssh -t $ssh_opts root@$m_ip "echo $root_pw | sudo -S sh /home/ubuntu/docker_installer.sh 2>&1 | tee docker_install.out"
sshpass -p$root_pw ssh -t $ssh_opts root@$w_ip "echo $root_pw | sudo -S sh /home/ubuntu/docker_installer.sh 2>&1 | tee docker_install.out"

# Do the actual CfC installation

# echo "Run CfC preparatory setup on master node"
sh /home/ubuntu/cfc_installer.sh $m_ip $w_ip $cfc_dir

cfc_dir='/home/ubuntu'
cd $cfc_dir

# echo "Run CfC preparatory setup on worker node"
sshpass -p$root_pw scp $ssh_opts cfc_installer.sh root@$w_ip:/home/ubuntu/
sshpass -p$root_pw ssh -t $ssh_opts root@$w_ip "echo $root_pw | sudo -S sh /home/ubuntu/cfc_installer.sh $m_ip $w_ip $cfc_dir 2>&1 | tee cfc_install.out"


#Install
# echo "*******************"
# echo "Run the cfc installer"
# echo "*******************"

# ------------------------------------------------------------------------------
# 3. Deploy your environment. This command must be run from the working
# directory. Your working directory is the directory that contains the cluster
# directory.
# ------------------------------------------------------------------------------
cfc_dir='/home/ubuntu/cfc'
cd $cfc_dir
# echo `pwd`

docker run -e LICENSE=view -e LICENSE=accept --rm -v "$(pwd)/cluster":/installer/cluster ibmcom/cfc-installer-ppc64le:0.1.0 install

# The following command is when we are connected to 9.* network. 
# docker run --rm -v $(pwd)/cluster:/installer/cluster ma1dock1.platformlab.ibm.com/daily/cfc-installer-ppc64le install

# echo "-------------------------------------------------------------------------"
# echo "END of the CfC installer script"
# echo "-------------------------------------------------------------------------"


