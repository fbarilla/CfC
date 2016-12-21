# -*- mode: ruby -*-
# vi: set ft=ruby :
# NOTE: Variable overrides are in ./config.rb
require "yaml"
require "fileutils"

# Use a variable file for overrides:
CONFIG = File.expand_path("config.rb")
if File.exist?(CONFIG)
  require CONFIG
end

# Force best practices for this environment:
# if $cfc_memory < 512
#   puts "WARNING: Your machine should have at least 512 MB of memory"
# end

# Install any Required Plugins
missing_plugins_installed = false
required_plugins = %w(vagrant-env vagrant-git vagrant-openstack-provider vagrant-proxyconf)

required_plugins.each do |plugin|
  if !Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    missing_plugins_installed = true
  end
end

# If any plugins were missing and have been installed, re-run vagrant
if missing_plugins_installed
  exec "vagrant #{ARGV.join(" ")}"
end

# Use plugins after install / re-run
require "vagrant-openstack-provider"

# Vagrantfile API/sytax version. Don’t touch unless you know what you’re doing!
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Guest Definitions:
  # ------------------------
  #
  # START: VM Definition(s)
  (1..$cfc_count).each do |kb|
  ip = "#{$subnet}.#{kb}"

    config.vm.define vm_name = "cfc#{kb}" do |cfc|

      cfc.vm.box = "xenialppc64"
      cfc.vm.box_url = "https://atlas.hashicorp.com/fbarilla/boxes/xenialppc64el/versions/1.0.0/providers/virtualbox.box"
      # cfc.vm.box_url = "http://hab-kub.kub.ibm.com/xenialppc64.box"
      cfc.vm.hostname = "cfc-#{kb}.#{$domain_name}"
       config.ssh.username = 'root'
       config.ssh.password = 'Oct4v14n9a!'
       # config.ssh.password = 'XdsOeD0MgwCsxFjjGzJhteOdt8ws6j1OD0EqkJ1W'
       config.ssh.insert_key = 'true'

      if $proxy_enable
        config.proxy.http     = $proxy_http
        config.proxy.https    = $proxy_https
        config.proxy.no_proxy = $proxy_no
      end

      if $expose_docker_tcp
        cfc.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
      end
      $forwarded_ports.each do |guest, host|
        cfc.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
      end
      # Virtualbox Provider (Default --provider=virtualbox):
      cfc.vm.provider "virtualbox" do |vb|
        vb.name = "cfc#{kb}"
        vb.customize ["modifyvm", :id, "--memory", $cfc_memory]
        vb.customize ["modifyvm", :id, "--cpus", $cfc_vcpus]
      end
      # Libvirt Provider (Optional --provider=libvirt)
      cfc.vm.provider "libvirt" do |lv|
        lv.driver = "kvm"
        lv.memory = $cfc_memory
        lv.cpus = $cfc_vcpus
	# FRB
        lv.cpu_mode = "host-passthrough"
	lv.video_type = "vga"
	# lv.host = "hab-kub.kub.ibm.com"
	lv.host = "localhost"
       	lv.connect_via_ssh = "true"
       	# lv.uri = "qemu+ssh://root@hab-kub.kub.ibm.com/system"
       	lv.uri = "qemu+ssh://root@localhost/system"
        lv.management_network_name = "default"
        lv.management_network_address = "192.168.122.0/24"
	# end FRB

      end
      # Openstack Provider (Optional --provider=openstack):
      cfc.vm.provider "openstack" do |os|
        # Openstack Authentication Information:
        os.openstack_auth_url  = $os_auth_url
        os.username            = $os_username
        os.password            = $os_password
        os.tenant_name         = $os_tenant
        # Openstack Instance Information:
        os.server_name         = "cfc#{kb}"
        os.flavor              = $os_flavor
        os.image               = $os_image
        os.floating_ip_pool    = $os_floatnet
        os.networks            = $os_fixednet
        os.keypair_name        = $os_keypair
        os.security_groups     = $os_secgroups
      end
    # We only want Ansible to run after after all servers are deployed:
    if kb == $cfc_count
      cfc.vm.provision :ansible do |ansible|
        ansible.sudo              = true
        ansible.limit             = $ansible_limit
        ansible.playbook          = $ansible_playbook
        ansible.host_key_checking = false
        ansible.groups            = {
          "cfc-masters" => [$cfc_masters],
          "cfc-workers" => [$cfc_workers],
          "cfc-cluster:children" => ["cfc-masters", "cfc-workers"],
        }
        ansible.extra_vars        = {
          "public_iface" => $public_iface,
          "proxy_enable" => $proxy_enable,
          "proxy_http" => $proxy_http,
          "proxy_https" => $proxy_https,
          "proxy_no" => $proxy_no
        }
        end
      end
    end

  end
end
