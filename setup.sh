#!/bin/bash

unzip /home/ubuntu/box/deploy/temp/*.zip -d /home/ubuntu/box/deploy/temp/

if [ ! -f /home/ubuntu/box/Vagrantfile ]; then
    vagrant init ubuntu/trusty32
fi

cp /home/ubuntu/box/deploy/temp/Vagrantfile box/