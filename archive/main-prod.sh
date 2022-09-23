#!/bin/sh

ENV="pprod01"
projectId="caas-production-285306"
clusterZone="asia-southeast2-a"
clusterZone2="asia-southeast2-b"
region="asia-southeast2"


rootFolder="/mnt/c/ICS/tm-upgrade/tools/tm-update"

db_gce_instance="prod-vault-db-a"
db_gce_instance2="prod-vault-db-b"

bastion_gce_instance="prod-bastion-linux"

# #DB Update remove wal2json node 1
# gcloud compute scp  --recurse ${rootFolder}/heper_scripts/db ${db_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
# gcloud compute ssh ${db_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- 'sh ~/db_prod/db.sh'
# gcloud compute ssh ${db_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- 'rm -rf ~/db_prod'
#
# #DB Update remove wal2json node 2
# gcloud compute scp  --recurse ${rootFolder}/heper_scripts/db ${db_gce_instance2}:~  --project ${projectId} --zone ${clusterZone2}
# gcloud compute ssh ${db_gce_instance} --zone ${clusterZone2} --tunnel-through-iap --project ${projectId} -- 'sh ~/db_prod/db.sh'
# gcloud compute ssh ${db_gce_instance} --zone ${clusterZone2} --tunnel-through-iap --project ${projectId} -- 'rm -rf ~/db_prod'


#Upgrade TM from 1.13.4 to 1.13.15
# gcloud compute scp  --recurse ${rootFolder}/heper_scripts/1.13.15_prod ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/1.13.15"
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/1.13.15_prod/update-1.13.15.sh $ENV $region $projectId $HC_VAULT_ROOT"
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/1.13.15_prod"

#Upgrade TM from 1.13.15 to 2.81
gcloud compute scp  --recurse ${rootFolder}/heper_scripts/2.8.1_prod ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/2.8.1"
gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/2.8.1_prod/update-2.8.1.sh $ENV $region $projectId"
gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/2.8.1_prod"
