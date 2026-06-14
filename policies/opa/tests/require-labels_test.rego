package labels

test_denies_missing_labels {
  deny[_] with input as {
    "kind": "Service",
    "metadata": {"name": "api", "labels": {"app.kubernetes.io/name": "api"}}
  }
}

test_allows_required_labels {
  count(deny) == 0 with input as {
    "kind": "Service",
    "metadata": {"name": "api", "labels": {
      "app.kubernetes.io/name": "api",
      "app.kubernetes.io/part-of": "payments",
      "platform.io/team": "payments",
      "platform.io/cost-center": "cc-100",
      "platform.io/environment": "dev"
    }}
  }
}

