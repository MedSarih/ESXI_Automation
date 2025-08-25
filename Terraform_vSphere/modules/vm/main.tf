terraform {
  required_providers {
    esxi = {
      source  = "josenk/esxi"
      version = "~> 1.10.0"
    }
  }
}


resource "esxi_guest" "vm" {
  guest_name         = var.name
  disk_store         = var.datastore
  numvcpus           = var.cpu
  memsize            = var.memory
  guestos            = "ubuntu-64"
  boot_disk_size     = var.disk_size
  power      = "on"


  # Clone from an existing VM on ESXi (must be powered off)
  clone_from_vm      = var.clone_source_vm

  network_interfaces {
    virtual_network  = var.network
    nic_type        = var.nic_type
  }

  # Cloud-init static IP configuration
  guestinfo = {
    "metadata" = base64encode(jsonencode({
      "network" = {
        "version" = 2
        "ethernets" = {
          "ens160" = {
            "addresses" = ["${var.vm_ip_subnet}.${var.ip_last_octet}/24"]
            "gateway4"  = var.vm_gateway
            "nameservers" = {
              "addresses" = ["8.8.8.8", "1.1.1.1"]
            }
          }
        }
      }
      "local-hostname" = var.name
      "instance-id"    = var.name
    }))
    "metadata.encoding" = "base64"
  }

 notes = "Role: ${var.role}, Managed by Terraform_Mohammed"



}
