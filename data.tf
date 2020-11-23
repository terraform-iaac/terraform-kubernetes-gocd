data "template_file" "preconfigure_server" {
  template = file("${path.module}/template/preconfigure_server.sh")
  vars = {
    gocd_name               = var.gocd_name
    server_service_httpPort = var.gocd_server_ports[0].internal_port
    gocd_namespace          = var.gocd_namespace
    AppVersion              = var.gocd_image_tag
    agentServiceAccountName = var.agent_service_account_name
  }
}