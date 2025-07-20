#!/usr/bin/env python3
import json
import os

# Obtener la ruta del directorio del script
script_dir = os.path.dirname(os.path.abspath(__file__))
ansible_dir = os.path.dirname(script_dir)
project_root = os.path.dirname(ansible_dir)

print(f"Script directory: {script_dir}")
print(f"Project root: {project_root}")

# Rutas absolutas
terraform_outputs = os.path.join(project_root, 'terraform', 'outputs.json')
hosts_ini = os.path.join(ansible_dir, 'hosts.ini')

print(f"Looking for terraform outputs at: {terraform_outputs}")
print(f"Will write hosts.ini to: {hosts_ini}")

# Leer el archivo outputs.json
with open(terraform_outputs, 'r') as f:
    outputs = json.load(f)

# Crear el contenido del inventory
inventory_content = f"""[defaults]
host_key_checking=False

[vm]
{outputs['vm_public_ip']['value']} ansible_ssh_private_key_file=~/.ssh/casopractico2/private_key.pem ansible_user=azureuser

[all:vars]
acr_name={outputs['acr_admin_username']['value']}
acr_login_server={outputs['acr_login_server']['value']}

# Using single localhost entry for both ACR and local operations
[local]
localhost ansible_connection=local
"""

# Escribir el archivo hosts.ini
with open(hosts_ini, 'w') as f:
    f.write(inventory_content)

print("Inventory file generated successfully")
