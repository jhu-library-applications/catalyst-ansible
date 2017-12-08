# -*- mode: ruby -*-
# vi: set ft=ruby :

domain          = "test"
setup_complete  = false

# NOTE: currently using the same OS for all boxen
OS="centos" # "debian" || "centos"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  package=""
  if OS=="debian"
    config.vm.box = "debian/jessie64"
    package="_apt"
  elsif OS=="centos"
    config.vm.box = "centos/7"
    config.vm.box_version = "1707.01" # 7.3.1611
    package="_yum"
  else
    puts "you must set the OS variable to a valid value before continuing"
    exit
  end

  {
    # comment in if testing replication:
    # 'catalyst-solr-slave' => '10.11.12.103',
    'catalyst'            => '10.11.12.101',
    'catalyst-solr'       => '10.11.12.102'
  }.each do |short_name, ip|
    config.vm.define short_name do |host|
      host.vm.network 'private_network', ip: ip
      host.vm.hostname = "#{short_name}.#{domain}"
      # presumes installation of https://github.com/cogitatio/vagrant-hostsupdater on host
      host.hostsupdater.aliases = ["#{short_name}"]
      # avoiding "Authentication failure" issue
      host.ssh.insert_key = false
      host.vm.synced_folder ".", "/vagrant", disabled: true

      host.vm.provider "virtualbox" do |vb|
        vb.name = "#{short_name}.#{domain}"
        vb.memory = 2048
        vb.cpus = 1
        vb.linked_clone = true

        if short_name == "catalyst-solr" || short_name == "catalyst-solr-slave"
          # 2 would be better for testing performance, but then the full
          # environment would exceed available resources on most dev machines
          vb.cpus = 1
          vb.memory = 5120
        end
      end

      if short_name == "catalyst-solr" # last in the list
        setup_complete = true
      end

      if setup_complete
        # workaround for https://github.com/mitchellh/vagrant/issues/8142
        host.vm.provision "shell",
          inline: "sudo service network restart"

        host.vm.provision "ansible" do |ansible|
          ansible.galaxy_role_file = "requirements.yml"
          ansible.inventory_path = "inventory/vagrant"
          # NOTE: comment in if replicating:
          # ansible.inventory_path = "inventory/dev_replicating"
          ansible.playbook = "setup.yml"
          ansible.limit = "all"
          ansible.verbose = "v"
        end
      end
    end
  end
end
