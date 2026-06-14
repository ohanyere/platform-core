# Onboarding

To onboard a new service:

1. Generate the service repository from the approved template.
2. Configure workflow calls to `platform-core`.
3. Add required platform and FinOps labels.
4. Add Crossplane claims only for infrastructure the service owns.
5. Add ServiceMonitor and rollout analysis references when the service is ready for production traffic.

To onboard a new team, add an Argo CD AppProject, namespace cost mapping, and budget template.

