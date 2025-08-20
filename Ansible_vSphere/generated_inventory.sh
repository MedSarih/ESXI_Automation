#!/bin/bash
# File: generated_inventory.sh
# Generate Ansible inventory from Terraform output (JSON)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_FILE="$SCRIPT_DIR/inventory.ini"
TEMP_OUTPUT="$SCRIPT_DIR/terraform-output.json"

echo "Generating inventory in Ansible directory..."
echo "Inventory file: $INVENTORY_FILE"
echo "Terraform output: $TEMP_OUTPUT"

# Check if Terraform output file exists
if [ ! -f "$TEMP_OUTPUT" ]; then
    echo "Error: Terraform output file not found: $TEMP_OUTPUT" >&2
    exit 1
fi

# Validate JSON
if ! jq empty "$TEMP_OUTPUT" 2>/dev/null; then
    echo "Error: Invalid JSON in Terraform output" >&2
    exit 1
fi

# Create or empty the Ansible inventory file
> "$INVENTORY_FILE"

# Add monitoring servers group to inventory (using template user)
echo "[monitoring_servers]" >> "$INVENTORY_FILE"
jq -r '
  to_entries[]
  | select(.value.role=="monitoring")
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=template"
' "$TEMP_OUTPUT" >> "$INVENTORY_FILE"

# Add application servers group to inventory (using template user)
echo "" >> "$INVENTORY_FILE"
echo "[application_servers]" >> "$INVENTORY_FILE"
jq -r '
  to_entries[]
  | select(.value.role=="application")
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=template"
' "$TEMP_OUTPUT" >> "$INVENTORY_FILE"

# Add all servers group
echo "" >> "$INVENTORY_FILE"
echo "[all_servers:children]" >> "$INVENTORY_FILE"
echo "monitoring_servers" >> "$INVENTORY_FILE"
echo "application_servers" >> "$INVENTORY_FILE"

# Add global variables for template user authentication
echo "" >> "$INVENTORY_FILE"
echo "[all:vars]" >> "$INVENTORY_FILE"
echo "ansible_ssh_pass = template" >> "$INVENTORY_FILE"  # ← Using template password
echo "ansible_ssh_common_args = -o StrictHostKeyChecking=no" >> "$INVENTORY_FILE"

echo "SUCCESS: Inventory generated at $INVENTORY_FILE"