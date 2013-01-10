#!/bin/bash

case $2 in
build)
  $(dirname BASH_SOURCE[0])/build-vmapp.sh $1
  ;;
start|stop)
  $(dirname BASH_SOURCE[0])/vmbuilder/kvm/rhel/6/misc/kvm-ctl.sh $2 --config_path=$1.conf --viftab=${1}.viftab
  ;;
esac
