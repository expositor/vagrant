VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "chef/ubuntu-13.10"
  #config.vm.box = "berendt/ubuntu-14.04-amd64"

  # Increase The Memory
  config.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  # Forward Some Ports
  config.vm.network "forwarded_port", guest: 22, host: 2200
  config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.network "forwarded_port", guest: 3306, host: 33060
  config.vm.network "forwarded_port", guest: 5432, host: 54320

  # Run The Base Provisioning Script
  config.vm.provision "shell", path: "provision.sh"

  # Add All Of Your Sites As Synced Folders
  config.vm.synced_folder "C:/Users/Taylor/Documents/Code/Laravel/plain", "/home/vagrant/Sites/plain"

  # Configure All Of Your Sites
  sites = {
    "plain.app" => "/home/vagrant/Sites/plain/public"
  }

  # Install All The Nginx Sites
  sites.each do |name, path|
    config.vm.provision "shell" do |s|
      s.path = "serve.sh"
      s.args = [name, path]
    end
  end
end
