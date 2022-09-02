#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${APM_TMP_DIR}" ]]; then
    echo "APM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_INSTALL_DIR}" ]]; then
    echo "APM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_BIN_DIR}" ]]; then
    echo "APM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $APM_TMP_DIR/cpython-3.9.13.tar.gz
  tar xf $APM_TMP_DIR/cpython-3.9.13.tar.gz -C $APM_PKG_INSTALL_DIR
  rm $APM_TMP_DIR/cpython-3.9.13.tar.gz

  wget https://github.com/cruise-automation/fwanalyzer/archive/0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23.tar.gz -O $APM_TMP_DIR/0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23.tar.gz
  tar xf $APM_TMP_DIR/0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23.tar.gz -C $APM_TMP_DIR
  mv $APM_TMP_DIR/fwanalyzer-0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23/devices $APM_PKG_INSTALL_DIR
  mv $APM_TMP_DIR/fwanalyzer-0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23/scripts $APM_PKG_INSTALL_DIR
  rm $APM_TMP_DIR/0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23.tar.gz
  rm -rf $APM_TMP_DIR/fwanalyzer-0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23

  wget https://github.com/AttifyOS/fwanalyzer/releases/download/v1.4.3/fwanalyzer-build.tar.gz -O $APM_TMP_DIR/fwanalyzer-build.tar.gz
  tar xf $APM_TMP_DIR/fwanalyzer-build.tar.gz -C $APM_PKG_INSTALL_DIR
  rm $APM_TMP_DIR/fwanalyzer-build.tar.gz

  echo "#!/bin/bash" > $APM_PKG_BIN_DIR/fwanalyzer
  echo "PATH=$APM_PKG_INSTALL_DIR/bin/:$APM_PKG_INSTALL_DIR/scripts/:$APM_PKG_INSTALL_DIR/python/bin/:\$PATH $APM_PKG_INSTALL_DIR/bin/fwanalyzer" >> $APM_PKG_BIN_DIR/fwanalyzer
  chmod +x $APM_PKG_BIN_DIR/fwanalyzer

  echo "#!/bin/bash" > $APM_PKG_BIN_DIR/fwanalyzer.check
  echo "PATH=$APM_PKG_INSTALL_DIR/bin/:$APM_PKG_INSTALL_DIR/scripts/:$APM_PKG_INSTALL_DIR/python/bin/:\$PATH $APM_PKG_INSTALL_DIR/python/bin/python3.9 $APM_PKG_INSTALL_DIR/devices/check.py" >> $APM_PKG_BIN_DIR/fwanalyzer.check
  chmod +x $APM_PKG_BIN_DIR/fwanalyzer.check

  sed -i "1c #!$APM_PKG_INSTALL_DIR/python/bin/python3.9" $APM_PKG_INSTALL_DIR/devices/check.py
  sed -i "1c #!$APM_PKG_INSTALL_DIR/python/bin/python3.9" $APM_PKG_INSTALL_DIR/devices/android/check_ota.py
  sed -i "1c #!$APM_PKG_INSTALL_DIR/python/bin/python3.9" $APM_PKG_INSTALL_DIR/scripts/prop2json.py

  echo "This package adds the following commands:"
  echo " - fwanalyzer"
  echo " - fwanalyzer.check"
}

uninstall() {
  rm -rf $APM_PKG_INSTALL_DIR/*
  rm $APM_PKG_BIN_DIR/fwanalyzer
  rm $APM_PKG_BIN_DIR/fwanalyzer.check
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1