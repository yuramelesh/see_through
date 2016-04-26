#!/bin/bash

HOME_DIR=$1

DEPLOY_DIR="$HOME_DIR/deploy"
PACKAGED_APP="$DEPLOY_DIR/$2"
TEMP_DIR="$DEPLOY_DIR/temp"
unzip -o $PACKAGED_APP -d $TEMP_DIR -x "setup.sh" 1>/dev/null 2>&1

echo "Provisioning environment variables"
echo "export SEE_THROUGH_HOME=`readlink -f $TEMP_DIR`" > $HOME_DIR/.env

echo "Staging a Vagrant box ..."
if [ ! -f $HOME_DIR/Vagrantfile ]; then
    vagrant init ubuntu/trusty32
fi

cp -u "$TEMP_DIR/Vagrantfile" box/

echo "Done."