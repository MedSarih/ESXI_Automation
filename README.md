# 🚀 ESXi Automation with Terraform, Ansible & Jenkins

This project automates the provisioning and configuration of **VMware vSphere VMs** using **Terraform**, **Ansible**, and **Jenkins**, with monitoring enabled via **Prometheus & Grafana**.

---

## 📌 Architecture Overview

- **GitHub** – Source code repository  
- **Jenkins** – CI/CD pipeline triggered by GitHub push events  
- **Terraform** – Provisions VMs in vSphere based on VM templates  
- **Ansible** – Configures provisioned VMs and deploys a monitoring stack  
- **Monitoring** – Prometheus + Grafana deployed via Docker to monitor the infrastructure  


![Uploading drawnew.png…]()


```plaintext
📂 Project Structure
ESXI_AUTOMATION_
├── Ansible_vSphere/
│   ├── generated_inventory.sh   # Script to generate Ansible inventory dynamically
│   ├── playbook-monitoring.yml  # Deploys monitoring stack (Prometheus, Grafana)
│   ├── playbook-setup.yml       # Configures provisioned VMs
│
├── Jenkins_vSphere/
│   └── Jenkinsfile              # CI/CD pipeline definition
│
└──Terraform_vSphere/
    ├── modules/vm/              # Terraform module for VM provisioning
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── variables.tf
    └── root/
        ├── main.tf
        ├── outputs.tf
        ├── terraform.tfvars     # Variables (credentials, VM specs, etc.)
        └── variables.tf
```

## ⚙️ Workflow

1. **Developer** pushes code to **GitHub**  
2. **Jenkins** pipeline is triggered  
3. **Terraform** provisions VMs on **VMware vSphere**  
4. Terraform generates **inventory.ini** for **Ansible**  
5. **Ansible** configures the VMs and deploys monitoring stack (**Prometheus + Grafana**)  
6. Infrastructure is ready and monitored via **Grafana dashboards**  
