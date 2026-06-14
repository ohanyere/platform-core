# Progressive Delivery

Argo Rollouts AnalysisTemplates define reusable canary checks:

- Error rate stays below 2 percent.
- P95 latency stays below 500ms.
- Success rate stays above 99 percent.
- HTTP 5xx request rate remains low.

Service rollouts pass `service-name` and `namespace` arguments. Prometheus metric names may need adaptation to match each service mesh or instrumentation standard.

