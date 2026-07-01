# Platform Capability Audit

Date: 2026-07-01

This audit records what exists in `platform-core` today and how far each capability is wired. It is based on repository inspection only; it does not assume live cluster state.

## Summary

`platform-core` contains real platform building blocks for governance, scanning, signing, Crossplane abstractions, reusable CI, and Argo CD bootstrap. The strongest fully wired surfaces are the reusable GitHub Actions workflows and the Argo CD app-of-apps path under `gitops/`.

The GitOps bootstrap now wires the previously disconnected cluster capabilities. Crossplane, the required AWS provider packages, existing XRDs, existing compositions, existing provider configs, Kyverno, and existing Kyverno policies are installed through Argo CD Applications under `gitops/bootstrap/platform`. Cosign signing is real in CI, and Kyverno now enforces keyless signature verification for platform-owned images.

## Real And Working

### GitHub Actions Reusable Workflows

`.github/workflows/reusable-build-sign.yaml` builds and pushes Docker images, installs Cosign, and signs the pushed image. It supports keyless signing through GitHub OIDC and a secret-backed key fallback through `COSIGN_PRIVATE_KEY`.

`.github/workflows/reusable-scan.yaml` runs Trivy filesystem and image scans, uploads separate SARIF categories for filesystem and image findings, and fails the workflow on critical image vulnerabilities.

`.github/workflows/reusable-policy-check.yaml` installs `kubeconform` and `conftest`, renders Kustomize overlays when `manifest_path/kustomization.yaml` exists, validates manifests, and runs OPA policies from `platform-core/policies/opa`.

`.github/workflows/reusable-release.yaml` publishes archive releases for a supplied artifact name and version.

`.github/workflows/validate-pr.yaml` runs `make validate` on pull requests and pushes to `main`.

### OPA And Conftest Policies

`policies/opa` contains real Rego policies and unit tests:

- `require-labels.rego`
- `no-latest-tag.rego`
- `disallow-privileged.rego`
- `tests/*_test.rego`

The reusable policy-check workflow wires these policies into CI for callers that use `.github/workflows/reusable-policy-check.yaml`.

### Trivy Scanning

Trivy scanning is real in `.github/workflows/reusable-scan.yaml`. It performs filesystem and image scans with `aquasecurity/trivy-action@v0.36.0` and `version: v0.71.2`. SARIF uploads are gated on scan output, and critical image vulnerabilities fail the final scan step.

### Cosign Signing

Cosign signing is real in `.github/workflows/reusable-build-sign.yaml`. The workflow installs Cosign and signs `docker.io/${dockerhub_namespace}/${service_name}:${image_tag}` after the image is pushed.

Cluster verification is enforced by `policies/kyverno/verify-signed-images.yaml` for platform-owned Docker Hub images signed by GitHub Actions keyless Cosign.

### Argo CD Bootstrap

`gitops/argocd/bootstrap/root-app.yaml` defines the root Argo CD `Application`.

`gitops/argocd/app-of-apps.yaml` defines the recursive app-of-apps `Application` for `path: gitops`, excluding `argocd/bootstrap/*` and `fleet/services/*/*.yaml`.

`gitops/argocd/appprojects` contains AppProjects for the platform and teams.

`gitops/bootstrap/platform/argo-rollouts.yaml` bootstraps Argo Rollouts and Istio base/control-plane Helm charts before fleet service ApplicationSets.

`gitops/bootstrap/platform/crossplane.yaml` installs Crossplane, AWS provider packages, and the existing Crossplane definition directories.

`gitops/bootstrap/platform/kyverno.yaml` installs Kyverno and applies the existing Kyverno policy directory.

`gitops/argocd/applicationsets/idp-managed-services.yaml` defines Git-file based ApplicationSets for dev, stage, and prod generated services. The ApplicationSets are automated with prune, self-heal, and `CreateNamespace=true`.

## Exists And Is Now Wired

### Crossplane

The repository contains real Crossplane API definitions:

- `crossplane/xrd/postgresql-claim.yaml`
- `crossplane/xrd/s3-claim.yaml`
- `crossplane/xrd/sqs-claim.yaml`
- `crossplane/xrd/redis-claim.yaml`
- `crossplane/xrd/dynamodb-claim.yaml`

It also contains AWS compositions:

- `crossplane/compositions/postgres-aws.yaml`
- `crossplane/compositions/s3-aws.yaml`
- `crossplane/compositions/sqs-aws.yaml`
- `crossplane/compositions/redis-aws.yaml`
- `crossplane/compositions/dynamodb-aws.yaml`

And one provider config:

- `crossplane/provider-configs/aws-provider-config.yaml`

The `ProviderConfig` is real YAML and uses `credentials.source: IRSA`.

