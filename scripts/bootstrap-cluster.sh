#!/usr/bin/env bash
set -euo pipefail

echo "platform-core bootstrap starter"
echo "This script checks prerequisites and prints the safe bootstrap order."

required=(kubectl helm)
for cli in "${required[@]}"; do
  if ! command -v "$cli" >/dev/null 2>&1; then
    echo "Missing required CLI: $cli"
    exit 1
  fi
done

echo "Prerequisites found."
echo "Suggested order:"
echo "1. Install Argo CD using scripts/install-argocd.sh"
echo "2. Apply gitops/argocd/bootstrap/root-app.yaml after confirming the repository URL"
echo "3. Sync platform projects and policies through Argo CD"
echo "No cluster mutations were performed by this starter script."
