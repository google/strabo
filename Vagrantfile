VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  ## Choose your base box
  config.vm.box = "ubuntu/vivid64"

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end

  ## For masterless, mount your salt file root
  config.vm.synced_folder "infrastructure/srv/salt/", "/srv/salt/"

  ## Use all the defaults:
  config.vm.provision :salt do |salt|
    salt.bootstrap_options = "-F -c /tmp/ -P"
    salt.minion_config = "infrastructure/vagrant-minion"
    salt.run_highstate = true

    salt.install_type = "git"
    salt.install_args = "develop"
  end

  config.vm.network "forwarded_port", guest: 4001, host: 4001
end
