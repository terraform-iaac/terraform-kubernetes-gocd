resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      name = var.gocd_namespace
    }
    labels = var.namespace_labels
    name = var.gocd_namespace
  }
}