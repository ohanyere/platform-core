# FinOps

FinOps guardrails depend on consistent labels:

- `platform.io/team`
- `platform.io/cost-center`
- `platform.io/environment`
- `app.kubernetes.io/name`
- `app.kubernetes.io/part-of`

Budget templates define expected monthly spend and alert thresholds. Kubecost values map platform labels into cost ownership fields.

Rightsizing is advisory by default. Recommendations should be attached to service pull requests and reviewed with utilization data, SLOs, and rollout safety checks.

