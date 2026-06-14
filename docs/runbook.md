# Runbook

## Policy Failure

Check whether the failing resource has required labels, explicit image tags, resource requests and limits, non-root security context, read-only root filesystem, and probes.

## Crossplane Claim Not Ready

Inspect the claim, composite resource, and managed resource conditions. Confirm that the provider config exists and that cloud credentials are available through the approved identity mechanism.

## Argo CD Sync Failure

Check the Application conditions, AppProject permissions, repository URL, and namespace restrictions.

## Budget Alert

Review Kubecost allocation by namespace, team, and cost center. Open a rightsizing or cleanup issue with the owning team when spend is unexpected.
