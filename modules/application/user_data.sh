#!/bin/bash
set -x
exec > /var/log/user-data.log 2>&1

echo "=== User Data Script Started at $(date) ==="

# Atualizar sistema
echo "Updating system..."
yum update -y

# Instalar Apache
echo "Installing httpd..."
yum install -y httpd

# Obter metadados
echo "Getting instance metadata..."
COMPUTE_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid | tr '[:upper:]' '[:lower:]')
COMPUTE_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

echo "Instance ID: $COMPUTE_INSTANCE_ID"
echo "Machine UUID: $COMPUTE_MACHINE_UUID"

# Criar página HTML - usando echo para evitar problemas com heredoc
echo "Creating HTML page..."
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Instance Info</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        h1 { color: #FF9900; }
        .info { 
            background-color: #e8f4f8;
            padding: 15px;
            border-left: 4px solid #FF9900;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 AWS Instance Information</h1>
        <div class="info">
            <p>This message was generated on instance <strong>$COMPUTE_INSTANCE_ID</strong> with the following UUID <strong>$COMPUTE_MACHINE_UUID</strong></p>
        </div>
        <p><small>Powered by Terraform & AWS</small></p>
    </div>
</body>
</html>
EOF

# Iniciar Apache
echo "Starting httpd service..."
systemctl start httpd
systemctl enable httpd

# Verificar status
echo "Checking httpd status..."
systemctl status httpd

# Teste local
echo "Testing local connection..."
curl -s localhost

echo "=== User Data Script Completed at $(date) ==="
