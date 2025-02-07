output "deployment_name" {
  value = kubernetes_deployment.this.metadata[0].name
}

output "load_balancer_hostname" {
  value = kubernetes_service.service_status_tracker_load_balancer.status[0].load_balancer[0].ingress[0].hostname
}