#!/bin/bash
# Inspired by http://ubuntuforums.org/showthread.php?t=910717.
set -o errexit

if [ "$#" -ne 2 ]; then
  echo "$0 <build-increment> <386|amd64>"
  echo
  echo "where build-increment is usually an integer, upped by 1 for every new build of this version."
  exit 1
fi

VERSION="$(cat ./version.go | grep "const VERSION" | awk '{print $NF}' | sed 's/"//g')-$1"
BASEDIR=statsdaemon_$VERSION
ARCH=$2

GOOS=linux GOARCH=$ARCH go build

if [ -d $BASEDIR ];then
  rm -frv $BASEDIR
fi
cp -r deb $BASEDIR
mkdir -pv $BASEDIR/usr/local/bin
cp -v statsdaemon $BASEDIR/usr/local/bin

sed "s/VERSION/$VERSION/g" deb/DEBIAN/control | sed "s/ARCH/$ARCH/g" > $BASEDIR/DEBIAN/control

if [ -e ${BASEDIR}.deb ];then
  rm -v ${BASEDIR}.deb
fi
dpkg-deb --build $BASEDIR
