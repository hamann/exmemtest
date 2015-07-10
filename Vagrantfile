# -*- mode: ruby -*-
# vi: set ft=ruby :

# berks vendor vagrant/cookbooks

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "holms-jessie-netboot"
  config.vm.box_url = 'https://github.com/holms/vagrant-jessie-box/releases/download/Jessie-v0.1/Debian-jessie-amd64-netboot.box'
  config.vm.hostname = "exmemtest"

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.network :forwarded_port, guest: 4000, host: 4000

  config.ssh.forward_agent = true

  config.vm.provision 'shell', path: 'script/vagrant_provision.sh', privileged: false

  config.vm.provider :virtualbox do |vb|
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000 ]
  end
end
