packer {
  required_plugins {
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
    hcloud = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/hcloud"
    }
  }
}

variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud token"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key"
}

locals {
  alpine_baseurl = "https://dl-cdn.alpinelinux.org/alpine/v3.18"
  alpine_tar     = "${local.alpine_baseurl}/releases/x86_64/alpine-minirootfs-3.18.4-x86_64.tar.gz"
}

source "hcloud" "alpine" {
  token = var.hcloud_token

  image       = "debian-11"
  location    = "nbg1"
  server_type = "cx11"

  rescue       = "linux64"
  ssh_username = "root"

  snapshot_labels = {
    distribution = "alpine"
    version      = "3.18"
  }
  snapshot_name = "alpine-3.18"
}

build {
  sources = [
    "source.hcloud.alpine",
  ]

  provisioner "shell" {
    script            = "${path.root}/build.sh"
    environment_vars  = ["TAR_URL=${local.alpine_tar}"]
    expect_disconnect = true
  }

  provisioner "ansible" {
    playbook_file = "${path.root}/ansible/site.yml"
    extra_arguments = [
      "--extra-vars",
      "ssh_public_key_path=${var.ssh_public_key_path}"
    ]
    user = "root"
    ansible_env_vars = [
      "ANSIBLE_STDOUT_CALLBACK=yaml",
      "ANSIBLE_HOST_KEY_CHECKING=False",
      # "ANSIBLE_CONFIG=./ansible.cfg"
    ]
    use_proxy    = false
    pause_before = "5s"
  }
}
