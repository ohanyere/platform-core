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

- `crossplane/providers` for provider packages and the shared AWS IRSA `DeploymentRuntimeConfig`.
- `crossplane/xrd` for claim APIs.
- `crossplane/compositions` for AWS implementations.
- `crossplane/provider-configs` for provider configuration.

The IDP claim flow is:

Developer -> IDP -> Claim -> Crossplane -> Composition -> Managed Resource

The IDP should create the claim in the service repository overlay that Argo CD already syncs. Crossplane then reconciles the claim by using the referenced composition and `ProviderConfig`.

## AWS provider readiness

The AWS `ProviderConfig` uses `credentials.source: IRSA`. Provider pods must run with a service account annotated with an IAM role that trusts the EKS cluster OIDC provider.

The readiness pieces in this repo are:

- `crossplane/provider-configs/aws-provider-config.yaml` defines the single `ProviderConfig` named `default`.
- `crossplane/providers/aws-providers.yaml` installs the existing Upbound AWS provider packages and points each one at `runtimeConfigRef.name: aws-irsa`.
- `crossplane/providers/aws-irsa-runtime-config.yaml` applies the `eks.amazonaws.com/role-arn` service account annotation through `DeploymentRuntimeConfig`.
- `terraform/crossplane-aws-irsa` creates the IAM role, trust policy, and provider permissions for the existing AWS-backed compositions.

Before syncing a real cluster, replace the placeholder role ARN in `crossplane/providers/aws-irsa-runtime-config.yaml` with the Terraform `role_arn` output for that AWS account:

```yaml
eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/platform-crossplane-aws-provider
```

The Terraform module needs the cluster OIDC provider values:

```bash
terraform -chdir=terraform/crossplane-aws-irsa init
terraform -chdir=terraform/crossplane-aws-irsa apply \
  -var='cluster_oidc_provider_arn=arn:aws:iam::<account-id>:oidc-provider/<issuer-hostpath>' \
  -var='cluster_oidc_issuer_url=https://<issuer-hostpath>'
terraform -chdir=terraform/crossplane-aws-irsa output role_arn
```

## Smoke test claim

`crossplane/examples/readiness-messagequeue-claim.example.yaml` is a minimal inactive `MessageQueue` claim for provider readiness testing. Copy it into a GitOps-synced service or smoke-test namespace only after the Crossplane providers are healthy and the runtime config contains the real IAM role ARN.

The claim creates one SQS queue through `messagequeue.aws.platform.ohanyere.com` and uses `deletionPolicy: Delete` so a test cleanup can remove the queue.

## Verification commands

Run these after Argo CD syncs the Crossplane bootstrap:

```bash
kubectl get providers
kubectl get providerconfigs
kubectl get claims -A
kubectl -n crossplane-system get deploymentruntimeconfig aws-irsa -o yaml
kubectl -n crossplane-system get serviceaccount -o yaml | grep -A3 'eks.amazonaws.com/role-arn'
kubectl describe messagequeue platform-aws-readiness -n platform-smoke
```

If your kubectl setup exposes claims through a generic resource alias, this also shows the same smoke claim:

```bash
kubectl describe claim platform-aws-readiness -n platform-smoke
```
