esxi_hostname   = "192.168.11.133"
esxi_username   = "root"
esxi_password   = "Mohammeds2003."
vm_ip_subnet    = "192.168.11"
vm_gateway      = "192.168.11.1"
esxi_hostport   = "22"
clone_source_vm = "templateVM"
nic_type        = "vmxnet3"

vm_configs = {
  app1-vMachine = {
    cpu           = 4
    memory        = 4096
    disk_size     = 40
    ip_last_octet = 230
    datastore     = "datastore1"
    network       = "VM Network"
    role          = "application"
  }

    app2-vMachine = {
    cpu           = 4
    memory        = 4096
    disk_size     = 40
    ip_last_octet = 220
    datastore     = "datastore1"
    network       = "VM Network"
    role          = "application"
  }



  monitoring-vMachine = {
    cpu           = 4
    memory        = 4096
    disk_size     = 40
    ip_last_octet = 240
    datastore     = "datastore1"
    network       = "VM Network"
    role          = "monitoring"
  }
}
