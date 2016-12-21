#!/bin/bash

#-------------------------------------------------------------------------------
# Shell script to automate docker installation on Ubuntu 16.04 
# Author: Ninad Sathaye
# Initial commit: Nov 15, 2016
# See Also: Cfc_ppc_master.sh
#-------------------------------------------------------------------------------

echo "[3] Install docker for Ubuntu 16.04 (ppc)"

echo deb http://ftp.unicamp.br/pub/ppc64el/ubuntu/16_04/docker-1.12.0-ppc64el/ xenial main > /etc/apt/sources.list.d/xenial-docker.list 

apt-get update

# --allow-unauthenticated option ensures it will auto fill answers as yes and install
# (not using --force-yes, it is deprecated)
apt-get --yes --allow-unauthenticated install docker-engine

echo `which docker`

echo "Done with docker installation for Ubuntu 16.04 (ppc)"
