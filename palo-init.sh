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

E0F

read -p "Enter your chose (1/2): " choice

case "$choice" in 
1)
    echo "this is choise 1"
    cluster=1
    ;;
2)
    echo "this is 2"
    cluster=0
    ;;
esac

echo "$cluster"

read -p "Enter Project name/number: " project

if [ "$cluster" = "1" ]; then
    read -p "Enter Firewall 1 IP: " firewall1_ip
    read -p "Enter Firewall 2 IP: " firewall2_ip
else
    read -p "Enter Firewall IP: " firewall1_ip
fi

read -p "Provide an encryption password for the Inventory (Ansible Vault): " enc_password

echo "Creating Project folder"
mkdir $project
cd $project

echo "Creating Inventory"
output_file="inventory.txt"

if [ "$cluster" = "1" ]; then 
    cat <<E0F  >$output_file
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

echo "Creating host_var folder"
mkdir host_vars
cd host_vars

echo "Creating the host vars sets"
output_file_1="firewall1.yml"
output_file_2="firewall2.yml"

if [ "$cluster" = "1" ]; then
    read -p "Give hostname for Firewall1: " firewall1_name
    read -p "Give hostname for Firewall2: " firewall2_name
    read -p "Give MGMT IP for Firewall1: " firewall1_mgmt_ip
    read -p "Give MGMT IP for Firewall2: " firewall2_mgmt_ip
    read -p "Give HA IP for Firewall1: " firewall1_ha_ip
    read -p "Give HA IP for Firewall2: " firewall2_ha_ip
    read -p "Give temp password for Firewalls: " temp_pass
    read -p "Give required software version: " soft_version
	read -p "Provide the Master Key: " master_key1
    read -p "Give auth code: " auth_code

    cat <<E0F  >$output_file_1
---
ip_address: "$firewall1_ip"
username: "protera"
password: "$temp_pass"
hostname: "$firewall1_name"
ha_peer_mgmt: "$firewall1_mgmt_ip"
ha_peer_mgmt2: "$firewall2_mgmt_ip"
ha_int_ip: "$firewall1_ha_ip"
dev_priority: 90
version1: "$soft_version"
admin_pass1: "$admin_pass"
auth_code1: "$auth_code"
E0F
    cat <<E0F  >$output_file_2
---
ip_address: "$firewall2_ip"
username: "protera"
password: "$temp_pass"
hostname: "$firewall2_name"
ha_peer_mgmt: "$firewall2_mgmt_ip"
ha_peer_mgmt2: "$firewall1_mgmt_ip"
ha_int_ip: "$firewall2_ha_ip"
dev_priority: 100
version1: "$soft_version"
admin_pass1: "$admin_pass"
auth_code1: "$auth_code"
E0F
else
    read -p "Give hostname for Firewall1: " firewall1_name
    read -p "Give MGMT IP for Firewall1: " firewall1_mgmt_ip
    read -p "Give HA IP for Firewall1: " firewall1_ha_ip
    read -p "Give temp password for Firewalls: " temp_pass
    read -p "Give required software version: " soft_version
	read -p "Provide the Master Key: " master_key1
    read -p "Give auth code: " auth_code


    cat <<E0F  >$output_file_1
---
ip_address: "$firewall1_ip"
username: "protera"
password: "$temp_pass"
hostname: "$firewall1_name"
ha_peer_mgmt: "$firewall1_mgmt_ip"
ha_int_ip: "$firewall1_ha_ip"
dev_priority: 90
version1: "$version"
admin_pass1: "$admin_pass"
auth_code1: "$auth_code"
E0F
fi

read -p "Do you want to perform a version upgrade during the setup? 1:YES 2:NO " vers_upgrade

if [ "$vers_upgrade" = "1" ]; then
    cd ..
    echo "Download the ansible files"
    wget https://prot-ansible-ntwk.s3.us-east-1.amazonaws.com/palo-init-update.yml
    clear
    echo "Running Ansible"
    ansible-playbook -i inventory.txt palo-init-update.yml
else
    cd ..
    wget https://prot-ansible-ntwk.s3.us-east-1.amazonaws.com/palo-init-wo-update.yml
    clear
    echo "Running Ansible"
    ansible-playbook -i inventory.txt palo-init-wo-update.yml
fi
