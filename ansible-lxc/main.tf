terraform {
  required_providers {
    proxmox = {
      source  = "registry.terraform.io/telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

variable "lxc_password" {
  description = "Root password for LXC containers"
  type        = string
  sensitive   = true
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  sensitive   = true
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true  # Because we're using self-signed certs
}

resource "proxmox_lxc" "blog" {
  target_node  = "pve1"
  hostname     = "blog"
  vmid         = 1401
  ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password     = var.lxc_password
  unprivileged = true
  start        = true

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  cores  = 1
  memory = 512

  network {
    name   = "eth0"
    bridge = "vlan140"
    ip     = "10.0.140.2/24"
    gw     = "10.0.140.1"
  }

  features {
    nesting = true
  }
}

output "blog_container_info" {
  value = {
    vmid     = proxmox_lxc.blog.vmid
    hostname = proxmox_lxc.blog.hostname
    ip       = "10.0.140.2"
  }
}