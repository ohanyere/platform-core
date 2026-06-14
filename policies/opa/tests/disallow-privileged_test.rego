package security

test_denies_privileged {
  deny[_] with input as {
    "kind": "Deployment",
    "metadata": {"name": "api"},
    "spec": {"template": {"spec": {"containers": [{"name": "api", "image": "example/api:v1", "securityContext": {"privileged": true}}]}}}
  }
}

test_allows_non_privileged {
  count(deny) == 0 with input as {
    "kind": "Deployment",
    "metadata": {"name": "api"},
    "spec": {"template": {"spec": {"containers": [{"name": "api", "image": "example/api:v1", "securityContext": {"privileged": false}}]}}}
  }
}

