#!/usr/bin/env bash
set -euo pipefail

echo "Validating Crossplane manifests"

if command -v kubeconform >/dev/null 2>&1; then
  kubeconform -summary -ignore-missing-schemas crossplane
else
  echo "kubeconform not found; skipping Kubernetes schema validation"
  echo "Install kubeconform for offline CRD-aware validation without a live cluster"
fi

echo "Crossplane validation completed"
