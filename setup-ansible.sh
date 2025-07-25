#!/bin/bash

# Obtener la ruta absoluta del directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Script directory: $SCRIPT_DIR"

# Asegurarse de que los directorios existan
mkdir -p "$SCRIPT_DIR/ansible"
mkdir -p "$SCRIPT_DIR/terraform"

# Generar outputs.json desde terraform
cd "$SCRIPT_DIR/terraform"
echo "Generating terraform outputs in: $(pwd)"
terraform output -json > outputs.json

# Crear directorio para la clave SSH
mkdir -p ~/.ssh/casopractico2

# Extraer la clave privada y guardarla en el archivo private_key.pem
echo "Extracting private key to: ~/.ssh/casopractico2/private_key.pem"
terraform output -raw ssh_private_key > ~/.ssh/casopractico2/private_key.pem

# Establecer permisos correctos
chmod 600 ~/.ssh/casopractico2/private_key.pem

# Generar el archivo hosts.ini usando el script Python
echo "Generating hosts.ini using Python script"
cd "$SCRIPT_DIR/ansible/scripts"
python3 generate_inventory.py

echo "✅ Configuración completada:"
echo "📁 outputs.json generado en terraform/"
echo "🔑 private_key.pem generado en ansible/ con permisos 600"
echo "📄 hosts.ini generado en ansible/"
