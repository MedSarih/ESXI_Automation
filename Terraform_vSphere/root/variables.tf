variable "esxi_hostname" { type = string }
variable "esxi_hostport" {}
variable "esxi_username" { type = string }
variable "esxi_password" {}
variable "vm_ip_subnet" { type = string }
variable "vm_gateway" { type = string }
variable "clone_source_vm" { type = string }
variable "nic_type" { type = string }

variable "vm_configs" {
  type = map(object({
    cpu           = number
    memory        = number
    disk_size     = number
    ip_last_octet = number
    datastore     = string
    network       = string
    role          = string
  }))
}
