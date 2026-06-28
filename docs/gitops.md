# GitOps

Argo CD bootstraps through an app-of-apps pattern.

`gitops/argocd/bootstrap/root-app.yaml` is the only file an operator should apply manually after confirming the repository URL. It points Argo CD at this repository.

`gitops/argocd/app-of-apps.yaml` recursively loads platform GitOps resources. AppProjects constrain which repositories and namespaces platform and team applications may target. Sync-wave annotations keep the bootstrap order deterministic:

- Argo CD is installed first outside this repository bootstrap flow.
- AppProjects sync before dependent Applications.
- Platform controllers sync before fleet ApplicationSets.
- Fleet ApplicationSets create generated service Applications after the shared CRDs exist.

Team projects are intentionally namespace-scoped. Platform projects can manage cluster-scoped resources needed for shared controls.

## Platform controllers

`gitops/bootstrap/platform/argo-rollouts.yaml` installs the platform controllers that generated services depend on:

- `platform-argo-rollouts` installs Argo Rollouts into `platform-rollouts`.
- `platform-istio-base` installs Istio CRDs into `istio-system`.
- `platform-istiod` installs the Istio control plane into `istio-system`.

Generated services use Argo Rollouts resources for progressive delivery and Istio resources such as `VirtualService` and `DestinationRule` for mesh traffic policy. These are platform dependencies, so they are installed before the fleet ApplicationSets generate service Applications. That keeps first sync failures focused on real service issues instead of missing CRDs.

The platform bootstrap does not install an Istio ingress gateway yet. Gateway installation is kept separate from the base mesh dependency because ingress exposure is an environment decision.

## IDP-managed service fleet

`gitops/argocd/applicationsets/idp-managed-services.yaml` defines the fleet pattern for services managed by the internal developer platform. The ApplicationSets use a Git file-based registry in this repository instead of the GitHub SCM provider. This keeps deployment discovery independent from GitHub organization APIs, which matters because `ohanyere` is a personal GitHub account and Argo CD would otherwise call organization endpoints such as `/orgs/ohanyere/repos`.

The fleet registry lives under `gitops/fleet/services/<environment>/`. Each file registers one service for one environment and supplies the values used by the generated Argo CD Application. `platform-core-apps` excludes these registry files from its recursive apply path so Argo CD consumes them through the ApplicationSet Git generator instead of applying them as Kubernetes resources.

```yaml
service: calendar-api
repoURL: https://github.com/ohanyere/calendar-api.git
branch: main
path: k8s/overlays/dev
namespace: calendar-api-dev
```

IDP-created services are registered by adding or updating these files as part of the service provisioning workflow:

- `gitops/fleet/services/dev/<service>.yaml` creates `<service>-dev`
- `gitops/fleet/services/stage/<service>.yaml` creates `<service>-stage`
- `gitops/fleet/services/prod/<service>.yaml` creates `<service>-prod`

Each registered repository can publish any workload shape, including APIs, workers, and frontends. The only required GitOps contract is that the registry entry points at an overlay path that the service repository contains.

Development sync is automated with prune and self-heal enabled so platform-managed changes land quickly after CI updates the dev overlay. Stage sync is automated only after a promotion PR is merged. Production sync is automated only after a production promotion PR is merged.

Developers do not run `kubectl` or manually sync Argo CD for normal service delivery. Argo CD is the reconciler for all environments; GitHub PR approval is the release gate for stage and production.

The `idp-services` AppProject permits generated services to create their managed namespaces while keeping source repositories constrained to `https://github.com/ohanyere/*.git` and destinations constrained to `*-dev`, `*-stage`, and `*-prod`.

GitHub topics remain useful service metadata. The IDP can still apply topics such as `idp-managed-service`, template identifiers, or team labels for search, ownership, and reporting, but topics are not deployment discovery. A service is deployed only when it has a fleet registry file in the appropriate environment directory.
