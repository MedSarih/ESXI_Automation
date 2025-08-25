esxi_hostname   = "10.67.6.210"
esxi_username   = "root"
esxi_password   = "Mohammeds2003."
vm_ip_subnet    = "10.67.6"
vm_gateway      = "10.67.6.202"
esxi_hostport   = "22"
clone_source_vm = "templateVM"
nic_type        = "vmxnet3"

vm_configs = {
  app-terraform = {
    cpu           = 4
    memory        = 4096
    disk_size     = 40
    ip_last_octet = 230
    datastore     = "datastore1"
    network       = "VM Network"
    role          = "application"
  }
  monitoring-terraform = {
    cpu           = 4
    memory        = 4096
    disk_size     = 40
    ip_last_octet = 240
    datastore     = "datastore1"
    network       = "VM Network"
    role          = "monitoring"
  }
}
