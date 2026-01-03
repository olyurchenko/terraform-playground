#!/bin/bash
apt update -y
apt install -y apache2
systemctl start apache2
systemctl enable apache2

cat > /var/www/html/index.html <<EOF
<h1>Hello, World</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF
