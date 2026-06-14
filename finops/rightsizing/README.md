# Rightsizing Recommendations

Rightsizing recommendations should be reviewed by the owning service team before changes are applied.

Use Kubecost, Prometheus, and incident history together. A low observed CPU value is not enough to lower requests for latency-sensitive services without understanding traffic seasonality and failover behavior.

Recommended workflow:

1. Generate a recommendation for a workload and namespace.
2. Attach seven to thirty days of utilization evidence.
3. Open a pull request in the service repository.
4. Let policy checks and rollout analysis validate the change.

