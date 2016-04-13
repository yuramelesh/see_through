#!/bin/sh

if [ $# -eq 0 ]
then
    PORT=2222
    USER=vagrant
    HOST=localhost
    KEY_FILE=/home/melesh/ubuntu/.vagrant/machines/default/virtualbox/private_key
    REMOTE_DIR=/home/vagrant/workspace/
else
    HOST=$1
    USER=$2
    PORT=22
    KEY_FILE=$3
    REMOTE_DIR=workspace
fi

ssh -i $KEY_FILE -p$PORT $USER@$HOST "mkdir -p $REMOTE_DIR"
ssh -i $KEY_FILE -p $PORT $USER@$HOST sudo chmod a+rwx $REMOTE_DIR
scp -rp -P$PORT -i $KEY_FILE ../../see_through $USER@$HOST:$REMOTE_DIR/
ssh -i $KEY_FILE -p $PORT $USER@$HOST $REMOTE_DIR/see_through/ops/provision.sh

