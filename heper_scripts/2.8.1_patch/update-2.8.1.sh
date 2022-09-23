#!/bin/sh

ENV=$1
CLUSTER_NAME="$1-tm-vault-cluster"
REGION=$2
PROJECT=$3

echo "Getting caas-cluster credentials"

gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT --internal-ip



sed -ie "s/\${env}/$ENV/g" ~/2.8.1_patch/values.yaml

kubectl apply -n ics -f ~/2.8.1_patch/vault_installer.yaml

TM_VAULT_INSTALLER_POD_STATUS=$( kubectl get pods vault-installer --namespace=ics -o custom-columns=":status.phase" |  tr -d '\n' )
while [ "$TM_VAULT_INSTALLER_POD_STATUS" != "Running" ]
do
        echo "Waiting for 10 seconds before it checking vault-installer stauts."
        sleep 10
        TM_VAULT_INSTALLER_POD_STATUS=$( kubectl get pods vault-installer --namespace=ics -o custom-columns=":status.phase" |  tr -d '\n' )
done

echo "Preparing vault installer for upgrade"
kubectl cp -n ics ~/2.8.1_patch/values.yaml vault-installer:/release-artifacts/config-templates/
kubectl cp -n ics ~/2.8.1_patch/packages.txt vault-installer:/release-artifacts/packages.txt

echo "Running Dry run TM upgrade."
kubectl exec -it -n ics vault-installer -- /deployment-tools/install-vault --component vault --dry_run

echo "Installing TM Webhook component."
kubectl exec -it -n ics vault-installer -- /deployment-tools/install-vault --component webhook-operator

echo "Upgrading TM Vault"
kubectl exec -it -n ics vault-installer -- /deployment-tools/install-vault --component vault --excluded_kinds=HorizontalPodAutoscaler
