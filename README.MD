##########################################
#                                        #
#       NTWK Team Automation             #
#                                        #
# Initial Palo Setup - Post Deployment   #
#                                        #
##########################################

1) Activates the Firewalls with given Auth Code
2) Installs latest dynamic Updates (AV, Wildfire, Content)
3) Schedules dynamic Updates
4) Attempts software Update - !!!! IF THE UPDATE DOES NOT FOLLOW THE PALO UPGRAE PATH YOU NEED TO PERFORM MANUALLY !!!!
5) Disables Telemetry
6) Adds Master Key and Panorama IP
7) Deletes Default RT
8) Setup HA interface automatically detecting the Cloud deployment (AWS, Azure)
9) Enables HA and verifies cluster

Unfortunately, you cannot force upgrade path changes. Palo allows specific update path with this module. Check UPGRADE MATRIX before using this Playbook

##########################################
#                                        #
#       NTWK Team Automation             #
#                                        #
#    Upgrade PanOS HA A-A Cluster        #
#                                        #
##########################################

This playbooks performs upgrades or downgrades for Palo PanOS software, following the recommended paths from Palo
If you want to follow an unsupported path you need to perform the changes manually

Steps:
1) Backup
2) Failover to Secondary Firewall
3) Check traffic - Status
4) Updates Primary and check status
5) Failback to Primary - Check status
6) Perform update to Secondary
7) Verify Cluster

*** This is tested with VM-Series for both downgrade and upgrade
Unfortunately, you cannot force upgrade path changes. Palo allows specific update path with this module. Check UPGRADE MATRIX before using this Playbook
