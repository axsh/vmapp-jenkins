#!/bin/bash
#
# requires:
#  bash
#  dirname, pwd
#  find, sed
#  vmbuilder.sh => git://github.com/hansode/vmbuilder.git
#
set -e
set -x

function list_guestroot_tree() {
  cd ${guestroot_dir}
  find . ! -type d | sed s,^\.,, | egrep -v '^/(.gitkeep|functions.sh)'
}

function generate_copyfile() {
  echo "[INFO] Generating copy.txt"

  [[ -d "${guestroot_dir}" ]] && {
    while read line; do
      echo ${guestroot_dir}${line} ${line}
    done < <(list_guestroot_tree) > ${manifest_dir}/copy.txt
  }

  cat ${manifest_dir}/copy.txt
}

function vmbuilder_path() {
  # should be added vmbuilder installation path to $PATH environment
  which vmbuilder.sh
}

function packages_option() {
  sed -e 's/[[:space:]]//g' -e 's/^/--addpkg /' ${abs_dirname}/packages
}

function build_vm() {
  [[ $# -eq 1 ]] || { echo "wrong number of arguments $# for 1" >&2; return 1; }
  local target=${1}
  local config_path=${abs_dirname}/${target}.conf

  [[ -f ${config_path} ]] || { echo "config file not found: ${config_path}" >&2; return 1; }
  local nictab=${abs_dirname}/${target}.nictab
  local routetab=${abs_dirname}/${target}.routetab

  . ${config_path}

  [[ -d ${guestroot_dir} ]] && rm -rf ${guestroot_dir} || :
  cp -a ${abs_dirname}/guestroot ${tmp_dir}
  [[ -d ${abs_dirname}/guestroot.${target} ]] && {
    cp -a ${abs_dirname}/guestroot.${target} -T ${guestroot_dir}
  }

  generate_copyfile

  echo "[INFO] Building vmimage"

  local version=1
  local arch=$(arch)
  local raw=${name}.$(date +%Y%m%d).$(printf "%02d" ${version}).${arch}.raw
  [[ -f ${raw} ]] && {
    version=$((${version} + 1))
    raw=${name}.$(date +%Y%m%d).$(printf "%02d" ${version}).${arch}.raw
  }

  $(vmbuilder_path) \
   --distro-arch=${arch} \
           --raw=${raw} \
          --copy=${manifest_dir}/copy.txt \
    --execscript=${manifest_dir}/execscript.sh \
    --nictab=${nictab} \
    --routetab=${routetab} \
    $(packages_option) \
    --config-path=${config_path}

  echo "[INFO] Modify symlink"
  echo "ln -sf ${abs_dirname}/${raw} ${abs_dirname}/${name}.raw"
  ln -sf ${abs_dirname}/${raw} ${abs_dirname}/${name}.raw 

  local num=$(ls ${abs_dirname}/${target}.*.raw | wc -l) 
  local limit=3
  [[ ${num} -le ${limit} ]] || {
    echo "[INFO] Deleting old vmimages"
    ls -t ${abs_dirname}/${target}.*.raw | tail -$((${num} - ${limit})) | while read file; do
      echo "rm ${file}"
      rm ${file}
    done
  }

  [[ -f ~/.ssh/known_hosts ]] && [[ -n "${ipaddr}" ]] && ssh-keygen -R ${ipaddr}
}

## variables

### environment variables

export LC_ALL=C
export LANG=C

### read-only variables

readonly abs_dirname=$(cd $(dirname $0) && pwd)

readonly manifest_dir=${abs_dirname}
readonly tmp_dir=${abs_dirname}/tmp
readonly guestroot_dir=${tmp_dir}/guestroot

mkdir -p ${tmp_dir}

###

#declare vmapp_name=${1:-vmapp-ashiba}

## main

# enable to set PATH at config.env
[[ -f ${abs_dirname}/config.env ]] && . ${abs_dirname}/config.env || :

build_vm ${1:-shinjuku}
