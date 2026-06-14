package images

test_denies_latest_tag {
  deny[_] with input as {
    "kind": "Deployment",
    "metadata": {"name": "api"},
    "spec": {"template": {"spec": {"containers": [{"name": "api", "image": "example/api:latest"}]}}}
  }
}

test_allows_versioned_tag {
  count(deny) == 0 with input as {
    "kind": "Deployment",
    "metadata": {"name": "api"},
    "spec": {"template": {"spec": {"containers": [{"name": "api", "image": "example/api:v1.2.3"}]}}}
  }
}

