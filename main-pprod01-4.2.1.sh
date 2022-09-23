#!/bin/sh

ENV="pprod01"
projectId="caas-delta-pprod01"
clusterZone="asia-southeast2-a"
region="asia-southeast2"


rootFolder="/mnt/c/ICS/tm-upgrade/tools/tm-update"
version="2.8.10"
bastion_gce_instance="pprod01-bastion-host"

#TODO: This variable needs to be from secured
HC_VAULT_ROOT="s.ZmhRRk08rtlfUT7KLjRV8kx0"

#Upgrade TM from 2.8.1 to 2.8.10
# gcloud compute scp  --recurse ${rootFolder}/heper_scripts/$version ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/$version/update-$version.sh $ENV $region $projectId $HC_VAULT_ROOT $version"
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/$version"


# #Upgrade TM from 2.8.10 to 3.3.3.3
# version="3.3.3.3"
#
# cp ${rootFolder}/heper_scripts/$version/values-pprod.yaml ${rootFolder}/heper_scripts/$version/values.yaml
# gcloud compute scp  --recurse ${rootFolder}/heper_scripts/$version ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/$version/update-$version.sh $ENV $region $projectId $HC_VAULT_ROOT $version"
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/$version"
#
#
# #Upgrade TM from 2.8.10 to 3.3.3.3
version="4.2.1"

cp ${rootFolder}/heper_scripts/$version/values-pprod.yaml ${rootFolder}/heper_scripts/$version/values.yaml
gcloud compute scp  --recurse ${rootFolder}/heper_scripts/$version ${bastion_gce_instance}:~  --project ${projectId} --zone ${clusterZone}
gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "sh ~/$version/update-$version.sh $ENV $region $projectId $HC_VAULT_ROOT $version"
# gcloud compute ssh ${bastion_gce_instance} --zone ${clusterZone} --tunnel-through-iap --project ${projectId} -- "rm -rf ~/$version"
