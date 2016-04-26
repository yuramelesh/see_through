#!/bin/bash

if [ $# -eq 0 ]
then
 PORT=2222
 USER=vagrant
 HOST=localhost
<<<<<<< HEAD
 KEY_FILE=/home/melesh/box/.vagrant/machines/default/virtualbox/private_key
 LOCAL_DIR=/home/melesh/RubymineProjects/see_through
 REMOTE_DIR=~/box/deploy/
=======
 KEY_FILE=/home/ubuntu/box/.vagrant/machines/default/virtualbox/private_key
 LOCAL_DIR=/home/ubuntu/box/deploy/temp
 REMOTE_DIR=$SEE_THROUGH_HOME
>>>>>>> 57860ddb9efe3db885e121e3263d15e8c64a755c
else
 HOST=$1
 USER=$2
 PORT=22
 KEY_FILE=$3
 LOCAL_DIR=$4
 REMOTE_DIR=/home/ubuntu/box/deploy/
 TEMP_DIR=/home/ubuntu/box/deploy/see_through
fi

<<<<<<< HEAD
ssh -i $KEY_FILE -p $PORT $USER@$HOST sudo mkdir -p $REMOTE_DIR
=======
ssh -i $KEY_FILE -p $PORT $USER@$HOST mkdir -p $REMOTE_DIR
>>>>>>> 57860ddb9efe3db885e121e3263d15e8c64a755c
scp -rp -P$PORT -i $KEY_FILE $LOCAL_DIR/*.zip $USER@$HOST:$REMOTE_DIR
ssh -i $KEY_FILE -p $PORT $USER@$HOST unzip *.zip -d $REMOTE_DIR
