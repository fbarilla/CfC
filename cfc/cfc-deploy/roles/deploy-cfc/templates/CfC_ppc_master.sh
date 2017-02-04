#!/bin/bash
#-------------------------------------------------------------------------------
# The Master script to automate Spectrum Conductor for Containers installation
# Author: Franck Barillaud
# Initial commit: Feb 3, 2017
# TODO: Needs more testing, documentation, to be revised further.
#-------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# get the IP addresses of the nodes
# ------------------------------------------------------------------------------
m_ip=`getent hosts auto_master | awk '{ print $1 }'`
w_ip=`getent hosts auto_worker | awk '{ print $1 }'`
p_ip=`getent hosts auto_proxy | awk '{ print $1 }'`

echo "UI URL is https://$m_ip:8443 , default username/password is admin/admin" > /tmp/msg

# ------------------------------------------------------------------------------
# Build final msg
# ------------------------------------------------------------------------------
echo "UI URL is https://$m_ip:8443 , default username/password is admin/admin" > /tmp/msg

# ------------------------------------------------------------------------------
# Download the IBM Spectrum Conductor for Containers installer image.
# ------------------------------------------------------------------------------
docker pull ibmcom/cfc-installer-ppc64le:0.3.0

# ------------------------------------------------------------------------------
# Extract the configuration files
# ------------------------------------------------------------------------------
cd /opt
docker run -e LICENSE=accept --rm -v "$(pwd)":/data ibmcom/cfc-installer-ppc64le:0.3.0 cp -r cluster /data

# ------------------------------------------------------------------------------
# Create and Update the ssh_key file
# ------------------------------------------------------------------------------
# -o StrictHostKeyChecking=no root@$m_ip:/root/.ssh/authorized_keys

ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
/usr/bin/sshpass -p 'Oct4v14n9a!' scp /root/.ssh/id_rsa.pub root@$m_ip:/root/.ssh/authorized_keys
/usr/bin/sshpass -p 'Oct4v14n9a!' scp /root/.ssh/id_rsa.pub root@$w_ip:/root/.ssh/authorized_keys
/usr/bin/sshpass -p 'Oct4v14n9a!' scp /root/.ssh/id_rsa.pub root@$p_ip:/root/.ssh/authorized_keys
cat /root/.ssh/id_rsa > /opt/cluster/ssh_key
chmod 400 /opt/cluster/ssh_key



# ------------------------------------------------------------------------------
# Update the host file
# ------------------------------------------------------------------------------
cat <<EOF > /opt/cluster/hosts
[master]
$m_ip

[worker]
$w_ip

[proxy]
$p_ip
EOF

# ------------------------------------------------------------------------------
# Install CfC
# ------------------------------------------------------------------------------
cd /opt
docker run -e LICENSE=accept --rm -t -v "$(pwd)/cluster":/installer/cluster ibmcom/cfc-installer-ppc64le:0.3.0 install

# -------------------------------------------------------------------------
# END of the CfC installer script
# -------------------------------------------------------------------------
                                                                                                                            
