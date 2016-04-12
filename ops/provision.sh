echo "------------------------------------------------------------------"
echo "------------------ Provision package lists -----------------------" 
echo "------------------------------------------------------------------"

sudo apt-get -y update

echo "------------------------------------------------------------------"
echo "--------------------- Install ruby -------------------------------" 
echo "------------------------------------------------------------------"

curl -L https://get.rvm.io | bash -s stable --ruby=2.2.1-dev

sudo apt-get install -y ruby-all-dev

echo "------------------------------------------------------------------"
echo "--------------------- Install gems -------------------------------" 
echo "------------------------------------------------------------------"


sudo gem install activerecord
sudo gem install octokit
sudo apt-get install libsqlite3-dev
sudo apt-get install sqlite3
sudo gem install sqlite3
sudo gem install json
sudo gem install sinatra
sudo gem install haml
sudo gem install time_difference

echo "------------------------------------------------------------------"
echo "--------------------- Add env vars -------------------------------" 
echo "------------------------------------------------------------------"

source ~/.profile && [ -z "$SEE_THROUGH_TOKEN" ] && echo "export SEE_THROUGH_TOKEN=e56363fd9d6f65bb87754de7ca5ecc8a806b0319" >> ~/.profile
source ~/.profile && [ -z "$SEE_THROUGH_EMAIL" ] && echo "export SEE_THROUGH_EMAIL=marshall@vgs.io" >> ~/.profile
source ~/.profile && [ -z "$SEE_THROUGH_EMAIL_PASS" ] && echo "export SEE_THROUGH_EMAIL_PASS=80RTeSQdBNfJ2X4cZauZew" >> ~/.profile
source ~/.profile

echo "------------------------------------------------------------------"
echo "--------------------- Run daily_report ---------------------------" 
echo "------------------------------------------------------------------"

cd workspace/see_through/
ruby daily_report.rb

echo "0 * * * * ruby 'home/ubuntu/workspace/see_through/daily_report.rb'" | crontab -
echo "*/15 * * * * ruby 'home/ubuntu/workspace/see_through/conflict_checker.rb'" | crontab -
