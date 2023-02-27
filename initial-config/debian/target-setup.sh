#!/bin/bash

echo "* Install the required package ..."
apt-get update -y && apt-get install -y targetcli-fb

# 
#  echo "* Install ufw ..."
#  apt-get install -y uwf
#


echo "* Create a folder to store the iSCSI disk files ..."
mkdir /var/lib/iscsi-images


echo "* Create an iSCSI disk ..."
targetcli backstores/fileio create D1 /var/lib/iscsi-images/D1.img 5G

echo "* Define a new target ..."
targetcli iscsi/ create iqn.2023-02.lab.demo:vm3.tgt1

echo "* Create a LUN using the disk created above ..."
targetcli iscsi/iqn.2023-02.lab.demo:vm3.tgt1/tpg1/luns create /backstores/fileio/D1

echo "* Register the initiator ..."
targetcli iscsi/iqn.2023-02.lab.demo:vm3.tgt1/tpg1/acls create iqn.2023-02.lab.demo:vm4.init1

echo "* Set a username for the initiator ..."
targetcli iscsi/iqn.2023-02.lab.demo:vm3.tgt1/tpg1/acls/iqn.2023-02.lab.demo:vm4.init1 set auth userid=vagrant

echo "* Set a password for the initiator ..."
targetcli iscsi/iqn.2023-02.lab.demo:vm3.tgt1/tpg1/acls/iqn.2023-02.lab.demo:vm4.init1 set auth password=mypassword

#
# echo "* Adjust the firewall settings ..."
# ufw allow 3260/tcp
# ufw reload
#
echo "* Enable and start the service ..."
systemctl enable --now rtslib-fb-targetctl.service