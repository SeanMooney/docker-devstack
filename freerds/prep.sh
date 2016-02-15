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


#
# Determine the Linux distro
#
if [ -e /etc/centos-release ]; then
  LINUX_DISTRO_FILE=/etc/centos-release
else
  LINUX_DISTRO_FILE=/etc/issue
fi

LINUX_DISTRO_NAME=`cat $LINUX_DISTRO_FILE|head -1|awk '{ print $1 }'`

case $LINUX_DISTRO_NAME in
  Ubuntu|Debian)
    LINUX_DISTRO_VERSION=`cat $LINUX_DISTRO_FILE|head -1|awk '{ print $2 }'`
    ;;
  CentOS)
    LINUX_DISTRO_VERSION=`cat $LINUX_DISTRO_FILE|head -1|awk '{ print $3 }'`
    ;;
  *)
    echo "Unsupported Linux distro '$LINUX_DISTRO_NAME'"
    exit
    ;;
esac

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


# Install the correct version of CMake
#
case $LINUX_DISTRO_NAME in
  Ubuntu|Debian)
    sudo apt-get install -y build-essential
    ;;
  CentOS)
    sudo yum groupinstall -y "Development Tools"
    ;;
esac

CMAKE_VERSION=2.8.12
CMAKE_FOLDER=cmake-$CMAKE_VERSION
CMAKE_ARCHIVE=$CMAKE_FOLDER.tar.gz
CMAKE_URL=http://www.cmake.org/files/v2.8/$CMAKE_ARCHIVE

RESULT=`cmake --version`
if [ "$RESULT" == "" ]; then
  # Download compressed archive
  pushd ~/Downloads
  wget $CMAKE_URL
  popd

  # Unpack compressed archive
  pushd ~/Downloads
  tar xvf $CMAKE_ARCHIVE
  pushd $CMAKE_FOLDER
  ./configure
  make
  sudo make install
  popd
  rm $CMAKE_ARCHIVE
  popd
else
  echo Found $RESULT
fi

#
# Install FreeRDP dependencies
#
case $LINUX_DISTRO_NAME in
  Ubuntu|Debian)
    sudo apt-get install -y \
    libssl-dev \
    libx11-dev libxext-dev libxinerama-dev libxcursor-dev libxkbfile-dev \
    libxv-dev libxi-dev libxdamage-dev libxrender-dev libxrandr-dev \
    libasound2-dev libcups2-dev libpulse-dev \
    libavutil-dev libavcodec-dev \
    libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev \
    && apt-get autoremove -y && apt-get autoclean -y
    ;;

  CentOS)
    sudo yum install -y \
    openssl-devel \
    libX11-devel libXext-devel libXinerama-devel libXcursor-devel libxkbfile-devel \
    libXv-devel libXtst-devel libXi-devel libXdamage-devel libXrandr-devel \
    alsa-lib-devel cups-devel ffmpeg-devel glib2-devel
    ;;
esac

#
# Install FreeRDS dependencies
#
case $LINUX_DISTRO_NAME in
  Ubuntu|Debian)
    sudo apt-get install -y \
    libpciaccess-dev libpam0g-dev libpng12-dev libjpeg-dev intltool \
    libexpat1-dev libxml-libxml-perl libtool bison flex xsltproc \
    libfreetype6-dev libfontconfig1-dev libpixman-1-dev xutils-dev \
    x11proto-gl-dev mesa-common-dev libgl1-mesa-dev xorg-dev \
    libboost-dev qt4-dev-tools libjson-c-dev libsndfile1-dev \
    libfuse-dev && apt-get autoremove -y && apt-get autoclean -y
    ;;

  CentOS)
    sudo yum install -y \
    finger patch gcc gcc-c++ make autoconf libtool automake pkgconfig \
    libpciaccess-devel openssl-devel gettext file pam-devel libjpeg-devel pixman-devel \
    libX11-devel libXfixes-devel libXfont-devel xorg-x11-proto-devel xorg-x11-xtrans-devel \
    flex bison libxslt perl-libxml-perl xorg-x11-font-utils xmlto-tex docbook-utils-pdf \
    boost-devel qt4-devel pulseaudio-libs-devel libtool-ltdl-devel libsndfile-devel speex-devel \
    fuse-devel
    ;;
esac

