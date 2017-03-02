VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'boxcutter/ol73'
  config.vm.provider 'virtualbox' do |v|
    v.memory = 1536
  end
  config.vm.network 'forwarded_port', guest: 1521, host: 1521
  config.vm.provision 'shell', path: 'setup.sh'
end
