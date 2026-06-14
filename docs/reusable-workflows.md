# Reusable Workflows

Generated service repositories should call workflows in this repository with `workflow_call`.

Example build and sign usage:

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

`reusable-scan.yaml` runs Trivy filesystem and image scans, uploads SARIF when GitHub code scanning is enabled, and fails on critical image vulnerabilities.

`reusable-policy-check.yaml` validates Kubernetes manifests with kubeconform and applies OPA policy checks with conftest.

`reusable-release.yaml` publishes an archive release for platform bundles or generated artifacts.
