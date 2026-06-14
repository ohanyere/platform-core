# Policy Reference

Kyverno policies:

- `require-finops-labels.yaml` requires app, team, cost center, and environment labels.
- `block-latest-tags.yaml` blocks `latest` and missing image tags.
- `require-resource-limits.yaml` requires CPU and memory requests and limits.
- `require-readonly-rootfs.yaml` requires read-only root filesystems.
- `require-non-root-user.yaml` requires non-root execution.
- `disallow-privileged-containers.yaml` blocks privileged containers.
- `require-network-policy.yaml` audits namespaces without NetworkPolicy.
- `require-probes.yaml` requires readiness and liveness probes.
- `validate-crossplane-claims.yaml` requires ownership labels on platform claims.

OPA policies:

- `no-latest-tag.rego` catches latest or missing tags in deployment images.
- `require-labels.rego` checks required platform labels.
- `disallow-privileged.rego` catches privileged deployment containers.

