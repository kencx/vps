terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">=1.38"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.6.0"
    }
  }
  backend "s3" {
    region = "main"
    bucket = "terraform-state"
    key    = "vps/terraform.tfstate"

    endpoints = {
      s3 = "https://minio.kencv.xyz"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    use_path_style              = true
    skip_requesting_account_id  = true
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "main" {
  name       = "web"
  public_key = file(var.vps_ssh_public_key_path)
}

data "hcloud_image" "alpine_snapshot" {
  with_selector = "distribution=alpine"
  most_recent   = true
}

resource "hcloud_server" "alpine" {
  name        = "alpine"
  image       = data.hcloud_image.alpine_snapshot.id
  server_type = "cx11"
  location    = "nbg1"
  backups     = false

  ssh_keys = [hcloud_ssh_key.main.id]
}

resource "local_file" "tf_ansible_vars_file" {
  content         = <<-EOF
ssh_public_key_path: ${var.vps_ssh_public_key_path}
username: ${var.vps_username}
password: ${var.vps_password}
timezone: ${var.vps_timezone}
letsencrypt_email: ${var.vps_letsencrypt_email}
fqdn:
  webhook: ${cloudflare_record.api-cheo-dev.hostname}
  resume: ${cloudflare_record.resume-cheo-dev.hostname}
  blog: ${cloudflare_record.ken-cheo-dev.hostname}
  sxkcd: ${cloudflare_record.xkcd-cheo-dev.hostname}
  git: ${cloudflare_record.git-cheo-dev.hostname}
EOF
  filename        = "${path.module}/tf_ansible_vars.yml"
  file_permission = "0644"
}

resource "local_file" "tf_ansible_inventory_file" {
  content         = <<-EOF
[vps]
${hcloud_server.alpine.ipv4_address} ansible_ssh_private_key_file=${var.vps_ssh_private_key_path}
EOF
  filename        = "${path.module}/tf_ansible_inventory"
  file_permission = "0644"
}

output "ip_address" {
  value       = hcloud_server.alpine.ipv4_address
  description = "IP address of endpoint"
}
