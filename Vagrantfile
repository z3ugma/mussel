# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 config.vm.box = "ubuntu/bionic64" 

 dirname = File.basename(Dir.getwd)
 config.vm.hostname = dirname

config.vm.network "private_network", type: "dhcp"
config.vm.network "forwarded_port", guest: 5353, host: 5354
config.vm.network "forwarded_port", guest: 9080, host: 9081

#config.bindfs.bind_folder "/Users/fred/vagrant-vms/gtm2", "/fetdb"
config.vm.synced_folder '.', '/mussel',
  nfs: true

$script = <<SCRIPT
echo "Provisioning GT.M"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python python-pip git curl fis-gtm-6.3-003a inotify-tools
cd /mussel
mkdir -p r g j o m


SCRIPT

config.vm.provision "shell", inline: $script

end
