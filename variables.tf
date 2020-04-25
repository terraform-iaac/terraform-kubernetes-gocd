variable "gocd_name" {
  default = "gocd"
}

variable "gocd_fullname" {
  default = "gocd"
}

variable "gocd_namespace" {
  default = "gocd-test"
}

variable "server_service_httpPort" {
  default = "8153"
}

variable "app_version" {
  default = "v20.3.0"
}

variable "agent_service_account_name" {
  default = "default"
}

variable "service_account_name" {
  default = "gocd"
}

variable "server_image" {
  default = "gocd/gocd-server"
}

variable "path_on_nfs" {
  default = ""
}
variable "nfs_endpoint" {
  default = ""
}