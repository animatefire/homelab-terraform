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

variable "ssh_public_key" {
  description = "SSH public key for container access"
  type        = string
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true
}

resource "proxmox_lxc" "uptime_kuma" {
  target_node  = "pve2"
  hostname     = "uptime-kuma"
  vmid         = 1102
  ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password     = var.lxc_password
  unprivileged = true
  start        = true
  ssh_public_keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvwKwTUkfVuJnCDEnw6C+l/0EP8cWYqy1lTLrpTdXW2 ansible"

  rootfs {
    storage = "local-lvm"
    size    = "16G"
  }

  cores  = 1
  memory = 512

  network {
    name   = "eth0"
    bridge = "vlan110"
    ip     = "10.0.110.2/24"
    gw     = "10.0.110.1"
  }

  features {
    nesting = true
  }
}

output "uptime_kuma_info" {
  value = {
    vmid     = proxmox_lxc.uptime_kuma.vmid
    hostname = proxmox_lxc.uptime_kuma.hostname
    ip       = "10.0.110.2"
  }
}