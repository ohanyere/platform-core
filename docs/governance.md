# Governance

## Kyverno installation

Kyverno is installed once by GitOps through `gitops/bootstrap/platform/kyverno.yaml`.

The bootstrap defines two Argo CD Applications:

- `platform-kyverno` installs the Kyverno Helm chart into the `kyverno` namespace.
- `platform-kyverno-policies` applies the existing policy bundle from `policies/kyverno`.

Do not add a second Kyverno installation or copy these policies into another GitOps path. The app-of-apps root at `gitops/argocd/app-of-apps.yaml` already discovers the platform bootstrap manifests from the `gitops` tree.

## Applied policies

The current policy bundle is:

- `block-latest-image-tags`
- `disallow-privileged-containers`
- `require-platform-finops-labels`
- `require-namespace-network-policy`
- `require-non-root-user`
- `require-container-probes`
- `require-readonly-root-filesystem`
- `require-resource-requests-limits`
- `validate-crossplane-claim-labels`
- `verify-platform-image-signatures`

Most policies use `validationFailureAction: Enforce` for admission control. `require-namespace-network-policy` uses `validationFailureAction: Audit`, which makes it safe for reporting verification because the test resource is admitted and then reported as non-compliant.

## PolicyReport CRDs

Kyverno reports are exposed through Kubernetes custom resources:

- `PolicyReport` for namespaced resources.
- `ClusterPolicyReport` for cluster-scoped resources.

Verify the CRDs after the Kyverno Application is synced:

```bash
kubectl get crd policyreports.wgpolicyk8s.io clusterpolicyreports.wgpolicyk8s.io
```

## Verification commands

Run these commands in a live cluster after Argo CD has synced `platform-kyverno` and `platform-kyverno-policies`:

```bash
kubectl get clusterpolicies
kubectl get policyreports -A
kubectl get clusterpolicyreports
```

The expected result is:

- `kubectl get clusterpolicies` lists the policies from `policies/kyverno`.
- `kubectl get policyreports -A` lists namespaced report objects for matched namespaced resources.
- `kubectl get clusterpolicyreports` lists cluster-scoped report objects for matched cluster resources such as Namespaces.

## Safe reporting smoke test

`docs/examples/kyverno-policyreport-namespace-violation.yaml` creates a labeled temporary namespace without a NetworkPolicy. It passes the required label policy, is not managed by GitOps, and should violate only the Audit-mode `require-namespace-network-policy` policy.

Apply the fixture:

```bash
kubectl apply -f docs/examples/kyverno-policyreport-namespace-violation.yaml
```

Wait for Kyverno reporting to process the admission event or background scan, then inspect reports:

```bash
kubectl get clusterpolicyreports -o wide
kubectl get clusterpolicyreports -o yaml
```

Look for a result like:

```yaml
policy: require-namespace-network-policy
rule: namespace-has-network-policy
result: fail
source: kyverno
```

Clean up the smoke namespace after verification:

```bash
kubectl delete namespace platform-policy-report-smoke
```

## IDP violation reads

The IDP should read Kyverno violations through the Kubernetes API using read-only access to `policyreports.wgpolicyk8s.io` and `clusterpolicyreports.wgpolicyk8s.io`.

The read model should:

- List `PolicyReport` objects across namespaces.
- List `ClusterPolicyReport` objects cluster-wide.
- Read each report `results[]` entry where `result` is `fail`, `warn`, or `error`.
- Map namespaced results to services by `scope.namespace`, resource labels, or the Argo CD Application namespace.
- Map cluster-scoped results by `scope.kind`, `scope.name`, and any platform labels on the scoped object.
- Surface `policy`, `rule`, `message`, `severity`, `category`, `source`, and `timestamp` as the violation details.

Policy reports represent current cluster state. The IDP should not treat them as an audit log. When an Enforce-mode policy blocks a resource at admission, the IDP should also read Kubernetes Events and Kyverno metrics if it needs rejected-write history.
