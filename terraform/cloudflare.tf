provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_accounts" "main" {
  name = "kenc"
}

resource "cloudflare_zone" "cheo-dev" {
  account_id = data.cloudflare_accounts.main.id
  zone       = "cheo.dev"

  lifecycle {
    ignore_changes = [
      account_id
    ]
  }
}

resource "cloudflare_record" "ken-cheo-dev" {
  zone_id = cloudflare_zone.cheo-dev.id
  name    = "ken"
  value   = hcloud_server.alpine.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "xkcd-cheo-dev" {
  zone_id = cloudflare_zone.cheo-dev.id
  name    = "xkcd"
  value   = hcloud_server.alpine.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "resume-cheo-dev" {
  zone_id = cloudflare_zone.cheo-dev.id
  name    = "resume"
  value   = hcloud_server.alpine.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "api-cheo-dev" {
  zone_id = cloudflare_zone.cheo-dev.id
  name    = "api"
  value   = hcloud_server.alpine.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "git-cheo-dev" {
  count   = 0
  zone_id = cloudflare_zone.cheo-dev.id
  name    = "git"
  value   = hcloud_server.alpine.ipv4_address
  type    = "A"
  proxied = true
}
