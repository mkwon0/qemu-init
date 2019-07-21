#!/bin/bash
NUM_CPU_HERE=16
DIR_WORK=/home/mkwon/src
DIR=/home/mkwon/qemu-init

#sudo yum install -y git screen vim
### Add simple configuration to vi configuration
#cat <<EOF >$HOME/.vimrc
#let g:go_version_warning = 0
#vnoremap <S-D> :norm i#<CR>
#vnoremap <S-U> :norm ^x<CR>
#EOF

## Init packages
#sudo yum install screen -y
#sudo yum -y groupinstall "Development Tools"
#sudo yum -y install ncurses-devel bison bc flex eltutils-libelf-devel openssl-devel elfutils-libelf-devel

## Add nameserver
#sudo sed -i '1 i\nameserver 8.8.8.8' /etc/resolv.conf
#sudo sed -i '1 i\nameserver 8.8.4.4' /etc/resolv.conf

## Clone linux-5.0.7-swap
#cd $DIR_WORK
#git clone git@github.com:mkwon0/linux-5.0.7-swap.git
#cp qemu-init/.config linux-5.0.7-swap/
#cd linux-5.0.7-swap
#make -j${NUM_CPU_HERE} -s
#make modules -j${NUM_CPU_HERE} -s
#sudo make modules_install -j${NUM_CPU_HERE} -s
#sudo make install -j${NUM_CPU_HERE} -s
#sudo grub2-mkconfig -o /boot/grub2/grub.cfg
#sudo grubby --set-default /boot/vmlinuz-5.0.7.img

## Clone util-linux-swap
cd $DIR_WORK \
&& git clone git@github.com:mkwon0/util-linux-swap.git \
&& cd util-linux-swap \
&& ./autogen.sh \
&& ./configure --disable-libuuid --prefix=/usr/sbin \
&& sudo make -j16 -s \
&& sudo cp swapon swapoff /usr/sbin/ \

#sudo reboot
