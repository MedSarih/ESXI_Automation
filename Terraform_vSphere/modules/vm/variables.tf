variable "name" {
  description = "VM name"
  type        = string
}

variable "cpu" {
  description = "Number of CPUs"
  type        = number
}

variable "memory" {
  description = "Memory in MB"
  type        = number
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
}

variable "ip_last_octet" {
  description = "Last octet for VM IP"
  type        = number
}

variable "datacenter" {
  description = "Datacenter name"
  type        = string
}

variable "cluster" {
  description = "Compute cluster name"
  type        = string
}

variable "datastore" {
  description = "Datastore name"
  type        = string
}

variable "network" {
  description = "Network name"
  type        = string
}

variable "template_name" {
  description = "Template VM name"
  type        = string
}

variable "vm_ip_subnet" {
  description = "Subnet base for IP (first 3 octets)"
  type        = string
}

variable "vm_gateway" {
  description = "Gateway IP for VM"
  type        = string
}