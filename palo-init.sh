#!/bin/bash
cat <<E0F
############################################################
#               NTWK Team - PA Init - Ansible              #
############################################################                                                                                                                                                                                                                                              
E0F
cat <<E0F
Choose from below:
1. Palo Alto Cluster Setup (AWS/Azure)
2. Single Firewall Setup (AWS/Azure)
3. Cluster Software Update
E0F

read -p "Enter your chose (1/2/3): " choice

case $choice in 
1)
    echo "this is choise 1"
    cluster=1
    ;;
2)
    echo "this is 2"
    cluster=0
    ;;
3)
    echo "this is 3"
    cluster=1
    ;;
esac

read -p "Enter Project name/number" project

if [ $cluster -gt 1 ]; then
    read -p "Enter Firewall 1 IP: " firewall1_ip
    read -p "Enter Firewall 2 IP: " firewall2_ip
else
    read -p "Enter Firewall IP: " firewall1_ip
fi

read -p "Provide an encryption password (That cannot be revived): " enc_password

echo "Creating Project folder"
mkdir $project
cd $project

echo "Creating Inventory"
output_file="inventory.txt"
if ["$cluster" -eq 1]; then 
    cat <<E0F >$output_file
[firewalls]
firewall1
firewall2
E0F
else
    cat <<E0F > $output_file
[firewalls]
firewall1
E0F
fi