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
    config.vm.box_version = "1801.02" # 7.4.1708
    package="_yum"
  else
    puts "you must set the OS variable to a valid value before continuing"
    exit
  end

  @machines = [
    # comment in if testing replication:
    # { name: 'catalyst-solr-slave',
    #   ip: '10.11.12.103',
    #   memory: 2048,
    #   cpus: 1, name: 'catsolrmaster-dev',
    #   ansible_group: 'solr',
    # },
    { name:'catalyst-dev',
      ip: '10.11.12.101',
      memory: 2048,
      cpus: 1,
    },
    { name: 'catalyst-solr-dev',
      ip: '10.11.12.102',
      memory: 2048,
      cpus: 1,
      ansible_group: 'solr'
    }
  ]

  # limit ansible provisioning to machines
  @ansible_limit = @machines.map{ |machine| "#{machine[:name]}.#{domain}" }.join(",") || "all"

  @machines.each_with_index do |machine, index|
    config.vm.define machine[:name] do |host|
      host.vm.network 'private_network', ip: machine[:ip]
      host.vm.hostname = "#{machine[:name]}.#{domain}"
      # presumes installation of https://github.com/cogitatio/vagrant-hostsupdater on host
      host.hostsupdater.aliases = [machine[:name]]
      # avoiding "Authentication failure" issue
      host.ssh.insert_key = false
      host.vm.synced_folder ".", "/vagrant", disabled: true

      host.vm.provider "virtualbox" do |vb|
        vb.name = "#{machine[:name]}.#{domain}"
        vb.memory = machine[:memory]
        vb.cpus = machine[:cpus]
        vb.linked_clone = true
      end

      # Note: have tried to move outside the machine.each loop but still triggers
      #       on first machine creation
      if index == (@machines.size-1)
        host.vm.provision "ansible" do |ansible|
          # NOTE: not reading from ansible.cfg
          ansible.inventory_path = "inventory/vagrant"
          ansible.galaxy_role_file = "requirements.yml"
          ansible.verbose = "v"
          # NOTE: can't just leave this out and expect it to default to "all"
          #ansible.limit = machine[:name]
          ansible.limit = @ansible_limit
          ansible.playbook = "setup.yml"
        end
      end
    end

  end

end
