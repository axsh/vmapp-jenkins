#!/bin/bash

$(dirname BASH_SOURCE[0])/vmbuilder/kvm/rhel/6/misc/kvm-ctl.sh $2 --config_path=$1.conf
