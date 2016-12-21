#!/bin/bash

#-------------------------------------------------------------------------------
# Shell script to automate passwordless ssh access between two nodes.
# Authors: Sri Sudha, Gene
# Initial commit: Nov 29, 2016
# Comments: Hardcoded values
# Initial draft, will test and modify the script.
#-------------------------------------------------------------------------------

m_ip=$1
w_ip=$2
root_pw=XdsOeD0MgwCsxFjjGzJhteOdt8ws6j1OD0EqkJ1W
#m_ip=169.44.37.187
#w_ip=169.44.37.188
#root_pw=passw0rd
ssh_opts=''

# echo "[1] Enable root login (ssh root@ip) for the VMs ----------------------"

# todo: Need to copy the permission key file(eg:power-cfc.pem) using which all nodes are authenticated to the boot node(from where this script is called)
# Change key permission to 400
# echo "Setting the root password for the master node: $m_ip ..."
# Have to use the key(power-cfc.pem)
# ssh -i power-cfc.pem -t $ssh_opts ubuntu@$m_ip "printf \"$root_pw\n$root_pw\n$root_pw\n\" | sudo -S passwd root"

# echo "Setting the root password for the worker node: $w_ip ..."

# ssh -i power-cfc.pem -t $ssh_opts ubuntu@$w_ip "printf \"$root_pw\n$root_pw\n$root_pw\n\" | sudo -S passwd root"

# echo "Done setting the root passwords."

# echo "Updating sshd_config for master node: $m_ip ..."

# set -x
# echo $root_pw | sudo -S sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
# echo $root_pw | sudo -S sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#-------------------------------------------------------------------------------
# Important restart sshd service.
#-------------------------------------------------------------------------------
# echo $root_pw | sudo -S service sshd restart

cd /home/ubuntu

# echo "Updating sshd_config for the worker node: $w_ip"

# ssh -i power-cfc.pem -t $ssh_opts ubuntu@$w_ip "echo $root_pw | sudo -S sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config"
# ssh -i power-cfc.pem -t $ssh_opts ubuntu@$w_ip "echo $root_pw | sudo -S service sshd restart"

# set +x

# echo "[2] Enabling password-less ssh: Generating public-private key pair"
# set -x
keys_dir=".ssh"
mkdir -p ~/$keys_dir
ssh-keygen -t rsa -f ~/$keys_dir/ssh_key -P ''

#copy the key to ubuntu@w_ip
#cat ~/.ssh/ssh_key.pub | ssh -i /home/ubuntu/power-cfc.pem ubuntu@$w_ip "cat >> ~/.ssh/authorized_keys"

#chmod 400 ~/$keys_dir/ssh_key
#chmod 400 ~/$keys_dir/ssh_key.pub

#Copying the generated keypair to master .ssh folder(ubuntu user)
# scp -i power-cfc.pem ~/$keys_dir/ssh_key ubuntu@$m_ip:~/$keys_dir
# scp -i power-cfc.pem ~/$keys_dir/ssh_key.pub ubuntu@$m_ip:~/$keys_dir
scp ~/$keys_dir/ssh_key ubuntu@$m_ip:~/$keys_dir
scp ~/$keys_dir/ssh_key.pub ubuntu@$m_ip:~/$keys_dir

#Copying the generated public key to worker(ubuntu user)
scp ~/$keys_dir/ssh_key ubuntu@$w_ip:~/$keys_dir
scp ~/$keys_dir/ssh_key.pub ubuntu@$w_ip:~

#Copy the script(worker_copy.sh) to all worker nodes ubuntu user
# scp ~/worker-copy.sh ubuntu@$w_ip:~
scp ./worker-copy.sh ubuntu@$w_ip:~

#Calling worker_copy.sh remotely from master by using ssh to append the generated key to authorized_keys as root
# ssh ubuntu@$w_ip "sh ~/worker-copy.sh"
scp /root/.ssh/ssh_key.pub ubuntu@$w_ip:~/.ssh
ssh ubuntu@$w_ip  'cat ~/.ssh/ssh_key.pub >> ~/.ssh/authorized_keys'

#Updating the permissions of the public and private key that is on the master node
# ssh -i power-cfc.pem ubuntu@$m_ip "chmod 400 ~/$keys_dir/ssh_key; chmod 400 ~/$keys_dir/ssh_key.pub"
ssh ubuntu@$m_ip "chmod 400 ~/$keys_dir/ssh_key; chmod 400 ~/$keys_dir/ssh_key.pub"

# FRB
scp ~/$keys_dir/ssh_key.pub root@$m_ip:~/$keys_dir
scp ~/$keys_dir/ssh_key.pub root@$w_ip:~/$keys_dir
ssh root@$w_ip  'cat ~/.ssh/ssh_key.pub >> ~/.ssh/authorized_keys'
ssh root@$m_ip  'cat ~/.ssh/ssh_key.pub >> ~/.ssh/authorized_keys'

