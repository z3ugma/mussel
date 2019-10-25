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
config.vm.synced_folder '.', '/fetdb', type: 'nfs'

$script = <<SCRIPT
echo "Provisioning GT.M"
sudo apt-get update
sudo apt-get -y install python python-pip git curl
cd /fetdb
chmod +x gtminstall
sudo ./gtminstall

#source /usr/lib/fis-gtm/V6.3-005_x86_64/gtmprofile
#env | grep ^gtm
#tree .fis-gtm/

SCRIPT

config.vm.provision "shell", inline: $script

end
