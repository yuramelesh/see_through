Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty32"

  config.vm.provision "shell", path: "/home/ubuntu/box/deploy/temp/ops/provision.sh"

  config.vm.synced_folder "deploy/temp", ENV['SEE_THROUGH_HOME']

end