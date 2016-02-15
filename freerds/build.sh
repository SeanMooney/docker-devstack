#! /bin/bash
#
#===========================================================================
#
# this script has been modified and is based on
# https://raw.githubusercontent.com/awakecoding/FreeRDS/master/build-freerds.sh
#
# build.sh
#
# This script builds and installs FreeRDS on a clean Linux distribution.
# Complete the following steps:
#
#   1. Install the Linux distro.
#   2. Open a Terminal window.
#   3. Download this script.
#   4. Run the command "chmod +x build-freerds.sh".
#   5. Run the command "./build-freerds.sh
#
# Once the installation has finished, here are instructions for running
# FreeRDS from the command line:
#
#   1. Run the command "cd /opt/FreeRDS/bin".
#   2. Open 2 more Terminal windows as root (e.g., "sudo gnome-terminal &").
#   3. Run "./freerds-server --nodaemon" in Terminal window 1.
#   4. Run "./freerds-manager --nodaemon" in Terminal window 2.
#   5. Connect with FreeRDP using "./xfreerdp /v:localhost /cert-ignore".
#
# Supported platforms include:
#
#   Ubuntu (12.10, 13.x, 14.x)
#   CentOS (6.x, 7.x)
#   Debian 7.x
#
#===========================================================================

GIT_ROOT_DIR=~/git/vworkspace
FREERDP_GIT=https://github.com/vworkspace/FreeRDP.git
FREERDS_GIT=https://github.com/vworkspace/FreeRDS.git
FREERDP_BRANCH=awakecoding
FREERDS_BRANCH=v2.0
FREERDS_INSTALL_DIR=/opt/FreeRDS

#
# Fetch sources from GitHub
#
case $LINUX_DISTRO_NAME in
  Ubuntu|Debian)
    sudo apt-get install -y git-core
    ;;
  CentOS)
    sudo yum install -y git-core
    ;;
esac

if [ ! -d $GIT_ROOT_DIR ]; then
  mkdir -p $GIT_ROOT_DIR
fi

if [ ! -d $GIT_ROOT_DIR/FreeRDP ]; then
  pushd $GIT_ROOT_DIR
  git clone $FREERDP_GIT
  cd FreeRDP
  git checkout $FREERDP_BRANCH
  popd
fi

if [ ! -d $GIT_ROOT_DIR/FreeRDP/server/FreeRDS ]; then
  pushd $GIT_ROOT_DIR/FreeRDP/server
  git clone $FREERDS_GIT
  cd FreeRDS
  git checkout $FREERDS_BRANCH
  popd
fi


#
# On 64-bit platforms, point to shared objects.
#
export LD_LIBRARY_PATH=/usr/lib

#
# Create the installation directory.
#
if [ ! -d $FREERDS_INSTALL_DIR ]; then
  sudo mkdir $FREERDS_INSTALL_DIR
  sudo chmod 777 $FREERDS_INSTALL_DIR
fi

#
# Clean the CMake cache.
#
if [ "$1" == "clean" ]; then
  pushd $GIT_ROOT_DIR/FreeRDP
  make clean
  sudo find . -name "CMakeCache.txt" | xargs rm -f
  sudo find . -name "CMakeFiles" | xargs rm -rf
  popd
fi

#
# Report the currently installed X server version.
#
X -version

#
# Build Xrds
#
pushd $GIT_ROOT_DIR/FreeRDP/server/FreeRDS
pushd module/X11/service/xorg-build
#sed -e 's#set(${EXTERNAL_PROJECT}_URL "http://xorg.freedesktop.org/releases/individual/xserver/${${EXTERNAL_PROJECT}_FILE}")#set(${EXTERNAL_PROJECT}_URL "https://github.com/freedesktop-unofficial-mirror/xorg__xserver/releases/tag/${${EXTERNAL_PROJECT}_FILE}")#g' -i CMakeLists.txt
sed -e 's#set(${EXTERNAL_PROJECT}_URL "http://xorg.freedesktop.org/releases/individual/xserver/${${EXTERNAL_PROJECT}_FILE}")#set(${EXTERNAL_PROJECT}_URL "ftp://artfiles.org/x.org/pub/individual/xserver/${${EXTERNAL_PROJECT}_FILE}")#g' -i CMakeLists.txt
cmake .
if [[ $? != 0 ]]; then
  exit
fi
make -j `nproc`
if [[ $? != 0 ]]; then
  exit
fi
cd ..
ln -s xorg-build/external/Source/xorg-server .
popd
popd


#
# Build FreeRDP (with FreeRDS)
#
pushd $GIT_ROOT_DIR/FreeRDP
cmake -DCMAKE_INSTALL_PREFIX=$FREERDS_INSTALL_DIR -DCMAKE_BUILD_TYPE=Debug -DSTATIC_CHANNELS=on -DWITH_CUPS=on -DWITH_SERVER=on -DWITH_XRDS=on .

mkdir -p -m 777 /usr/local/lib/pulse-4.0/
ln -s /usr/local/lib/pulse-4.0/ /usr/lib/pulse-4.0

make -j `nproc`

pushd ~/git/vworkspace/FreeRDP/server/FreeRDS/external/Source/pulseaudio/
make  -j `nproc`
make install
popd

make -j `nproc`
sudo make install
rm -rf ~/git/vworkspace
popd

