VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  ## Choose your base box
  config.vm.box = "ubuntu/trusty64"

  ## For masterless, mount your salt file root
  config.vm.synced_folder "infrastructure/srv/salt/", "/srv/salt/"

  ## Use all the defaults:
  config.vm.provision :salt do |salt|
    salt.bootstrap_options = "-P"
    salt.minion_config = "infrastructure/vagrant-minion"
    salt.run_highstate = true
  end

  config.vm.network "forwarded_port", guest: 4001, host: 4001
end
