#!/bin/bash

echo "* Install the initiator package ..."
dnf install -y iscsi-initiator-utils

echo "* Set the initiator name ..."
echo "InitiatorName=iqn.2023-02.lab.demo:vm2.init1" | tee /etc/iscsi/initiatorname.iscsi

echo "* Enable authentication with username and password ..."
sed -i '58,s/#//' /etc/iscsi/iscsid.conf
sed -i '69,70s/#//' /etc/iscsi/iscsid.conf
sed -i '69s/= username/= vagrant/' /etc/iscsi/iscsid.conf
sed -i '70s/= password/= mypassword/' /etc/iscsi/iscsid.conf

echo "* Restart the service ..."
systemctl restart iscsi

echo "* Initiate a target discovery ..."
iscsiadm -m discovery -t sendtargets -p vm1

echo "* Login to the target ..."
iscsiadm -m node --login

echo "* Confirm the established session ..."
iscsiadm -m session -o show

echo "*  Create a partition on the storage device ..."
parted -s /dev/sdc -- mklabel msdos mkpart primary 16384s -0m

echo "*  Create a filesystem ..."
mkfs.ext4 /dev/sdc1

echo "*  Prepare a mountpoint ..."
mkdir -p /mnt/iscsi

echo "*  Mount the it ..."
mount /dev/sdc1 /mnt/iscsi

echo "*  Export the UUID in an environment variable ..."
export DISK_UUID
DISK_UUID=$(ls -l /dev/disk/by-uuid/ | grep sdc1 | cut -d " " -f 9)

echo "*  Mount on boot ..."
umount /mnt/iscsi
echo "UUID=$DISK_UUID /mnt/iscsi ext4 _netdev 0 0" | tee -a /etc/fstab
mount -a

