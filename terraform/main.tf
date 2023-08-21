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

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "hcloud" {
  token = var.vps_hcloud_token
}

data "cloudflare_accounts" "main" {
  name = "kenc"
}

resource "cloudflare_zone" "cheo-dev" {
  account_id = data.cloudflare_accounts.main.id
  zone       = "cheo.dev"
}

resource "cloudflare_record" "ken-cheo-dev" {
  zone_id = cloudflare_zone.cheo-dev.id
  name    = "ken"
  value   = hcloud_server.main.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "xkcd-cheo-dev" {
  zone_id = cloudflare_zone.cheo-dev.id
  name    = "xkcd"
  value   = hcloud_server.main.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "resume-cheo-dev" {
  zone_id = cloudflare_zone.cheo-dev.id
  name    = "resume"
  value   = hcloud_server.main.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "api-cheo-dev" {
  zone_id = cloudflare_zone.cheo-dev.id
  name    = "api"
  value   = hcloud_server.main.ipv4_address
  type    = "A"
  proxied = true
}

resource "hcloud_ssh_key" "main" {
  name       = "web"
  public_key = file(var.vps_ssh_public_key_path)
}

resource "hcloud_server" "main" {
  name        = "web"
  image       = "debian-11"
  server_type = "cx11"
  location    = "nbg1"
  backups     = false

  ssh_keys = [hcloud_ssh_key.main.id]
}

resource "local_file" "tf_ansible_vars_file" {
  content         = <<-EOF
vps_ssh_public_key_path: ${var.vps_ssh_public_key_path}
vps_username: ${var.vps_username}
vps_password: ${var.vps_password}
vps_timezone: ${var.vps_timezone}
vps_certbot_email: ${var.vps_certbot_email}
${yamlencode({ vps_packages = var.vps_packages })}
EOF
  filename        = "${path.module}/tf_ansible_vars.yml"
  file_permission = "0644"
}

resource "local_file" "tf_ansible_inventory_file" {
  content         = <<-EOF
[vps]
${hcloud_server.main.ipv4_address} ansible_ssh_private_key_file=${var.vps_ssh_private_key_path}
EOF
  filename        = "${path.module}/tf_ansible_inventory"
  file_permission = "0644"
}

output "ip_address" {
  value       = hcloud_server.main.ipv4_address
  description = "IP address of endpoint"
}
