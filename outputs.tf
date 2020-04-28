output "urls" {
  value = module.ingress.urls
}
output "namespace" {
  value = kubernetes_namespace.namespace.id
}