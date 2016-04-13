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
echo "--------------------- Add cron jobs ------------------------------" 
echo "------------------------------------------------------------------"

echo "0 * * * * /home/ubuntu/daily_report.sh
*/15 * * * * /home/ubuntu/conflict_checker.sh" | crontab -
