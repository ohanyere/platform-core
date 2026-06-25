# GitOps

Argo CD bootstraps through an app-of-apps pattern.

`gitops/argocd/bootstrap/root-app.yaml` is the only file an operator should apply manually after confirming the repository URL. It points Argo CD at this repository.

`gitops/argocd/app-of-apps.yaml` recursively loads platform GitOps resources. AppProjects constrain which repositories and namespaces platform and team applications may target.

Team projects are intentionally namespace-scoped. Platform projects can manage cluster-scoped resources needed for shared controls.

## IDP-managed service fleet

`gitops/argocd/applicationsets/idp-managed-services.yaml` defines the fleet pattern for services managed by the internal developer platform. The ApplicationSet uses the GitHub SCM provider to scan the `ohanyere` GitHub organization, selects repositories with the `idp-managed-service` topic, and generates environment-specific Argo CD Applications from each service repository.

Each tagged repository can publish any workload shape, including APIs, workers, and frontends. The only required GitOps contract is that the repository contains the overlay for the environment it wants Argo CD to manage:

- `k8s/overlays/dev` creates `<repo>-dev` in namespace `<repo>-dev`
- `k8s/overlays/stage` creates `<repo>-stage` in namespace `<repo>-stage`
- `k8s/overlays/prod` creates `<repo>-prod` in namespace `<repo>-prod`

Development sync is automated with prune and self-heal enabled so platform-managed changes land quickly. Stage and production are generated with namespace creation enabled, but sync remains manual to keep promotion explicit.

The ApplicationSet controller needs a GitHub token in the `argocd` namespace:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: github-scm-provider
  namespace: argocd
stringData:
  token: <github-token>
```

The token only needs read access to repository metadata and contents for the managed organization. GitHub repository topics are used for `labelMatch`, so adding or removing the `idp-managed-service` topic controls fleet membership.
