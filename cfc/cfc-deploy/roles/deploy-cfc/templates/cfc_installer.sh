#!/bin/bash

# m_ip=$1
# w_ip=$2
# cfc_dir=$3
m_ip=`getent hosts auto_master | awk '{ print $1 }'`
w_ip=`getent hosts auto_worker | awk '{ print $1 }'`
cfc_dir='/home/ubuntu/cfc'
m_hostname="auto-master"
w_hostname="auto-worker"

# echo "In cfc_installer.sh, m_ip=$m_ip, w_ip=$w_ip, cfc working dir=$cfc_dir"

# echo "\n\n***************************"
# echo " Install pip, docker-py"
# echo "****************************\n"

# set -x

# echo "Y" | apt install python-setuptools || yum install python-setuptools
# easy_install pip
# pip install docker-py

mount --make-rshared /

# TODO: To ensure that this setting is available after reboot, 
# add this mount command to the pre-start script section in the /etc/init/docker.conf file

# set +x

# echo "\n\n***************************"
# echo " Prepare for CfC installation"
# echo "***************************\n"

# set -x

#Appending master and worker nodes IP and hostname to master /etc/hosts file
# sudo -- sh -c -e "echo '$m_ip $m_hostname' >> /etc/hosts"
# sudo -- sh -c -e "echo '$w_ip $w_hostname' >> /etc/hosts"

#Enabling write permission for /etc/hosts
# ssh -i power-cfc.pem ubuntu@$w_ip "sudo chmod 777 ~/etc/hosts"

#Appending master and worker nodes IP and hostname to worker /etc/hosts file
# ssh -i power-cfc.pem ubuntu@$w_ip "echo "$m_ip $m_hostname" >> /etc/hosts"
# ssh -i power-cfc.pem ubuntu@$w_ip "echo "$w_ip $w_hostname" >> /etc/hosts"

#Changing the file permission back to the original one(644)
# ssh -i power-cfc.pem ubuntu@$w_ip "sudo chmod 644 ~/etc/hosts"

#ssh -i power-cfc.pem ubuntu@$w_ip "echo "$m_ip $m_hostname" >> /etc/hosts"
#sed -i $m_ip $m_hostname /etc/hosts
#sed -i $w_ip $w_hostname /etc/hosts

#To ensure that docker engine has started in master.
# sudo systemctl start docker

# Todo: ensure that docker engine has started in worker nodes.
# ssh -i power-cfc.pem ubuntu@$w_ip "sudo systemctl start docker"

#Todo: Need to add code to ssh to all the worker, proxy nodes and modify the /etc/hosts file



# ------------------------------------------------------------------------------
# 1. Download the IBM Spectrum Conductor for Containers installer image.
# ------------------------------------------------------------------------------

# docker pull ibmcom/cfc-installer-ppc64le:0.1.0

# ------------------------------------------------------------------------------
# 2. Extract the configuration files. 
# Perform this step inside a designated working directory.
# ------------------------------------------------------------------------------

mkdir $cfc_dir && cd $cfc_dir

docker run --rm --entrypoint=cp -v "$(pwd)":/data ibmcom/cfc-installer-ppc64le:0.1.0 -r cluster /data

# echo "Update the master and worker nodes in the $cfc_dir/cluster/hosts file"
printf "[master]\n$m_ip\n\n[worker]\n$w_ip\n" 2>&1 | tee cluster/hosts

# echo "Copy the ssh key to $cfc_dir/cluster/ssh_key "
# echo "The ssh_key was earlier created by setup_passwordless_ssh"

cp /home/ubuntu/.ssh/ssh_key /home/ubuntu/cfc/cluster/
# cp ~/.ssh/ssh_key /home/ubuntu/cfc/cluster/
chmod 400 /home/ubuntu/cfc/cluster/ssh_key







