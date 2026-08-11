# Register our SSH public key with Hetzner so it can be injected into servers.
resource "hcloud_ssh_key" "main" {
  name       = "clustermind-key"
  public_key = var.ssh_public_key
}

# Firewall: allow SSH (22), HTTP (80), HTTPS (443) inbound.
resource "hcloud_firewall" "main" {
  name = "clustermind-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

# The server itself.
resource "hcloud_server" "main" {
  name         = "clustermind-node"
  server_type  = var.server_type
  location     = var.location
  image        = "ubuntu-24.04"
  ssh_keys     = [hcloud_ssh_key.main.id]
  firewall_ids = [hcloud_firewall.main.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
