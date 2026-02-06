package kubernetes

required_labels := {"app.kubernetes.io/name", "app.kubernetes.io/part-of", "owner", "compliance"}

deny[msg] {
  obj := input
  kind := object.get(obj, "kind", "")
  kind != ""
  labels := object.get(object.get(obj, "metadata", {}), "labels", {})
  missing := required_labels - object.keys(labels)
  count(missing) > 0
  name := object.get(object.get(obj, "metadata", {}), "name", "unknown")
  msg := sprintf("%s/%s is missing required labels: %v", [kind, name, missing])
}

# Check for resource limits on containers
deny[msg] {
  obj := input
  obj.kind == "Deployment"
  container := obj.spec.template.spec.containers[_]
  not container.resources.limits
  msg := sprintf("Deployment/%s: container '%s' must define resource limits", [obj.metadata.name, container.name])
}

deny[msg] {
  obj := input
  obj.kind == "Deployment"
  container := obj.spec.template.spec.containers[_]
  not container.resources.requests
  msg := sprintf("Deployment/%s: container '%s' must define resource requests", [obj.metadata.name, container.name])
}

# Check for security context
deny[msg] {
  obj := input
  obj.kind == "Deployment"
  container := obj.spec.template.spec.containers[_]
  not container.securityContext
  msg := sprintf("Deployment/%s: container '%s' must define securityContext", [obj.metadata.name, container.name])
}

deny[msg] {
  obj := input
  obj.kind == "Deployment"
  container := obj.spec.template.spec.containers[_]
  container.securityContext.privileged == true
  msg := sprintf("Deployment/%s: container '%s' must not run in privileged mode", [obj.metadata.name, container.name])
}

deny[msg] {
  obj := input
  obj.kind == "Deployment"
  container := obj.spec.template.spec.containers[_]
  sc := object.get(container, "securityContext", {})
  readOnly := object.get(sc, "readOnlyRootFilesystem", false)
  readOnly != true
  msg := sprintf("Deployment/%s: container '%s' should use read-only root filesystem", [obj.metadata.name, container.name])
}

# Check for liveness and readiness probes
deny[msg] {
  obj := input
  obj.kind == "Deployment"
  container := obj.spec.template.spec.containers[_]
  not container.livenessProbe
  msg := sprintf("Deployment/%s: container '%s' should define a livenessProbe", [obj.metadata.name, container.name])
}

deny[msg] {
  obj := input
  obj.kind == "Deployment"
  container := obj.spec.template.spec.containers[_]
  not container.readinessProbe
  msg := sprintf("Deployment/%s: container '%s' should define a readinessProbe", [obj.metadata.name, container.name])
}
