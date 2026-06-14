package labels

required_labels := {
  "app.kubernetes.io/name",
  "app.kubernetes.io/part-of",
  "platform.io/team",
  "platform.io/cost-center",
  "platform.io/environment",
}

deny[msg] {
  input.kind
  missing := required_labels[_]
  not input.metadata.labels[missing]
  msg := sprintf("resource %q is missing label %q", [input.metadata.name, missing])
}

