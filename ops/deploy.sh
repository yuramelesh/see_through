#!/bin/sh

if [ $# -eq 0 ]
then
 PORT=2222
 USER=vagrant
 HOST=localhost
 KEY_FILE=/home/melesh/virtual/.vagrant/machines/default/virtualbox/private_key
 LOCAL_DIR=../../see_through
 REMOTE_DIR=/home/vagrant/
else
 HOST=$1
 USER=$2
 PORT=22
 KEY_FILE=$3
 LOCAL_DIR=$4
 REMOTE_DIR=/home/ubuntu/box/deploy/
 TEMP_DIR=/home/ubuntu/box/deploy/see_through
fi

ssh -i $KEY_FILE -p $PORT $USER@$HOST mkdir -p $REMOTE_DIR
scp -rp -P$PORT -i $KEY_FILE $LOCAL_DIR/*.zip $USER@$HOST:$REMOTE_DIR

ssh -i $KEY_FILE -p $PORT $USER@$HOST mkdir -p $TEMP_DIR
scp -rp -P$PORT -i $KEY_FILE $LOCAL_DIR/*.zip $USER@$HOST:$TEMP_DIR

ssh -i $KEY_FILE -p $PORT $USER@$HOST unzip 'box/deploy/see_through/*.zip' -d 'box/deploy/see_through/'

ssh -i $KEY_FILE -p $PORT $USER@$HOST rsync -avz --ignore-existing '*.db' --ignore-existing '*.yml' --exclude '*.zip' box/deploy/see_through/ -o box/see_through/

ssh -i $KEY_FILE -p $PORT $USER@$HOST cd dox/ ; rm -rf deploy
