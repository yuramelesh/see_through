Vagrant.configure(2) do |config|

  config.env.enable

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

  bundle install --gemfile=#{SEE_THROUGH_HOME_PATH}Gemfile --no-cache --no-rdoc --no-ri

  SHELL

  config.vm.synced_folder "deploy/temp", SEE_THROUGH_HOME_PATH

end
