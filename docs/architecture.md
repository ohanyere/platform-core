# Architecture

`platform-core` is organized around platform contracts rather than deployable business services.

The repository has three layers:

1. Authoring standards, such as reusable workflows, OPA policies, and templates.
2. Cluster platform standards, such as Kyverno policies, Argo CD bootstrap, Istio defaults, Rollouts analysis, and observability resources.
3. Infrastructure abstractions, such as Crossplane XRDs and AWS compositions.

Service repositories remain responsible for application code and service-specific deployment intent. This repository supplies the paved road those services use.

