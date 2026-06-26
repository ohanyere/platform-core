#!/usr/bin/env bash
set -euo pipefail

echo "Validating GitOps manifests"

if command -v kubeconform >/dev/null 2>&1; then
  find gitops progressive-delivery observability security finops \
    -type f \( -name '*.yaml' -o -name '*.yml' \) \
    ! -path 'gitops/fleet/services/*/*.yaml' \
    -print0 | xargs -0 kubeconform -summary -ignore-missing-schemas
else
  echo "kubeconform not found; skipping Kubernetes schema validation"
  echo "Install kubeconform for offline CRD-aware validation without a live cluster"
fi

if command -v python3 >/dev/null 2>&1; then
  find observability/grafana/dashboards -name '*.json' -print0 | xargs -0 -I{} python3 -m json.tool {} >/dev/null
elif command -v jq >/dev/null 2>&1; then
  find observability/grafana/dashboards -name '*.json' -print0 | xargs -0 -I{} jq empty {}
else
  echo "jq and python3 not found; skipping dashboard JSON validation"
fi

echo "GitOps validation completed"
