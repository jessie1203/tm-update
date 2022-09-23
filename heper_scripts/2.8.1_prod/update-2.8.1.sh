#!/bin/sh

ENV=$1
CLUSTER_NAME="prod-vault-cluster"
REGION=$2
PROJECT=$3

echo "Getting caas-cluster credentials"

gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT --internal-ip


if [ $? -eq 0 ]; then
	#sudo yum remove wal2json_12.x86_64
        echo "Deleting old version of vault-installer."
	kubectl delete -n mybank-dev pod vault-installer
else
	echo "vault-installer is not installed."
fi

#Backup configmap vault-admin-website-config
kubectl get configmap  -n tm-deploy-ns vault-admin-website-config -o=yaml > ~/2.8.1_prod/vault-admin-website-config-back.yaml

echo "Updating values.yaml"
#TODO: vault-admin-website-config certificate is wrong after upgrade check this code if it cause it
sed -ie "s/\${SAML_CERT}/$( kubectl get configmap  -n tm-deploy-ns vault-admin-website-config -o=jsonpath='{.data.*}' | jq .SAML_IDP_x509_CERT | sed 's/\//\\\//g' )/g" ~/2.8.1_prod/values.yaml

echo "Installing vault installer 2.8.1_prod"
kubectl apply -n mybank-dev -f ~/2.8.1_prod/vault-installer-cluster-role.yaml
kubectl apply -n mybank-dev -f ~/2.8.1_prod/vault-installer-cluster-role-binding.yaml
kubectl apply -n mybank-dev -f ~/2.8.1_prod/vault_installer.yaml

TM_VAULT_INSTALLER_POD_STATUS=$( kubectl get pods vault-installer --namespace=mybank-dev -o custom-columns=":status.phase" |  tr -d '\n' )
while [ "$TM_VAULT_INSTALLER_POD_STATUS" != "Running" ]
do
        echo "Waiting for 10 seconds before it checking vault-installer stauts."
        sleep 10
        TM_VAULT_INSTALLER_POD_STATUS=$( kubectl get pods vault-installer --namespace=mybank-dev -o custom-columns=":status.phase" |  tr -d '\n' )
done

echo "Preparing vault installer for upgrade"
kubectl cp -n mybank-dev ~/2.8.1_prod/values.yaml vault-installer:/release-artifacts/config-templates/
kubectl cp -n mybank-dev ~/2.8.1_prod/packages.txt vault-installer:/release-artifacts/packages.txt

echo "Delete old ingress configuration"
kubectl delete ingress -n tm-deploy-ns vault-ingress

echo "Running Dry run TM upgrade."
kubectl exec -it -n mybank-dev vault-installer -- /deployment-tools/install-vault --component vault --dry_run


echo "Installing TM Webhook component."
kubectl exec -it -n mybank-dev vault-installer -- /deployment-tools/install-vault --component webhook-operator

echo "Upgrading TM Vault"
kubectl exec -it -n mybank-dev vault-installer -- /deployment-tools/install-vault --component vault

kubectl exec -it -n mybank-dev vault-installer -- /deployment-tools/install-vault --garbage_collect

kubectl exec -it -n mybank-dev vault-installer --  health_check --namespace tm-deploy-ns
#
echo "Check TM version"
kubectl get configmap -n tm-deploy-ns vault-version -o=yaml
