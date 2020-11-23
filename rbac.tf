resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = var.server_service_account_name
    namespace = kubernetes_namespace.namespace.id
    labels = {
      app = var.gocd_name
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_secret" "token" {
  metadata {
    name      = kubernetes_service_account.service_account.metadata[0].name
    namespace = kubernetes_namespace.namespace.id
  }
}

resource "kubernetes_cluster_role" "cluster_role" {
  metadata {
    name = var.gocd_name
    labels = {
      app = var.gocd_name
    }
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log"]
    verbs      = ["*"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["watch", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
  metadata {
    name = var.gocd_name
    labels = {
      app = var.gocd_name
    }
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.service_account.metadata[0].name
    namespace = kubernetes_namespace.namespace.id
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_role.metadata[0].name
  }
}