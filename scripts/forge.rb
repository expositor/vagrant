class Forge
	def Forge.provision(config, settings)
		# Configure The Box
		config.vm.box = "chef/ubuntu-13.10"

		config.vm.provider "virtualbox" do |vb|
		    vb.customize ["modifyvm", :id, "--memory", "2048"]
			vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
			vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		end

		# Configure Port Forwarding
		config.vm.network "forwarded_port", guest: 22, host: 2200
		config.vm.network "forwarded_port", guest: 80, host: 8000
		config.vm.network "forwarded_port", guest: 3306, host: 33060
		config.vm.network "forwarded_port", guest: 5432, host: 54320

		# Run The Base Provisioning Script
		config.vm.provision "shell" do |s|
		  s.path = "./scripts/provision.sh"
		  s.args = [File.read(settings["key"])]
		end

		# Register All Of The Shared Folders
		settings["folders"].each do |folder|
		  config.vm.synced_folder folder["map"], folder["to"]
		end

		# Install All The Nginx Sites
		settings["sites"].each do |site|
		  config.vm.provision "shell" do |s|
		    s.path = "./scripts/serve.sh"
		    s.args = [site["map"], site["to"]]
		  end
		end
	end
end