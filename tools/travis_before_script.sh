#!/bin/sh

set -x
set -e

mkdir -p vendor
cd vendor
if [ "$MYSQL_VERSION" = "system" ]; then
    sudo apt-get -y build-dep mysql-server
    apt-get source mysql-server
    ln -s $(find . -maxdepth 1 -type d | sort | tail -1) mysql
    cd mysql
    debuild -us -uc -Tconfigure
    make -j$(grep '^processor' /proc/cpuinfo | wc -l) > /dev/null
    cd ..
else
    sudo apt-get -y install cmake
    wget http://ftp.jaist.ac.jp/pub/mysql/Downloads/MySQL-5.5/mysql-${MYSQL_VERSION}.tar.gz
    tar xvzf mysql-${MYSQL_VERSION}.tar.gz
    ln -s mysql-${MYSQL_VERSION} mysql
    cd mysql
    BUILD/compile-amd64-debug-max
    cd ..
fi
cd ..

./autogen.sh
./configure \
    --with-mysql-source=$PWD/vendor/mysql \
    --with-mysql-config=$PWD/vendor/mysql/mysql_config
