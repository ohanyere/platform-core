# Repository Structure

`.github/workflows` contains reusable CI workflows and repository PR validation.

`policies` contains Kyverno admission policies and OPA policies for conftest.

`crossplane` contains XRDs, AWS compositions, provider configuration examples, and inactive claim examples.

`gitops` contains Argo CD bootstrap manifests, AppProjects, ApplicationSets, the IDP service fleet registry, Istio defaults, and cert-manager defaults.

`progressive-delivery` contains Argo Rollouts AnalysisTemplates backed by Prometheus queries.

`observability` contains Prometheus rules, ServiceMonitor templates, Loki and Promtail values, and Grafana dashboard skeletons.

`security` contains Vault configuration examples, Vault policies, and External Secrets templates.

`finops` contains cost allocation labels, budget templates, Kubecost defaults, and rightsizing guidance.

`charts` contains a small Helm chart shell for teams that want to package platform metadata.

`scripts` contains safe validation and bootstrap helper scripts.

`docs` contains architecture notes, references, onboarding, and runbooks.
