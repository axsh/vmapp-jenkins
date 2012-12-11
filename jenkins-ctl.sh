#!/bin/bash

$(dirname BASH_SOURCE[0])/vmbuilder/kvm/rhel/6/misc/kvm-ctl.sh $1 --config_path=jenkins.conf
