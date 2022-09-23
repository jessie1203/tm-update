#!/bin/sh

ENV=stg01
projectId="caas-indian-stg01"
clusterZone="asia-southeast2-a"
region=asia-southeast2


rootFolder="/mnt/c/ICS/tm-upgrade/tools/tm-update"

db_gce_instance="stg01-db-instance"
bastion_gce_instance="stg01-bastion-host"


#TODO: This variable needs to be from secured
HC_VAULT_ROOT="s.peZevIBy7VoMuZYKvt9ZYYmU"

#DB Update remove wal2json
#gcloud compute scp  --recurse ${rootFolder}/heper_scripts/db ${db_gce_instance}:~  --project ${projectId} --zone ${clusterZone}

#gcloud compute ssh ${db_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- 'sh ~/db/db.sh'
#gcloud compute ssh ${db_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- 'rm -rf ~/db'

#Upgrade TM from 1.13.4 to 1.13.15
#gcloud compute scp  --recurse ${rootFolder}/heper_scripts/1.13.15 ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
#gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/1.13.15/update-1.13.15.sh $ENV $region $projectId $HC_VAULT_ROOT"
#gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/1.13.15"

#Upgrade TM from 1.13.15 to 2.81
gcloud compute scp  --recurse ${rootFolder}/heper_scripts/2.8.1 ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/2.8.1/update-2.8.1.sh $ENV $region $projectId"
gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/2.8.1"
