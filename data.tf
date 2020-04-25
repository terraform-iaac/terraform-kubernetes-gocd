data "template_file" "preconfigure_server" {
  template = file("${path.module}/template/preconfigure_server.sh")
  vars = {
    gocd_fullname = var.gocd_fullname
    server_service_httpPort = var.server_service_httpPort
    gocd_namespace = var.gocd_namespace
    AppVersion = var.app_version
    agentServiceAccountName = var.agent_service_account_name
  }
}