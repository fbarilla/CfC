# IBM Spectrum Conductor for Containers (CfC) on Power 8

IBM Spectrum Conductor for Containers is an on premises platform for managing containerized applications that is based on the container orchestrator Kubernetes. Through the implementation of a  robust resource manager, Apache Mesos, IBM Spectrum Conductor for Containers is able to manage resources for hybrid environments that contain both containerized and non-containerized applications as well as mixed hardware architecture.
IBM Spectrum Conductor for Containers also includes a graphical user interface which provides a centralized location from where you can deploy, manage, monitor and scale your applications.

To intall CfC:

1) Load a Power 8 or OpenPower system with Ubuntu 16.10

    Remove apparmor

	systemctl stop apparmor.service
	update-rc.d -f apparmor remove
	apt-get remove apparmor
	apt-get purge apparmor
	
    Setup 'root' password 
    Enable ssh login for 'root'
    	ssh-keygen
	
	vi /etc/ssh/sshd_config
		# PermitRootLogin prohibit-password
		PermitRootLogin yes
		# PermitEmptyPasswords no
		#PasswordAuthentication yes
	
	service ssh restart
		    
    Make sure that you have passwordless connection to 'localhost'. The 'ssh root@localhost' should 
    return without asking for password. If not:

	ssh-copy-id root@localhost

    Make sure that SMT is turn off

	ppc64_cpu --smt=off

    
2) Install pre-requisites

	apt-get update
	sed -i 's/^# deb-src/deb-src/g' /etc/apt/sources.list
	apt-get -y build-dep vagrant ruby-libvirt
	apt-get install -y qemu-kvm libvirt-bin  ebtables dnsmasq 
	apt-get install -y libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev git  git-review	
	apt-get install -y vagrant-libvirt
	apt-get install -y software-properties-common
	apt-add-repository -y ppa:ansible/ansible
	apt-get install -y ansible

	Make sure that libvirt can be run by the 'root' user

	vi  /etc/libvirt/qemu.conf
		user = "root"
		group = "root"

	service libvirtd restart

3) Install Vagrant

	apt-get install -y vagrant
	apt-get install -y build-essential libssl-dev libffi-dev python-dev

4) Install Vagrant plugins

	vagrant plugin install vagrant-mutate
	vagrant plugin install vagrant-libvirt
	vagrant plugin install vagrant-host-shell

5) Clone the CfC repository

	cd /root
	git clone https://github.com/fbarilla/CfC.git

6) Deploy CfC

	vagrant up

Note: the CfC dashboard URL and credentials are provided as the last message of the installation process.  
	
	TASK [deploy-cfc : Congratulations! Conductor for Container (CfC) has been successfully installed.] ***
	ok: [cfc1] => {
    	"msg": "To access CfC point a browser to https://192.168.122.xxx . Use 'admin/admin' as credentials"
	}


Note: by default, the installation process is started from '/root/CfC'. If the github project has been cloned in a different directory, update the 'install_dir' variable in './cfc/cfc-deploy/group_vars/all.yml'.

Note: by default the VM network interface name is 'enp0s5'. If your VM has a different interface naming convention, update the name in 'root/CfC/config.rb' and './cfc/cfc-deploy/group_vars/all.yml'
