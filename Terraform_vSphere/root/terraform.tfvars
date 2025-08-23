esxi_hostname   = "10.49.66.200"
esxi_username   = "root"
esxi_password   = "Mohammeds2003."
vm_ip_subnet    = "10.49.66"
vm_gateway      = "10.49.66.26"
esxi_hostport   = "22"
clone_source_vm = "templateVM"
nic_type        = "vmxnet3"

vm_configs = {
  app-terraform = {
    cpu           = 4
    memory        = 4096
    disk_size     = 40
    ip_last_octet = 202
    datastore     = "datastore1"
    network       = "VM Network"
    role          = "application"
  }
  monitoring-terraform = {
    cpu           = 4
    memory        = 4096
    disk_size     = 40
    ip_last_octet = 204
    datastore     = "datastore1"
    network       = "VM Network"
    role          = "monitoring"
  }
}
