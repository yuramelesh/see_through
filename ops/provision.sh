echo "------ Provision package lists ------"

sudo apt-get -y update
sudo apt-get -y unzip

echo "------ Install ruby ------"

curl -L https://get.rvm.io | bash -s stable --ruby=2.2.1-dev

sudo apt-get install -y ruby-all-dev

<<<<<<< HEAD
echo "------ Install bundler ------"

sudo gem install bundler

echo "------ Install sqlite3 ------"

sudo apt-get install libsqlite3-dev
sudo apt-get install sqlite3

=======
echo "------ Install sqlite3 ------"

sudo apt-get install libsqlite3-dev
sudo apt-get install sqlite3

echo "------ Install gems ------"

sudo gem install activerecord --no-rdoc --no-ri
sudo gem install octokit --no-ri --no-rdoc
sudo gem install sqlite3 --no-ri --no-rdoc
sudo gem install json --no-ri --no-rdoc
sudo gem install sinatra --no-ri --no-rdoc
sudo gem install haml --no-ri --no-rdoc
sudo gem install time_difference --no-ri --no-rdoc

>>>>>>> 57860ddb9efe3db885e121e3263d15e8c64a755c
echo "------ Install git ------"

sudo apt-get -y install git

echo "------ Add cron jobs ------   "

<<<<<<< HEAD
echo "0 * * * * ENV['SEE_THROUGH_HOME_PATH']daily_report.sh
*/15 * * * * ENV['SEE_THROUGH_HOME_PATH']conflict_checker.sh" | crontab -
=======
echo "0 * * * * $SEE_THROUGH_HOME/daily_report.sh
*/15 * * * * $SEE_THROUGH_HOME/conflict_checker.sh" | crontab -
>>>>>>> 57860ddb9efe3db885e121e3263d15e8c64a755c
