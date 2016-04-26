Vagrant.configure(2) do |config|

  config.env.enable

  config.vm.box = "ubuntu/trusty32"

  config.vm.provision "shell", path: "#{ENV['SEE_THROUGH_HOME']}/ops/provision.sh"
end