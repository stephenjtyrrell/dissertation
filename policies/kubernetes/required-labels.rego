package kubernetes

required_labels := {"app.kubernetes.io/name", "app.kubernetes.io/part-of", "owner", "compliance"}

deny contains msg if {
  obj := input
  kind := object.get(obj, "kind", "")
  kind != ""
  labels := object.get(object.get(obj, "metadata", {}), "labels", {})
  missing := required_labels - object.keys(labels)
  count(missing) > 0
  name := object.get(object.get(obj, "metadata", {}), "name", "unknown")
  msg := sprintf("%s/%s is missing required labels: %v", [kind, name, missing])
}
