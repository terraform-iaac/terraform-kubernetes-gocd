variable "nfs_endpoint" {
  description = "(Required) Nfs endpoint"
  type = string
}
variable "path_on_nfs" {
  description = "(Optional) Path on efs for volumes"
  type = string
  default = "/"
}
variable "domain" {
  description = "(Required) Domain for the url. Generating url: gocd.[domain]"
}
variable "gocd_name" {
  description = "(Optional) Application name"
  type = string
  default = "gocd"
}
variable "gocd_namespace" {
  description = "(Optional) Namespace name"
  type = string
  default = "gocd"
}
variable "namespace_labels" {
  description = "(Optional) Add labels for namespace"
  type = map(string)
  default = {}
}
variable "gocd_image_tag" {
  description = "(Optional) Docker image tag for server & agent"
  type = string
  default = "v20.9.0"
}
variable "gocd_server_image" {
  description = "(Optional) Docker image for server & agent"
  type = string
  default = "gocd/gocd-server"
}
variable "server_service_account_name" {
  description = "(Optional) Service account name for server"
  type = string
  default = "gocd"
}
variable "gocd_security_context" {
  default = [
    {
      fs_group = 0
      user_id = 1000
      group_id = 0
      as_non_root = false
    }
  ]
}
variable "gocd_server_env" {
  default = [
    {
      name = "GOCD_PLUGIN_INSTALL_kubernetes-elastic-agents"
      value = "https://github.com/gocd/kubernetes-elastic-agents/releases/download/v3.7.1-230/kubernetes-elastic-agent-3.7.1-230.jar"
    },
    {
      name = "GOCD_PLUGIN_INSTALL_docker-registry-artifact-plugin"
      value = "https://github.com/gocd/docker-registry-artifact-plugin/releases/download/v1.1.0-104/docker-registry-artifact-plugin-1.1.0-104.jar"
    },
    {
      name = "GOCD_PLUGIN_INSTALL_gocd-ec2-elastic-agent-plugin"
      value = "https://github.com/iriusrisk/GoCD-EC2-Elastic-Agent-Plugin/releases/download/2.2.0/gocd-ec2-elastic-agent-plugin-2.2.0.jar"
    },
    {
      name = "GOCD_PLUGIN_INSTALL_gocd-ldap-authorization-plugin"
      value = "https://github.com/gocd/gocd-ldap-authorization-plugin/releases/download/v4.0.1-6/gocd-ldap-authorization-plugin-4.0.1-6.jar"
    },
    {
      name = "GOCD_PLUGIN_INSTALL_gocd-slack-notifier"
      value = "https://github.com/ashwanthkumar/gocd-slack-build-notifier/releases/download/v2.0.2/gocd-slack-notifier-2.0.2.jar"
    }
  ]
}
locals {
  // GoCd server, volume names
  gocd-config-vol = "config-vol"
  gocd-data-vol = "goserver-vol"
}
variable "gocd_server_probe" {
  default = [
    {
      failure_threshold = 10
      initial_delay_seconds = 90
      period_seconds = 15
      success_threshold = 1
      timeout_seconds = 1
      http_get = [
        {
          path = "/go/api/v1/health"
          port = "8153"
          scheme = "HTTP"
        }
      ]
    }
  ]
}
variable "gocd_server_lifecycle_events" {
  default = [
    {
      post_start = [
        {
          exec_command = [
            "/bin/bash",
            "/preconfigure_server.sh",
          ]
        }
      ]
    }
  ]
}
variable "gocd_server_ports" {
  description = "(Optional) Port mapping"
  default = [
    {
      name = "http"
      internal_port = "8153"
      external_port = "8153"
    }
  ]
}
variable "tls" {
  type = list(string)
  description = "(Optional) Define TLS , for use only HTTPS"
  default = []
}
variable "tls_hosts" {
  description = "(Optional) Define TLS with host"
  default = []
}
variable "ingress_annotations" {
  description = "(Optional) Set addional annontations for ingress"
  default = {
    "kubernetes.io/ingress.class" = "nginx"
  }
}
variable "agent_service_account_name" {
  description = "(Optional) Default service account for agent"
  type = string
  default = "default"
}
variable "gocd_static_agent_count" {
  description = "(Optional) Agent count"
  type = number
  default = 0
}
variable "gocd_agent_env" {
  description = "(Optional) GoCd Agent envs"
  default = [
    {
      name = "GO_SERVER_URL"
      value = "http://gocd-server:8153/go"
    }
  ]
}
variable "agent_image" {
  description = "(Optional) Docker image for agent"
  type = string
  default = "gocd/gocd-agent-alpine-3.10"
}
variable "gocd_server_node_selector" {
  description = "(Optional) Specify node selector for pod"
  type = map(string)
  default = null
}