resource "kubernetes_namespace" "namespace" {
  #count = var.create_namespace == true ? 1 : 0
  metadata {
    annotations = {
      name = var.gocd_namespace
    }
    #labels = var.namespace_labels
    name = var.gocd_namespace
  }
}

variable "server_shouldPreconfigure" {
  default = true
}

variable "service_account_create" {
  default = true
}
variable "rbac_create" {
  default = true
}

resource "kubernetes_service_account" "service_account" {
  count = var.service_account_create == true ? 1 : 0
  metadata {
    name = var.service_account_name
    namespace = kubernetes_namespace.namespace.id
    labels = {
      app = var.gocd_name
    }
  }
}

resource "kubernetes_cluster_role" "cluster_role" {
  count = var.rbac_create == true ? 1 : 0
  metadata {
    name = var.gocd_fullname
    labels = {
      app = var.gocd_name
    }
  }
  rule {
    api_groups = [""]
    resources = ["pods", "pods/log"]
    verbs = ["*"]
  }
  rule {
    api_groups = [""]
    resources = ["nodes"]
    verbs = ["get", "list"]
  }
  rule {
    api_groups = [""]
    resources = ["events"]
    verbs = ["watch", "list"]
  }
  rule {
    api_groups = [""]
    resources = ["namespaces"]
    verbs = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
  count = var.rbac_create == true ? 1 : 0
  metadata {
    name = var.gocd_fullname
    labels = {
      app = var.gocd_name
    }
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.service_account[0].metadata[0].name
    namespace = kubernetes_namespace.namespace.id
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = kubernetes_cluster_role.cluster_role[0].metadata[0].name
  }
}

resource "kubernetes_config_map" "preconfigure_server" {
  count = var.server_shouldPreconfigure == true ? 1 : 0
  metadata {
    name = var.gocd_name
    namespace = var.gocd_namespace
    labels = {
      app = var.gocd_name
    }
  }
  data = {
    "preconfigure_server.sh"  = data.template_file.preconfigure_server.rendered
  }
}

variable "ports" {
  default = [
    {
      name = "access"
      internal_port = "8153"
    }
  ]
}

module "gocd_server" {
  source = "../terraform_k8s_deploy"
  image = "${var.server_image}:${var.app_version}"
  name = "${var.gocd_fullname}-server"
  namespace = kubernetes_namespace.namespace.id
  custom_labels = {
    app = var.gocd_name
    component = "server"
  }
  internal_port = var.ports
  service_account_name = var.service_account_create == true ? kubernetes_service_account.service_account[0].metadata[0].name : null
  security_context = var.server_security_context
  volume_mount = [
    {
      mount_path = "/preconfigure_server.sh"
      volume_name = "config-vol"
      sub_path = "preconfigure_server.sh"
    },
    {
      mount_path = "/godata"
      volume_name = "goserver-vol"
      sub_path = "godata"
    },
    {
      mount_path = "/home/go"
      volume_name = "goserver-vol"
      sub_path = "homego"
    },
    {
      mount_path = "/docker-entrypoint.d"
      volume_name = "goserver-vol"
      sub_path = "scripts"
    }
  ]
  volume_nfs = [
    {
      path_on_nfs = var.path_on_nfs
      nfs_endpoint = var.nfs_endpoint
      volume_name = "goserver-vol"
    }
  ]
  volume_config_map = [
    {
      mode = "0420"
      name = kubernetes_config_map.preconfigure_server[0].metadata[0].name
      volume_name = "config-vol"
    }
  ]
}

variable "server_security_context" {
  default = [
    {
      fs_group = "0"
      user_id = "1000"
      group_id = "0"
    }
  ]
}