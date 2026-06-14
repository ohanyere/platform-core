# GitOps

Argo CD bootstraps through an app-of-apps pattern.

`gitops/argocd/bootstrap/root-app.yaml` is the only file an operator should apply manually after confirming the repository URL. It points Argo CD at this repository.

`gitops/argocd/app-of-apps.yaml` recursively loads platform GitOps resources. AppProjects constrain which repositories and namespaces platform and team applications may target.

Team projects are intentionally namespace-scoped. Platform projects can manage cluster-scoped resources needed for shared controls.
