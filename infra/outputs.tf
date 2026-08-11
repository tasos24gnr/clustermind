output "server_ipv4" {
  description = "Public IPv4 address of the ClusterMind node."
  value       = hcloud_server.main.ipv4_address
}

output "ssh_command" {
  description = "Ready-to-use SSH command."
  value       = "ssh root@${hcloud_server.main.ipv4_address}"
}
