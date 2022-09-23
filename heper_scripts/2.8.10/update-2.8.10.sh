#!/bin/sh

ENV=$1
CLUSTER_NAME="$ENV-tm-vault-cluster"
REGION=$2
PROJECT=$3
HC_VAULT_ROOT=$4
VERSION=$5
echo $HC_VAULT_ROOT

echo "Getting caas-cluster credentials"

gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT

#Update TM-vault priority
echo "Updating priority classes."
kubectl apply -n tm-deploy-ns -f ~/${VERSION}/priority-classes.yaml

echo "Updating vault-sa service account."
#Update vault_installer service account
kubectl apply -n tm-deploy-ns -f ~/${VERSION}/vault-installer-service-account.yaml
kubectl apply -n tm-deploy-ns -f ~/${VERSION}/vault-installer-cluster-role.yaml
kubectl apply -n tm-deploy-ns -f ~/${VERSION}/vault-installer-cluster-role-binding.yaml

kubectl get -n tm-deploy-ns pod vault-installer

if [ $? -eq 0 ]; then
	#sudo yum remove wal2json_12.x86_64
  echo "Deleting old version of vault-installer."
	kubectl delete -n tm-deploy-ns pod vault-installer
else
	echo "vault-installer is not installed."
fi

#Backup configmap vault-admin-website-config
kubectl get configmap  -n tm-deploy-ns vault-admin-website-config -o=yaml > ~/${VERSION}/vault-admin-website-config-back.yaml

echo "Updating values.yaml"

sed -ie "s/\${env}/${ENV}/g" ~/$VERSION/values.yaml
#TODO: vault-admin-website-config certificate is wrong after upgrade check this code if it cause it
sed -ie "s/\${SAML_CERT}/$( kubectl get configmap  -n tm-deploy-ns vault-admin-website-config -o=jsonpath='{.data.*}' | jq .SAML_IDP_x509_CERT | sed 's/\//\\\//g' )/g" ~/${VERSION}/values.yaml

#echo "Updating Hashicorp Vault."
#kubectl exec --stdin --tty vault-0 --namespace=hashicorp-ns -- vault login ${HC_VAULT_ROOT}
#kubectl exec --stdin --tty vault-0 --namespace=hashicorp-ns -- vault kv put secret/myprefix/root-db-secrets tm-vault.$ENV.db.internal.icsapi.com=tmvault123


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
kubectl apply -n tm-deploy-ns -f ~/$VERSION/install-istio-service-account.yaml
kubectl apply -n tm-deploy-ns -f ~/$VERSION/install-istio-cluster-role.yaml
kubectl apply -n tm-deploy-ns -f ~/$VERSION/install-istio-cluster-role-binding.yaml

echo "Deleting old ISTIO version."
kubectl delete namespaces istio-system

echo "Creating new ISTIO namespace."
kubectl create namespace istio-system

echo "Deploying new version of ISTIO."
kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/install-vault --component istio --excluded_kinds=HorizontalPodAutoscaler

echo "Post-deploying for new version ISTIO."
echo "Restarting istio pods."
kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/restart-pods --namespace istio-system

echo "Running Dry run TM upgrade."
kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/install-vault --component vault --dry_run

echo "Deploying webhook-operator."
kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/install-vault --component webhook-operator


echo "Upgrading TM Vault"
#kubectl cp -n hashicorp-ns ${VERSION}/vault-installer-hashicorp-vault-policy.hcl vault-0:/tmp
#kubectl exec --stdin --tty vault-0 --namespace=hashicorp-ns -- vault policy write vault-acl /tmp/vault-installer-hashicorp-vault-policy.hcl
#kubectl exec --stdin --tty vault-0 --namespace=hashicorp-ns -- vault write auth/kubernetes/role/vault-sa bound_service_account_names=vault-sa bound_service_account_namespaces=tm-deploy-ns policies=vault-acl

kubectl exec -it -n tm-deploy-ns vault-installer -- /deployment-tools/install-vault --component vault   --excluded_kinds=HorizontalPodAutoscaler

echo "Check TM version"
kubectl get configmap -n tm-deploy-ns vault-version -o=yaml
