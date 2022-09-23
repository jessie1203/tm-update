#!/bin/sh

ENV="prod"
projectId="caas-production-285306"
clusterZone="asia-southeast2-a"
region="asia-southeast2"


rootFolder="/mnt/c/ICS/tm-upgrade/tools/tm-update"
bastion_gce_instance="prod-bastion-linux"

#TODO: This variable needs to be from secured
HC_VAULT_ROOT="s.peZevIBy7VoMuZYKvt9ZYYmU"

#Upgrade TM from 2.8.1 to 2.8.10
# version="2.8.10"
# gcloud compute scp  --recurse ${rootFolder}/heper_scripts/$version ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/$version/update-$version-$ENV.sh $ENV $region $projectId $HC_VAULT_ROOT $version"
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/$version"


#Upgrade TM from 2.8.10 to 3.3.3.3
# version="3.3.3.3"
#
# gcloud compute scp  --recurse ${rootFolder}/heper_scripts/$version ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/$version/update-$version-$ENV.sh $ENV $region $projectId $HC_VAULT_ROOT $version"
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/$version"


#Upgrade TM from 2.8.10 to 3.3.3.3
version="4.2.1"

gcloud compute scp  --recurse ${rootFolder}/heper_scripts/$version ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/$version/update-$version-$ENV.sh $ENV $region $projectId $HC_VAULT_ROOT $version"
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/$version"
