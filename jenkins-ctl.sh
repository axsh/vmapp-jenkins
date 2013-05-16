#!/bin/bash

base_dir=$(dirname ${BASH_SOURCE[0]})
env=$1

case $2 in
build)
  ${base_dir}/build-vmapp.sh $1
  ;;
start|stop)
  ${base_dir}/vmbuilder/kvm/rhel/6/misc/kvm-ctl.sh $2 --config_path=${base_dir}/${env}.conf --viftab=${base_dir}/${env}.viftab
  ;;
esac
