#!/bin/bash

HOST=$1
USER=$2
PORT=22
KEY_FILE=$3
LOCAL_DIR=$4
REMOTE_DIR=/home/ubuntu/box/
ZIP_DIR=/home/ubuntu/box/deploy/
TEMP_DIR=/home/ubuntu/box/deploy/temp/

#Creating local *.zip
VERSION_SHORT=$(git rev-parse --short HEAD)
VERSION_FULL=$(git rev-parse HEAD)
echo $VERSION_SHORT > version.txt
echo $VERSION_FULL >> version.txt
zip -r see_through_$VERSION_SHORT * -x ".git" -x ".idea" -x "package.sh" -x "*.sh~"

#Copying *.zip to server
ssh -i $KEY_FILE -p $PORT $USER@$HOST mkdir -p $TEMP_DIR
scp -rp -P$PORT -i $KEY_FILE $LOCAL_DIR/*.zip $USER@$HOST:$TEMP_DIR
scp -rp -P$PORT -i $KEY_FILE $LOCAL_DIR/*.zip $USER@$HOST:$ZIP_DIR
scp -rp -P$PORT -i $KEY_FILE $LOCAL_DIR/setup.sh $USER@$HOST:
ssh -i $KEY_FILE -p $PORT $USER@$HOST bash setup.sh
