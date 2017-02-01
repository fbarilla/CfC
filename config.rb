# CfC Details: Instances
$cfc_dir = "/root/CfC/"
$cfc_version = 	"ubuntu/xenial64"
$cfc_memory = 2048
$cfc_vcpus = 2
$cfc_count = 2
$git_commit        = "6a7308d"
$subnet            = "192.168.122"
$public_iface = "eth1"
$forwarded_ports   = {}
$domain_name = "cfc.ibm.com"

# Ansible Declarations:
#$number_etcd       = "cfc[1:2]"
#$number_master     = "cfc[1:2]"
#$number_worker     = "cfc[1:3]"
$cfc_masters      = "cfc1"
$cfc_workers = "cfc2"
# FRB $cfc_control      = "cfc1"

# Virtualbox leave / Openstack change to OS default username:
$ssh_user = "ubuntu"
$ssh_keypath       = "~/.ssh/id_rsa"
$ssh_port          = 22

# Ansible Details:
$ansible_limit     = "all"
$ansible_playbook  = "cfc/cfc-deploy/cfc-deploy.yml"
$ansible_inventory = ".vagrant/provisioners/ansible/inventory_override"

# Openstack Authentication Information:
$os_auth_url       = "http://your.openstack.url:5000/v2.0"
$os_username       = "user"
$os_password       = "password"
$os_tenant         = "tenant"

# Openstack Instance Information:
$os_flavor         = "m1.small"
$os_image = "ubuntu-trusty-16.04"
$os_floatnet       = "public"
$os_fixednet       = ['vagrant-net']
$os_keypair        = "your_ssh_keypair"
$os_secgroups      = ["default"]

# Proxy Configuration (only use if deploying behind a proxy):
$proxy_enable      = false 
$proxy_http        = "http://proxy:8080"
$proxy_https       = "https://proxy:8080"
$proxy_no          = "localhost,127.0.0.1"
