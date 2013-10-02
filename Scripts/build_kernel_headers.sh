#!/bin/bash
cd
sudo apt-get install git-core build-essential
git clone --depth 1 git://github.com/raspberrypi/linux.git
cd linux
git checkout rpi-3.6.y
zcat /proc/config.gz > .config
make ARCH=arm oldconfig
make ARCH=arm
cd ..
# git clone git://github.com/tandersson/rf-bitbanger.git
# cd rf-bitbanger/rfbb
# make KERNELDIR=~/linux
# cd ..
# cd  rfbb_cmd
# make
# sudo make install
# sudo insmod /home/pi/rf-bitbanger/rfbb/rfbb.ko
# sudo mknod /dev/rfbb c 248 0
# sudo chown root:dialout /dev/rfbb
# sudo chmod g+rw /dev/rfbb
