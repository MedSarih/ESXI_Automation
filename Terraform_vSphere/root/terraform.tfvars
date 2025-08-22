esxi_hostname   = "172.20.10.51"
esxi_username   = "root"
esxi_password   = "Mohammeds2003."
vm_ip_subnet    = "172.20.10"
vm_gateway      = "172.20.10.2"
esxi_hostport   = "22"
clone_source_vm = "templateVM"
nic_type        = "vmxnet3"



vm_configs = {
  app-terraform = {
    cpu           = 4
    memory        = 4096
    disk_size     = 40
    ip_last_octet = 190
    datastore     = "datastore1"
    network       = "VM Network"
    role          = "application"
  }
  monitoring-terraform = {
    cpu           = 4
    memory        = 4096
    disk_size     = 40
    ip_last_octet = 191
    datastore     = "datastore1"
    network       = "VM Network"
    role          = "monitoring"
  }
}
