variable "hcloud_token" {
  description = "Hetzner Cloud API token (Read & Write). Supplied via terraform.tfvars, never committed."
  type        = string
  sensitive   = true
}

variable "server_type" {
  description = "Hetzner server type. CAX21 = 4 vCPU / 8 GB ARM."
  type        = string
  default     = "cpx32"
}

variable "location" {
  description = "Hetzner datacenter location. nbg1=Nuremberg, fsn1=Falkenstein, hel1=Helsinki (all EU)."
  type        = string
  default     = "hel1"
}

variable "ssh_public_key" {
  description = "SSH public key injected into the server. The PUBLIC half only."
  type        = string
}
