terraform {
  required_version = ">= 0.13"

  required_providers {
    esxi = {
      source  = "josenk/esxi"
      version = "~> 1.10.0" # or latest compatible version
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

module "vm" {
  source   = "../modules/vm"
  for_each = var.vm_configs

  name            = each.key
  cpu             = each.value.cpu
  memory          = each.value.memory
  disk_size       = each.value.disk_size
  ip_last_octet   = each.value.ip_last_octet
  datastore       = each.value.datastore
  network         = each.value.network
  vm_ip_subnet    = var.vm_ip_subnet
  vm_gateway      = var.vm_gateway
  nic_type        = var.nic_type
  role            = each.value.role
  clone_source_vm = var.clone_source_vm # pass existing VM template name

}

resource "null_resource" "generate_inventory" {
  depends_on = [module.vm]

  provisioner "local-exec" {
    command = <<EOT
echo "# Auto-generated Ansible Inventory" > inventory.ini
echo "" >> inventory.ini

echo "[monitoring_servers]" >> inventory.ini
%{for k, cfg in var.vm_configs~}
%{if cfg.role == "monitoring"}
echo "${k} ansible_host=${var.vm_ip_subnet}.${cfg.ip_last_octet} ansible_user=ubuntu" >> inventory.ini
%{endif~}
%{endfor~}

echo "" >> inventory.ini
echo "[application_servers]" >> inventory.ini
%{for k, cfg in var.vm_configs~}
%{if cfg.role == "application"}
echo "${k} ansible_host=${var.vm_ip_subnet}.${cfg.ip_last_octet} ansible_user=ubuntu" >> inventory.ini
%{endif~}
%{endfor~}

echo "[all:vars]" >> inventory.ini
echo "ansible_ssh_private_key_file = ~/.ssh/id_rsa" >> inventory.ini
echo "ansible_ssh_common_args = -o StrictHostKeyChecking=no" >> inventory.ini
EOT
  }

}
