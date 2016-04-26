Vagrant.configure(2) do |config|

  config.env.enable

<<<<<<< HEAD
  config.vm.box = ENV['UBUNTU_BOX']

  SEE_THROUGH_HOME_PATH=ENV['SEE_THROUGH_HOME']
  SEE_THROUGH_TOKEN=ENV['SEE_THROUGH_TOKEN']
  SEE_THROUGH_EMAIL=ENV['SEE_THROUGH_EMAIL']
  SEE_THROUGH_EMAIL_PASS=ENV['SEE_THROUGH_EMAIL_PASS']
  DEBUG_EMAIL=ENV['DEBUG_EMAIL']

  config.vm.provision "shell", inline: <<-SHELL

  source ~/.profile && if [ -z ${SEE_THROUGH_HOME_PATH} ]; then
        echo "export SEE_THROUGH_HOME_PATH=#{SEE_THROUGH_HOME_PATH}" >> .profile
  fi

  source ~/.profile && if [ -z ${SEE_THROUGH_TOKEN} ]; then
        echo "export SEE_THROUGH_TOKEN=#{SEE_THROUGH_TOKEN}" >> .profile
  fi

  source ~/.profile && if [ -z ${SEE_THROUGH_EMAIL} ]; then
        echo "export SEE_THROUGH_EMAIL=#{SEE_THROUGH_EMAIL}" >> .profile
  fi

  source ~/.profile && if [ -z "$SEE_THROUGH_EMAIL_PASS" ]; then
        echo "export SEE_THROUGH_EMAIL_PASS=#{SEE_THROUGH_EMAIL_PASS}" >> .profile
  fi

  source ~/.profile && if [ -z "$DEBUG_EMAIL" ]; then
        echo "export DEBUG_EMAIL=#{DEBUG_EMAIL}" >> .profile
  fi

  bash #{SEE_THROUGH_HOME_PATH}ops/provision.sh

  bundle install --gemfile=#{SEE_THROUGH_HOME_PATH}Gemfile --no-cache

  SHELL

  config.vm.synced_folder "deploy/temp", SEE_THROUGH_HOME_PATH

end
=======
  config.vm.box = "ubuntu/trusty32"

  config.vm.provision "shell", path: "#{ENV['SEE_THROUGH_HOME']}/ops/provision.sh"
end
>>>>>>> 57860ddb9efe3db885e121e3263d15e8c64a755c
