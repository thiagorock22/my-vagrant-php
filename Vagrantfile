# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "private_network", ip: "192.168.2.2"

  if Dir.exist?("./www")
    config.vm.synced_folder "./www", "/var/www/html"
  else
    config.vm.synced_folder Dir.pwd, "/var/www/html"
  end

  if Dir.exist?(Dir.pwd+"/public")
    config.vm.synced_folder Dir.pwd, "/usr/share/devlocal/"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "768"]
  end

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path    = "puppet/modules"
    puppet.manifest_file  = "init.pp"
  end

end
