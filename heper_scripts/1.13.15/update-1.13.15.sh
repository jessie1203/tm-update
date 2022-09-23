#!/bin/sh

ENV=$1
CLUSTER_NAME="$1-tm-vault-cluster"
REGION=$2
PROJECT=$3
HC_VAULT_ROOT=$4

echo $HC_VAULT_ROOT

echo "Getting caas-cluster credentials"

gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT

kubectl get -n ics pod vault-installer

if [ $? -eq 0 ]; then
	#sudo yum remove wal2json_12.x86_64
  echo "Deleting old version of vault-installer."
	kubectl delete -n ics pod vault-installer
else
	echo "vault-installer is not installed."
fi

#Backup configmap vault-admin-website-config
kubectl get configmap  -n tm-deploy-ns vault-admin-website-config -o=yaml > ~/1.13.15/vault-admin-website-config-back.yaml

echo "Updating values.yaml"

sed -ie "s/\${env}/${ENV}/g" ~/1.13.15/values.yaml
#TODO: vault-admin-website-config certificate is wrong after upgrade check this code if it cause it
sed -ie "s/\${SAML_CERT}/$( kubectl get configmap  -n tm-deploy-ns vault-admin-website-config -o=jsonpath='{.data.*}' | jq .SAML_IDP_x509_CERT | sed 's/\//\\\//g' )/g" ~/1.13.15/values.yaml

echo "Updating Hashicorp Vault."
kubectl exec --stdin --tty vault-0 --namespace=hashicorp-ns -- vault login ${HC_VAULT_ROOT}
kubectl exec --stdin --tty vault-0 --namespace=hashicorp-ns -- vault kv put secret/myprefix/root-db-secrets tm-vault.$ENV.db.internal.icsapi.com=tmvault123


echo "Installing vault installer 1.13.15"
kubectl apply -n ics -f ~/1.13.15/vault_installer.yaml

TM_VAULT_INSTALLER_POD_STATUS=$( kubectl get pods vault-installer --namespace=ics -o custom-columns=":status.phase" |  tr -d '\n' )
while [ "$TM_VAULT_INSTALLER_POD_STATUS" != "Running" ]
do
        echo "Waiting for 10 seconds before it checking vault-installer stauts."
        sleep 10
        TM_VAULT_INSTALLER_POD_STATUS=$( kubectl get pods vault-installer --namespace=ics -o custom-columns=":status.phase" |  tr -d '\n' )
done

echo "Preparing vault installer for upgrade"
kubectl cp -n ics ~/1.13.15/values.yaml vault-installer:/release-artifacts/config-templates/
kubectl cp -n ics ~/1.13.15/packages.txt vault-installer:/release-artifacts/packages.txt

echo "Running Dry run TM upgrade."
kubectl exec -it -n ics vault-installer -- /deployment-tools/install-vault --component vault --dry_run

echo "Upgrading TM Vault"
kubectl exec -it -n ics vault-installer -- /deployment-tools/install-vault --component vault   --excluded_kinds=HorizontalPodAutoscaler

echo "Check TM version"
kubectl get configmap -n tm-deploy-ns vault-version -o=yaml
