VAGRANTFILE_API_VERSION = "2"

require 'yaml'
require './scripts/forge.rb'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  Forge.provision config, YAML::load(File.read('./Vagrant.yaml'))
end
