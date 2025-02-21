output ingress_hostname {
  description = "The ingress of the k8s service"
  value       = data.kubernetes_service.backend_service_ingress.status.0.load_balancer.0.ingress.0.hostname
}