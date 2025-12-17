#!/bin/bash
# Setup Self-Signed SSL for IP Address

set -e

echo "========================================="
echo "Self-Signed SSL Configuration"
echo "========================================="

# Get Public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
echo "🌐 Server Public IP: $PUBLIC_IP"

SSL_DIR="/etc/nginx/ssl"
KEY_FILE="$SSL_DIR/selfsigned.key"
CERT_FILE="$SSL_DIR/selfsigned.crt"

# Create SSL directory
mkdir -p $SSL_DIR

# Generate Self-Signed Certificate
echo "🔒 Generating self-signed certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout $KEY_FILE \
    -out $CERT_FILE \
    -subj "/C=SG/ST=Singapore/L=Singapore/O=OncoTracker/CN=$PUBLIC_IP"

echo "✅ Certificate generated at $CERT_FILE"

# Determine config file location
if [ -d "/etc/nginx/conf.d" ]; then
    CONFIG_FILE="/etc/nginx/conf.d/oncotracker.conf"
else
    CONFIG_FILE="/etc/nginx/sites-available/oncotracker"
fi

echo "📝 Updating Nginx config at $CONFIG_FILE..."

# Update Nginx Configuration to enforce HTTPS
cat > "$CONFIG_FILE" <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;
    server_name _;
    
    ssl_certificate $CERT_FILE;
    ssl_certificate_key $KEY_FILE;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Supabase Dashboard
    location /supabase/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Supabase API
    location /supabase/v1/ {
        proxy_pass http://127.0.0.1:8000/api/v1/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Next.js Application
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

echo "🧪 Testing Nginx configuration..."
nginx -t

echo "🔄 Restarting Nginx..."
systemctl restart nginx

echo ""
echo "✅ HTTPS enabled on https://$PUBLIC_IP"
echo "⚠️  Note: You will see a security warning in the browser because this is a self-signed certificate."
echo "⚠️  Ensure PORT 443 is open in your Security Group!"
