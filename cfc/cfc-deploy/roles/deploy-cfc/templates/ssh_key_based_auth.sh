#!/bin/bash

#-------------------------------------------------------------------------------
# Shell script to automate passwordless ssh access between two nodes.
# Author: Sri Sudha
# Initial commit: Nov 25, 2016
# Comments: Hardcoded values
# Initial draft, will test and modify the script.
#-------------------------------------------------------------------------------

m_ip=169.44.37.187
w_ip=169.44.37.188
root_pw=passw0rd
ssh_opts=''

echo "[1] Enable root login (ssh root@ip) for the VMs ----------------------"

# todo: Need to copy the permission key file(eg:power-cfc.pem) using which all nodes are authenticated to the boot node(from where this script is called)
# Change permissionto 400 of the key
echo "Setting the root password for the master node: $m_ip ..."
# Have to use the key
ssh -i power-cfc.pem -t $ssh_opts ubuntu@$m_ip "printf \"$root_pw\n$root_pw\n$root_pw\n\" | sudo -S passwd root"

echo "Setting the root password for the worker node: $w_ip ..."

ssh -i power-cfc.pem -t $ssh_opts ubuntu@$w_ip "printf \"$root_pw\n$root_pw\n$root_pw\n\" | sudo -S passwd root"

echo "Done setting the root passwords."

echo "Updating sshd_config for master node: $m_ip ..."

set -x
echo $root_pw | sudo -S sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
echo $root_pw | sudo -S sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#-------------------------------------------------------------------------------
# Important restart sshd service.
#-------------------------------------------------------------------------------
echo $root_pw | sudo -S service sshd restart


echo "Updating sshd_config for the worker node: $w_ip"

ssh -i power-cfc.pem -t $ssh_opts ubuntu@$w_ip "echo $root_pw | sudo -S sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config"
ssh -i power-cfc.pem -t $ssh_opts ubuntu@$w_ip "echo $root_pw | sudo -S service sshd restart"

set +x
echo "[2] Enabling password-less ssh: Generating public-private key pair"

set -x


keys_dir=".ssh"
mkdir -p ~/$keys_dir
ssh-keygen -t rsa -f ~/$keys_dir/ssh_key -P ''


# As it is been ran as root user, sudo su - is used and all variables are to be set again in root user
# the variables should be set for all nodes while sshing to tha node
sudo su -
scp /home/ubuntu/ssh_key.pub .
#scp ~/$keys_dir/ssh_key.pub .
service ssh restart

keys_dir=".ssh"
scp -i power-cfc.pem ~/$keys_dir/ssh_key.pub ubuntu@$w_ip:/home/ubuntu/$keys_dir
ssh -i ssh_key root@$m_ip
sudo su -
scp ~/$keys_dir/ssh_key.pub .

#Todo:  Copy ssh_key and ssh_key.pub to root@worker node
service ssh restart



ls ~/$keys_dir/ssh_key

# Make sure to change the permission to 400
chmod 400 ~/$keys_dir/ssh_key

# Copy the ssh key to the master node. TODO: will it preserve 400 access? Check.
ssh -i ssh_key scp $ssh_opts ~/$keys_dir/ssh_key root@$m_ip:/home/ubuntu/

ssh -i ssh_key scp $ssh_opts ~/$keys_dir/ssh_key root@$w_ip:/home/ubuntu/


echo "End of setup_passwordless_ssh"
echo "Now, from master node (as a root) you can run ssh -i ~/.ssh/ssh_key root@ip for passwordless access."

