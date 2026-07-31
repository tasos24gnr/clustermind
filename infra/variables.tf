variable "region" {
  description = "OCI region to deploy into (e.g. eu-frankfurt-1). A variable so we can relocate if a region hits capacity limits."
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment to create resources in. Account-specific; supplied via terraform.tfvars, never committed."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key injected into the VM for login. The PUBLIC half only."
  type        = string
}

variable "instance_shape" {
  description = "Compute shape for the VM."
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs. Always-Free ARM ceiling is 4 total across all instances; we use the full tenancy allocation."
  type        = number
  default     = 2
}

variable "instance_memory_gb" {
  description = "Memory in GB. Always-Free ceiling is 24 total; we use 12."
  type        = number
  default     = 12
}
