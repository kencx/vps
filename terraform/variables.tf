variable "hcloud_token" {
  type        = string
  description = "Hetzner API Token"
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "vps_ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key"
}

variable "vps_ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key"
}
