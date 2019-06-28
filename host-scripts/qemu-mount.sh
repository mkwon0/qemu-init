#!/bin/bash

WORK_DIR=$HOME/qemu && mkdir -p $WORK_DIR
IMG_PATH=/var/lib/libvirt/images/centos7.0.qcow2

sudo yum install -y libguestfs-tools
mkdir -p root_mnt
sudo guestmount -a $IMG_PATH -m /dev/centos/root root_mnt
sudo cp -r root_mnt/home/mkwon/linux-5.0.7-swap $WORK_DIR/
sudo guestunmount root_mnt
rm -rf root_mnt

# $virsh edit centos7.0
# <domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
# <qemu:commandline>
#   <qemu:arg value='-s'/>
#   <qemu:arg value='-S'/>
# </qemu:commandline>
