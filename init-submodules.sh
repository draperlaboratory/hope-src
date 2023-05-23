#! /bin/bash

submodules=($(git submodule--helper list | awk '{$1=$2=$3=""; print substr($0,4)}'))

private_submodules=(
  bsp
  pex-bootrom
  pex-kernel
  pex-firmware
)

usage () {
  echo "Usage: ./init-submodules.sh [-h] [-p]"
  echo "    -h: Display this help message"
  echo "    -p: Clone additional private modules, which include"
  echo "    ${private_submodules[@]}"
}

clone_private=false
while getopts ":hp" opt; do
  case "${opt}" in
    p)
      clone_private=true
      ;;
    h)
      usage && exit 0
      ;;
    ?)
      usage && exit 1
      ;;
  esac
done

echo ${submodules[@]}

echo ${private_submodules[@]}

if [ $clone_private = false ]; then
  for module in ${private_submodules[@]}; do
    echo "Disabling access to $module"
    git config --local submodule."$module".update none
  done
else
  for module in ${private_submodules[@]}; do
    echo "Enabling access to $module"
    git config --local --unset submodule."$module".update
  done
fi

GIT_SSL_NO_VERIFY=1 git submodule update --init --recursive
