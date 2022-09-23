# Required for vault installer to manage internal secrets and certs used by Thought Machine Vault
path "secret/prod/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Required by Observability packages installer
path "secret/monitoring/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Required for the vault installer to determine whether it has a valid HashiCorp Vault access token
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Optional: allows vault installer to automatically create policies for services in HashiCorp Vault
path "sys/policy/*" {
  capabilities = ["create", "read", "update", "delete"]
}

# Optional: allows vault installer to automatically create policies for services in HashiCorp Vault
path "auth/kubernetes/role/*"{
  capabilities = ["create", "read", "update", "delete"]
}

# Optional: Only required when using the PKI engine to sign certificates
path "{PATH_TO_KAFKA_PKI}/ca*" {
    capabilities = ["read"]
}
path "{PATH_TO_KAFKA_PKI}/sign/vault-installer" {
    capabilities = ["read","update"]
}

# Optional: Only required when using the PKI engine and you intend to use the installer pod's CA rotation tool to replace a self-signed CA cert.
path "{PATH_TO_KAFKA_PKI}/root" {
    capabilities = ["delete","sudo"]
}
path "{PATH_TO_KAFKA_PKI}/root/generate/internal" {
    capabilities = ["update"]
}

# Optional: Only required when using the PKI engine to sign certificates
path "{PATH_TO_COCKROACHDB_PKI}/ca*" {
    capabilities = ["read"]
}
path "{PATH_TO_COCKROACHDB_PKI}/sign/vault-installer" {
    capabilities = ["read","update"]
}

# Optional: Only required when using the PKI engine and you intend to use the installer pod's CA rotation tool to replace a self-signed CA cert.
path "{PATH_TO_COCKROACHDB_PKI}/root" {
    capabilities = ["delete","sudo"]
}
path "{PATH_TO_COCKROACHDB_PKI}/root/generate/internal" {
    capabilities = ["update"]
}
