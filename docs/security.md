# Security

Vault files provide a starter configuration and Kubernetes auth setup example. The auth job is an example only and should be reviewed before use.

Vault policies separate service read access from platform administration. Service policies are scoped by Kubernetes identity metadata.

External Secrets templates connect Kubernetes secrets to Vault through a `ClusterSecretStore`. Service teams should reference secret paths owned by their namespace and service name.

## Supply chain enforcement

Generated service repositories use the platform reusable workflows for image scanning and signing:

Developer -> Git Push -> GitHub Actions -> Trivy -> Cosign -> GitOps -> Kyverno -> Cluster

`reusable-scan.yaml` runs Trivy filesystem and image scans and fails on critical image vulnerabilities. `reusable-build-sign.yaml` builds, pushes, and signs Docker images with Cosign. Keyless GitHub Actions signing is the primary path; the private-key fallback remains available for environments that cannot use OIDC.

Kyverno is installed by `gitops/bootstrap/platform/kyverno.yaml`. The existing policies under `policies/kyverno` are applied by GitOps, including `verify-signed-images.yaml`, which verifies Cosign keyless signatures for platform-owned Docker Hub images before Pods are admitted.

Cosign stores signatures in the image registry as OCI signature artifacts associated with the signed image reference. Kyverno verifies those signatures at admission using Sigstore Rekor and the GitHub Actions OIDC issuer.
