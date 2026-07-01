# Crossplane

XRDs define the platform-facing APIs:

- `PostgreSQLInstance`
- `ObjectBucket`
- `MessageQueue`
- `RedisInstance`
- `DynamoDBTable`

Compositions map those APIs to AWS resources using Upbound AWS provider kinds. The included `ProviderConfig` is configured for AWS IAM Roles for Service Accounts. For other environments, configure credentials through GitHub Actions OIDC, External Secrets, Vault, or Kubernetes secrets managed outside Git.

Claims in `crossplane/examples` are examples only. Service teams copy a claim into their service repo, set labels and parameters, and let Argo CD apply it through the team namespace.

## GitOps wiring

`gitops/bootstrap/platform/crossplane.yaml` installs Crossplane, the required Upbound AWS provider packages, and the existing platform definitions without duplicating the XRDs, compositions, or provider configs.

The bootstrap applies:

- `crossplane/providers` for provider packages.
- `crossplane/xrd` for claim APIs.
- `crossplane/compositions` for AWS implementations.
- `crossplane/provider-configs` for provider configuration.

The IDP claim flow is:

Developer -> IDP -> Claim -> Crossplane -> Composition -> Managed Resource

The IDP should create the claim in the service repository overlay that Argo CD already syncs. Crossplane then reconciles the claim by using the referenced composition and `ProviderConfig`.

The AWS `ProviderConfig` uses IRSA, so the live cluster must provide the matching AWS IAM role binding for provider pods. This repository wires the package and config path; it does not contain AWS account credentials.
