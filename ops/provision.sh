echo "------ Provision package lists ------"

sudo apt-get -y update
sudo apt-get -y unzip

echo "------ Install ruby ------"

curl -L https://get.rvm.io | bash -s stable --ruby=2.2.1-dev

sudo apt-get install -y ruby-all-dev

echo "------ Install bundler ------"

sudo gem install bundler

echo "------ Install sqlite3 ------"

sudo apt-get install libsqlite3-dev
sudo apt-get install sqlite3

echo "------ Install git ------"

sudo apt-get -y install git

echo "------ Add cron jobs ------   "

echo "0 * * * * ENV['SEE_THROUGH_HOME_PATH']daily_report.sh
*/15 * * * * ENV['SEE_THROUGH_HOME_PATH']conflict_checker.sh" | crontab -