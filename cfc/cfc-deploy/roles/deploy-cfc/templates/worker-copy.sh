#!/bin/bash

#Dynamically find the current directory of this file (and the key file)
CURR_DIR=$(cd $(dirname $BASH_SOURCE) && pwd)

#Call the remaining commands as root
sudo su root <<EOF
echo "Create .ssh directory"
mkdir -p ~/.ssh

echo "Add public key to list of authorized keys"
cat $CURR_DIR/ssh_key.pub >> ~/.ssh/authorized_keys

echo "Remove temporary key files from worker"
rm -f $CURR_DIR/ssh_key.pub
rm -f $CURR_DIR/ubuntu/ssh_key

echo "Complete!"
EOF
