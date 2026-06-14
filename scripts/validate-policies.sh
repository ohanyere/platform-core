#!/usr/bin/env bash
set -euo pipefail

echo "Validating policy files"

if command -v yamllint >/dev/null 2>&1; then
  yamllint policies/kyverno
else
  echo "yamllint not found; skipping YAML lint"
fi

if command -v conftest >/dev/null 2>&1; then
  conftest verify policies/opa
else
  echo "conftest not found; skipping OPA unit tests"
fi

echo "Policy validation completed"

