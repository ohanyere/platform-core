# Crossplane

XRDs define the platform-facing APIs:

- `PostgreSQLInstance`
- `ObjectBucket`
- `MessageQueue`
- `RedisInstance`
- `DynamoDBTable`

Compositions map those APIs to AWS resources using Upbound AWS provider kinds. The included `ProviderConfig` is configured for AWS IAM Roles for Service Accounts. For other environments, configure credentials through GitHub Actions OIDC, External Secrets, Vault, or Kubernetes secrets managed outside Git.

Claims in `crossplane/examples` are examples only. Service teams copy a claim into their service repo, set labels and parameters, and let Argo CD apply it through the team namespace.
