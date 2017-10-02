VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'http://yum.oracle.com/boxes/oraclelinux/ol74/ol74.box'
  config.vm.network 'forwarded_port', guest: 1521, host: 1521
  config.vm.provision 'shell', path: 'provision.sh'
end
