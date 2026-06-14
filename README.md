# platform-core

`platform-core` is the central platform engineering repository for reusable Internal Developer Platform standards. It is not an application service. It holds CI workflows, policy-as-code, Crossplane abstractions, GitOps bootstrap manifests, mesh defaults, progressive delivery checks, observability defaults, security defaults, FinOps guardrails, and runbooks.

Generated service repositories consume this repository instead of copying platform logic. A generated service should call reusable workflows from `.github/workflows`, render service-specific manifests from its own repo, and rely on the policies here to validate that the service remains deployable, observable, secure, and cost-attributable.

## How Service Repos Use It

Service repositories call reusable workflows by reference:

```yaml
jobs:
  build:
    uses: ohanyere/platform-core/.github/workflows/reusable-build-sign.yaml@main
    with:
      service_name: payments-api
      dockerhub_namespace: ohanyere
      image_tag: ${{ github.sha }}
      dockerfile_path: Dockerfile
      context_path: .
    secrets: inherit
```

The reusable build workflow builds and pushes an image, then signs it with Cosign. Keyless signing is the preferred path. A secret-backed Cosign key is documented as a fallback for environments that cannot use OIDC yet.

## Policy Validation

Kyverno policies under `policies/kyverno` are intended for admission control in platform clusters. OPA policies under `policies/opa` are intended for PR validation through conftest. Together they check standard labels, image tag hygiene, privileged mode, resource defaults, security context expectations, probes, NetworkPolicy posture, and Crossplane claim ownership metadata.

## Crossplane Claims

Crossplane XRDs define portable platform APIs for PostgreSQL, S3, SQS, Redis, and DynamoDB. Service teams request infrastructure by creating claims in their own namespaces. Compositions map those claims to AWS managed resources through a generic `ProviderConfig`. This repo does not include real AWS credentials and examples are not active by default.

## GitOps Bootstrap

Argo CD starts from `gitops/argocd/bootstrap/root-app.yaml`, which points at the app-of-apps definition. AppProjects restrict platform and team deployments to expected repositories and namespaces.

## FinOps Guardrails

FinOps defaults require cost allocation labels, map namespaces to teams and cost centers, provide budget templates, and include Kubecost configuration. Admission policies and PR checks make cost ownership visible before workloads land in a cluster.

## Validation

Run:

```bash
make validate
make validate-policies
make validate-crossplane
make validate-gitops
```

Validation is designed to work without a live Kubernetes cluster. Extra checks run when optional CLIs such as `kubeconform`, `conftest`, `yamllint`, and `jq` are available.
