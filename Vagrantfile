# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'
VAGRANT_BOX = 'bento/ubuntu-18.04'
vm_specs = [
  { name: 'lb-0', ip: '10.240.0.40', playbook: 'lb.yml', sync_dir: 'lb', },
  { name: 'controller-0', ip: '10.240.0.10', playbook: 'controller.yml', sync_dir: 'controller', },
  { name: 'controller-1', ip: '10.240.0.11', playbook: 'controller.yml', sync_dir: 'controller', },
  { name: 'controller-2', ip: '10.240.0.12', playbook: 'controller.yml', sync_dir: 'controller', },
  { name: 'worker-0', ip: '10.240.0.20', playbook: 'worker.yml', sync_dir: 'worker', },
  { name: 'worker-1', ip: '10.240.0.21', playbook: 'worker.yml', sync_dir: 'worker', },
  { name: 'worker-2', ip: '10.240.0.22', playbook: 'worker.yml', sync_dir: 'worker', },
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  ##############################################################################
  # 共通
  ##############################################################################
  config.vm.box = VAGRANT_BOX
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder './ansible', '/home/vagrant/ansible',
    create: true, type: :rsync, owner: :vagrant, group: :vagrant,
    rsync__exclude: ['*.swp']
  config.vm.provider 'virtualbox' do |vb|
    vb.cpus = '1'
    vb.memory = 1024 * 1
    vb.customize [ 'modifyvm', :id, '--uartmode1', 'disconnected' ]
  end
  config.vm.provision :hosts, :sync_hosts => true

  ##############################################################################
  # 各VM
  ##############################################################################
  vm_specs.each do |spec|
    config.vm.define spec[:name] do |machine|
      machine.vm.hostname = spec[:name]
      machine.vm.network 'private_network', ip: spec[:ip]
      machine.vm.provider :virtualbox do |vb|
        vb.name = spec[:name]
      end
      machine.vm.synced_folder './' + spec[:sync_dir], '/home/vagrant/' + spec[:sync_dir],
        create: true, type: :rsync, owner: :vagrant, group: :vagrant,
        rsync__exclude: ['*.swp']
      machine.vm.provision 'ansible_local' do |ansible|
        ansible.provisioning_path = '/home/vagrant/'
        ansible.playbook          = '/home/vagrant/ansible/' + spec[:playbook]
        ansible.inventory_path    = '/home/vagrant/ansible/inventories/hosts'
        #ansible.install_mode      = 'pip'
        #ansible.version           = '2.9.7'
        ansible.version           = 'latest'
        ansible.verbose           = false
        ansible.install           = true
        ansible.limit             = spec[:name]
      end
    end
  end
end
