#!/bin/sh

ENV="pprod01"
projectId="caas-delta-pprod01"
clusterZone="asia-southeast2-a"
region="asia-southeast2"


rootFolder="/mnt/c/ICS/tm-upgrade/tools/tm-update"

db_gce_instance="pprod01-db-instance"
bastion_gce_instance="pprod01-bastion-host"


#TODO: This variable needs to be from secured
HC_VAULT_ROOT="s.ZmhRRk08rtlfUT7KLjRV8kx0"

#Upgrade TM from 1.13.15 to 2.81
gcloud compute scp  --recurse ${rootFolder}/heper_scripts/2.8.1 ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/2.8.1/update-2.8.1.sh $ENV $region $projectId"
gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/2.8.1"
