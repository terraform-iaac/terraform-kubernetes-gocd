module "gocd_agent" {
  source  = "terraform-iaac/deployment/kubernetes"
  version = "1.0.8"

  strategy_update = "Recreate"

  name      = "${var.gocd_name}-agent"
  namespace = kubernetes_namespace.namespace.id

  image = "${var.agent_image}:${var.gocd_image_tag}"

  custom_labels = {
    app       = var.gocd_name
    component = "agent"
  }

  env = var.gocd_agent_env

  security_context = var.gocd_security_context

  replicas = var.gocd_static_agent_count

  service_account_name  = var.agent_service_account_name
  service_account_token = true
}