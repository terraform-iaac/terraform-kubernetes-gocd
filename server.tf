resource "kubernetes_config_map" "preconfigure_server" {
  metadata {
    name = var.gocd_name
    namespace = kubernetes_namespace.namespace.id
    labels = {
      app = var.gocd_name
      component = "server"
    }
  }
  data = {
    "preconfigure_server.sh"  = data.template_file.preconfigure_server.rendered
  }
}

module "gocd_server" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_deploy.git?ref=v1.0.8"
  image = "${var.gocd_server_image}:${var.gocd_image_tag}"
  name = "${var.gocd_name}-server"
  namespace = kubernetes_namespace.namespace.id
  custom_labels = {
    app = var.gocd_name
    component = "server"
  }
  env = var.gocd_server_env
  internal_port = var.gocd_server_ports
  service_account_name = var.server_service_account_name
  service_account_token = true
  security_context = var.gocd_security_context
  readiness_probe = var.gocd_server_probe
  liveness_probe = var.gocd_server_probe
  lifecycle_events = var.gocd_server_lifecycle_events
  tty = false
  node_selector = var.gocd_server_node_selector

  volume_mount = [
    {
      mount_path = "/preconfigure_server.sh"
      volume_name = local.gocd-config-vol
      sub_path = "preconfigure_server.sh"
    },
    {
      mount_path = "/godata"
      volume_name = local.gocd-data-vol
      sub_path = "gocd/godata"
    },
    {
      mount_path = "/home/go"
      volume_name = local.gocd-data-vol
      sub_path = "gocd/homego"
    },
    {
      mount_path = "/docker-entrypoint.d"
      volume_name = local.gocd-data-vol
      sub_path = "gocd/scripts"
    }
  ]
  volume_nfs = [
    {
      path_on_nfs = var.path_on_nfs
      nfs_endpoint = var.nfs_endpoint
      volume_name = local.gocd-data-vol
    }
  ]
  volume_config_map = [
    {
      mode = "0420"
      name = kubernetes_config_map.preconfigure_server.metadata[0].name
      volume_name = local.gocd-config-vol
    }
  ]
}

module "service" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_service.git?ref=v1.0.0"
  app_name = "${var.gocd_name}-server"
  app_namespace = kubernetes_namespace.namespace.id
  port_mapping = var.gocd_server_ports
  custom_labels = {
    app = var.gocd_name
    component = "server"
  }
  type = "NodePort"
}

module "ingress" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_ingress.git?ref=v1.0.2"
  app_name = "${var.gocd_name}-server"
  app_namespace = kubernetes_namespace.namespace.id
  domain_name = var.domain
  web_internal_port = [
    {
      sub_domain = "gocd."
      internal_port = var.gocd_server_ports[0].internal_port
    }
  ]

  tls = var.tls
  tls_hosts = var.tls_hosts

  annotations = var.ingress_annotations
}