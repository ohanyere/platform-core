# Observability

Prometheus rules provide platform-level alerts and service rule templates. ServiceMonitor templates define a standard `/metrics` scrape contract.

Loki and Promtail values provide starter log aggregation defaults. They label logs by namespace and platform team so troubleshooting and cost allocation can share the same metadata vocabulary.

Grafana dashboards are skeletons for platform health, service health, cost, and rollout behavior. They are intentionally small starting points for environment-specific dashboard provisioning.

