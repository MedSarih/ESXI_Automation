#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_FILE="$SCRIPT_DIR/inventory.ini"
TEMP_OUTPUT="$SCRIPT_DIR/terraform-output.json"

echo "🔧 Generating Ansible inventory..."
echo "📁 Inventory file: $INVENTORY_FILE"
echo "📄 Terraform output: $TEMP_OUTPUT"

# Check if file exists
if [[ ! -f "$TEMP_OUTPUT" ]]; then
  echo "❌ ERROR: Terraform output file not found: $TEMP_OUTPUT" >&2
  exit 1
fi

# Validate JSON
if ! jq empty "$TEMP_OUTPUT" 2>/dev/null; then
  echo "❌ ERROR: Invalid JSON in $TEMP_OUTPUT" >&2
  echo "👉 Try running: jq . $TEMP_OUTPUT"
  exit 1
fi

# Extract all VMs with role and name
echo "🔍 Found VMs:"
jq -r 'to_entries[] | "  Key='\''\(.key)'\'', Name='\''\(.value.name)'\'', Role='\''\(.value.role)'\'', IP='\''\(.value.ip)'\'', User='\''\(.value.ansible_user)'\''"' "$TEMP_OUTPUT"

# Start fresh inventory
> "$INVENTORY_FILE"

# Add monitoring servers
echo "[monitoring_servers]" >> "$INVENTORY_FILE"
jq -r '
  to_entries[]
  | select(.value.role and .value.role == "monitoring")
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user)"
' "$TEMP_OUTPUT" >> "$INVENTORY_FILE" || true

# Add application servers
echo "" >> "$INVENTORY_FILE"
echo "[application_servers]" >> "$INVENTORY_FILE"
jq -r '
  to_entries[]
  | select(.value.role and .value.role == "application")
  | "\(.value.name) ansible_host=\(.value.ip) ansible_user=\(.value.ansible_user)"
' "$TEMP_OUTPUT" >> "$INVENTORY_FILE" || true

# Add groups
cat >> "$INVENTORY_FILE" << EOF

[all_servers:children]
monitoring_servers
application_servers

[all:vars]
ansible_ssh_pass = \${ANSIBLE_VM_CREDENTIALS}
ansible_ssh_common_args = -o StrictHostKeyChecking=no
EOF

# Final check
echo ""
if [[ ! -s "$INVENTORY_FILE" ]]; then
  echo "❌ ERROR: Inventory file is empty!" >&2
  exit 1
fi

echo "✅ SUCCESS: Inventory generated at $INVENTORY_FILE"
echo ""
echo "📄 Contents:"
cat "$INVENTORY_FILE"
echo ""