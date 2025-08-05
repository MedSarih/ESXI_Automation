variable "vsphere_user" {
  description = "vSphere username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vSphere server address"
  type        = string
}

variable "template_name" {
  description = "VM Template name created by Packer"
  type        = string
  default     = "ubuntu-template"
}

variable "vm_ip_subnet" {
  description = "Base subnet for VM IPs (first 3 octets)"
  type        = string
  default     = "192.168.1"
}

variable "vm_gateway" {
  description = "Gateway IP for the VMs"
  type        = string
  default     = "192.168.1.1"
}



variable "vm_configs" {
  description = "Map of VM configurations keyed by VM name"
  type = map(object({
    cpu          = number
    memory       = number
    disk_size    = number
    ip_last_octet = number

    datacenter   = string
    cluster      = string
    datastore    = string
    network      = string

    role        = string
  }))
}
