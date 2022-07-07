#!/bin/sh
AWS_MACHINE=''
cd $2/setups/$1
vagrant up $AWS_MACHINE --provider=aws
