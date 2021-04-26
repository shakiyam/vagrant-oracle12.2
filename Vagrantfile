VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false
  config.vm.box = 'oraclelinux/7'
  config.vm.box_url = 'https://oracle.github.io/vagrant-projects/boxes/oraclelinux/7.json'
  config.vm.network 'forwarded_port', guest: 1521, host: 1521
  config.vm.provision 'shell', path: 'provision.sh'
end
