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

variable "lxc_ip" {
  description = "Container IP"
  type		= string
  default 	= "10.0.70.3"
}

variable "hostname" {
  description = "Container hostname"
  type        = string
  default     = "ansible"
}

variable "ssh_public_key" {
  description = "SSH public key for container access"
  type        = string
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true  # Because we're using self-signed certs
}

resource "proxmox_lxc" "ansible" {
  target_node  = "pve1"
  hostname     = var.hostname
  vmid         = 703
  ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password     = var.lxc_password
  unprivileged = true
  start        = true
  ssh_public_keys = var.ssh_public_key

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  cores  = 1
  memory = 512

  network {
    name   = "eth0"
    bridge = "vlan70"
    ip     = "${var.lxc_ip}/24"
    gw     = "10.0.70.1"
  }

  features {
    nesting = true
  }
}

output "ansible_container_info" {
  value = {
    vmid     = proxmox_lxc.ansible.vmid
    hostname = proxmox_lxc.ansible.hostname
    ip       = var.lxc_ip
  }
}
