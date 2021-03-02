# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure('2') do |config|

  # this same file is used for ansible inventory
  inventory_path = 'inventory/vagrant'
  inventory = YAML.load_file(inventory_path)
  ansible_hosts = inventory['all']['hosts']

  # delete status = absent
  ansible_hosts.map do |name, vars|
    # skip hosts marked as absent
    ansible_hosts.delete(name)  if (  vars['state'] == 'absent' )
  end

  ansible_limit = ansible_hosts.map{ | host_name, host | "#{host_name}" }.join(',') || 'all'

  ansible_hosts.each_with_index do | (host_name, host_vars), index|
    config.vm.define host_name do |host|
 
      # setup box image for each host
      host.vm.box = host_vars['vagrant_box_image']
      host.vm.box_version = host_vars['vagrant_box_version']

      # configure the virtual machine
      host.vm.provider 'virtualbox' do |vb|
        vb.name = host_name
        vb.memory = host_vars['memory']
        vb.cpus = host_vars['cpus']
        vb.linked_clone = true
      end

      # configure network
      host.vm.hostname = host_name
      host.vm.network 'private_network', ip: host_vars['ansible_ip']
      host.hostsupdater.aliases = host_vars['aliases']
      host.ssh.insert_key = false
      host.vm.synced_folder '.', '/vagrant', disabled: true

      # only provision the last host, ansible will manage all hosts
      if index == (ansible_hosts.size-1)
        host.vm.provision 'ansible' do |ansible|
          ansible.compatibility_mode = '2.0'
          ansible.inventory_path = inventory_path
          # ensure roles installed
          ansible.galaxy_role_file = 'requirements.yml'
          ansible.verbose = 'v'
          ansible.limit = ansible_limit
          ansible.playbook = 'setup.yml'
        end
      end
    end

  end
end
