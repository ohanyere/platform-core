# Security

Vault files provide a starter configuration and Kubernetes auth setup example. The auth job is an example only and should be reviewed before use.

Vault policies separate service read access from platform administration. Service policies are scoped by Kubernetes identity metadata.

External Secrets templates connect Kubernetes secrets to Vault through a `ClusterSecretStore`. Service teams should reference secret paths owned by their namespace and service name.