These Crossplane resources are wired by `gitops/bootstrap/platform/crossplane.yaml`. The bootstrap installs Crossplane, applies provider packages from `crossplane/providers`, applies XRDs from `crossplane/xrd`, applies compositions from `crossplane/compositions`, and applies provider configs from `crossplane/provider-configs`.

The remaining environment prerequisite is AWS identity. The included `ProviderConfig` uses IRSA, so the target cluster must provide the matching AWS IAM role binding for provider pods.

### Kyverno Policies

`policies/kyverno` contains real `ClusterPolicy` manifests:

- `block-latest-tags.yaml`
- `disallow-privileged-containers.yaml`
- `require-finops-labels.yaml`
- `require-network-policy.yaml`
- `require-non-root-user.yaml`
- `require-probes.yaml`
- `require-readonly-rootfs.yaml`
- `require-resource-limits.yaml`
- `validate-crossplane-claims.yaml`
- `verify-signed-images.yaml`

Most policies use `validationFailureAction: Enforce`; `require-network-policy.yaml` uses `Audit`.

These policies are installed by `gitops/bootstrap/platform/kyverno.yaml`. The bootstrap installs Kyverno once through the Helm chart and points `platform-kyverno-policies` at the existing `policies/kyverno` directory.

### Platform-Core PR Validation Depth

`make validate` is real and runs policy, Crossplane, GitOps, docs, and shell syntax checks. However, local validation scripts skip deeper checks when optional tools are not present:

- `scripts/validate-policies.sh` skips YAML lint when `yamllint` is missing.
- `scripts/validate-policies.sh` skips OPA unit tests when `conftest` is missing.
- `scripts/validate-crossplane.sh` skips schema validation when `kubeconform` is missing.
- `scripts/validate-gitops.sh` skips schema validation when `kubeconform` is missing.

`validate-pr.yaml` installs `shellcheck` and `jq`, but not `yamllint`, `conftest`, or `kubeconform`. That means platform-core PR validation is structurally wired but may be bounded unless those tools are already available in the runner.

## Mock Or Document-Only

`crossplane/examples/*.example.yaml` are example claims only. They are not active by default and are not applied by the current GitOps bootstrap.

The Crossplane documentation describes how service teams copy claims into service repositories. This repository provides the GitOps and platform-control-plane side of that flow; the Nexus Platform service-creation implementation that writes claim YAML lives outside this repository.

`scripts/bootstrap-cluster.sh` is a bootstrap helper that prints prerequisite checks and safe ordering. It does not install platform components itself.

## Remaining External Prerequisites

The following are not solved by this repository alone:

- A Nexus Platform implementation in this repository that creates Crossplane claim YAML.
- AWS IAM role and IRSA binding for the Upbound AWS provider pods.
- Public-key verification for the optional Cosign private-key fallback. The enforced admission policy covers keyless GitHub Actions signatures.

## Direct Answers

### Can Nexus Platform Create Real Crossplane Claims Today?

Partially.

This repo now installs the platform control-plane side: Crossplane, AWS providers, XRDs, compositions, and provider configs. A separate Nexus Platform automation path still needs to write claim YAML into a GitOps-synced service repository, and the live cluster still needs the AWS IRSA role binding for provider pods.

### Which Resource Types Are Already Supported?

The Crossplane claim types defined under `crossplane/xrd` are:

- `PostgreSQLInstance`, backed by `rds.aws.upbound.io/v1beta1` `Instance`
- `ObjectBucket`, backed by `s3.aws.upbound.io/v1beta1` `Bucket` and `BucketVersioning`
- `MessageQueue`, backed by `sqs.aws.upbound.io/v1beta1` `Queue`
- `RedisInstance`, backed by `elasticache.aws.upbound.io/v1beta1` `Cluster`
- `DynamoDBTable`, backed by `dynamodb.aws.upbound.io/v1beta1` `Table`

### Is Cosign Signing Real In CI?

Yes. `.github/workflows/reusable-build-sign.yaml` installs Cosign and signs the pushed Docker image with either keyless OIDC signing or a configured private-key fallback.

### Is Signature Verification Enforced In Cluster?

Yes for platform-owned Docker Hub images signed by GitHub Actions keyless Cosign. `policies/kyverno/verify-signed-images.yaml` verifies those signatures through Kyverno admission.

### Are Kyverno Policies Installed By GitOps?

Yes. `gitops/bootstrap/platform/kyverno.yaml` installs Kyverno and applies the existing `policies/kyverno` directory.

### Are CI Policy Checks Real?

Yes for service repositories that call `.github/workflows/reusable-policy-check.yaml`. That workflow installs `kubeconform` and `conftest`, renders Kustomize overlays when present, and runs the OPA policy bundle from `platform-core/policies/opa`.

For `platform-core`'s own PR workflow, policy validation is present through `make validate`, but it is bounded by optional tool availability because `validate-pr.yaml` does not install `yamllint`, `conftest`, or `kubeconform`.
