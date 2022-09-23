#!/bin/sh

ENV=$1
CLUSTER_NAME="$ENV-vault-cluster"
REGION=$2
PROJECT=$3
HC_VAULT_ROOT=$4
VERSION=$5
echo $HC_VAULT_ROOT


echo "Getting caas-cluster credentials"
mv ~/${VERSION}/values-prod.yaml ~/${VERSION}/values.yaml

echo "Getting caas-cluster credentials"

gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT --internal-ip

#Update TM-vault priority
echo "Updating priority classes."
kubectl apply -n tm-deploy-ns -f ~/${VERSION}/priority-classes.yaml

echo "Updating vault-sa service account."
kubectl apply -n tm-deploy-ns -f ~/${VERSION}/vault-installer-cluster-role.yaml

kubectl get -n tm-deploy-ns pod vault-installer

if [ $? -eq 0 ]; then
	#sudo yum remove wal2json_12.x86_64
  echo "Deleting old version of vault-installer."
	kubectl delete -n tm-deploy-ns pod vault-installer
else
	echo "vault-installer is not installed."
fi

#Backup configmap vault-admin-website-config-vault-operations-package-389d24ef4c
kubectl get configmap  -n tm-deploy-ns vault-admin-website-config-vault-operations-package-389d24ef4c -o=yaml > ~/${VERSION}/vault-admin-website-config-vault-operations-package-389d24ef4c-back.yaml

echo "Updating values.yaml"

#TODO: vault-admin-website-config-vault-operations-package-389d24ef4c certificate is wrong after upgrade check this code if it cause it
sed -ie "s/\${SAML_CERT}/$( kubectl get configmap  -n tm-deploy-ns vault-admin-website-config-vault-operations-package-389d24ef4c -o=jsonpath='{.data.*}' | jq .SAML_IDP_x509_CERT | sed 's/\//\\\//g' )/g" ~/${VERSION}/values.yaml

echo "Installing vault installer $VERSION"
kubectl apply -n tm-deploy-ns -f ~/$VERSION/vault_installer.yaml

TM_VAULT_INSTALLER_POD_STATUS=$( kubectl get pods vault-installer --namespace=tm-deploy-ns -o custom-columns=":status.phase" |  tr -d '\n' )
while [ "$TM_VAULT_INSTALLER_POD_STATUS" != "Running" ]
do
        echo "Waiting for 10 seconds before it checking vault-installer stauts."
        sleep 10
        TM_VAULT_INSTALLER_POD_STATUS=$( kubectl get pods vault-installer --namespace=tm-deploy-ns -o custom-columns=":status.phase" |  tr -d '\n' )
done

echo "Preparing vault installer for upgrade"
kubectl cp -n tm-deploy-ns ~/$VERSION/values.yaml vault-installer:/release-artifacts/config-templates/
kubectl cp -n tm-deploy-ns ~/$VERSION/packages.txt vault-installer:/release-artifacts/packages.txt

#ISTIO deployments


echo "Creating service account and role-binding for ISTIO."
kubectl apply -n tm-deploy-ns -f ~/$VERSION/install-istio-cluster-role.yaml


echo "Deploying new version of ISTIO."
kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/install-vault --component istio

echo "Post-deploying for new version ISTIO."
echo "Restarting istio pods."
kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/restart-pods --namespace istio-system

echo "Running Dry run TM upgrade."
kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/install-vault --component vault --dry_run

echo "Deploying webhook-operator."
kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/install-vault --component webhook-operator


echo "Upgrading TM Vault"

kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/install-vault --component vault


echo "Enabling istio ."
kubectl label ns tm-deploy-ns --overwrite istio-annotation-tm-webhook-tm-deploy-ns=enabled

#Enable Istio injection for the Vault namespace
kubectl label ns tm-deploy-ns --overwrite istio.io/rev-
kubectl label ns tm-deploy-ns --overwrite istio-injection-

kubectl label ns tm-deploy-ns --overwrite istio.io/rev=canary-v1-14

echo "Restart all tm-vault pods."
kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/restart-pods --selector "project notin (kafka)"

# delete the cluster role and cluster role binding that were deployed

echo "Check TM version"
kubectl get configmap -n tm-deploy-ns vault-version -o=yaml
