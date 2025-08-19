#!/bin/bash
# File: generated_inventory.sh
# Generate Ansible inventory from Terraform output (JSON)

set -e  # Exit immediately if any command fails

# Define inventory file name and temporary Terraform output file
INVENTORY_FILE="inventory.ini"
TEMP_OUTPUT="../Terraform_vSphere/root/terraform-output.json"

# Generate the latest Terraform JSON output
echo "Generating Terraform JSON output..."
terraform output -json vm_inventory > "$TEMP_OUTPUT"

# Check if the Terraform output file exists
if [ ! -f "$TEMP_OUTPUT" ]; then
  echo " Terraform output file not found: $TEMP_OUTPUT"
  exit 1
fi

echo " Terraform output found: $TEMP_OUTPUT"

# Create or empty the Ansible inventory file
> "$INVENTORY_FILE"

# Add monitoring servers group to inventory
echo "[monitoring_servers]" >> "$INVENTORY_FILE"
jq -r '
  to_entries[]                       # Iterate over each VM entry
  | select(.value.role=="monitoring") # Select only monitoring servers
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user) ansible_ssh_private_key_file=~/.ssh/id_rsa"
' "$TEMP_OUTPUT" >> "$INVENTORY_FILE"

# Add application servers group to inventory
echo "" >> "$INVENTORY_FILE"
echo "[application_servers]" >> "$INVENTORY_FILE"
jq -r '
  to_entries[]                       # Iterate over each VM entry
  | select(.value.role=="application") # Select only application servers
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user) ansible_ssh_private_key_file=~/.ssh/id_rsa"
' "$TEMP_OUTPUT" >> "$INVENTORY_FILE"

# Add global variables to inventory
echo "" >> "$INVENTORY_FILE"
echo "[all:vars]" >> "$INVENTORY_FILE"
echo "ansible_ssh_private_key_file = ~/.ssh/id_rsa" >> "$INVENTORY_FILE"
echo "ansible_ssh_common_args = -o StrictHostKeyChecking=no" >> "$INVENTORY_FILE"

# Print success message
echo " Inventory generated: $INVENTORY_FILE"
