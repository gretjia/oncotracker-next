#!/bin/bash
# Nginx Configuration Script
# Run this on your ECS instance after deploying the application

set -e

echo "========================================="
echo "Nginx Configuration"
echo "========================================="

# Prompt for domain name
read -p "Enter your domain name (or press Enter to skip SSL setup): " DOMAIN_NAME

# Create Nginx configuration
echo "📝 Creating Nginx configuration..."

# Determine Nginx configuration directory
if [ -d "/etc/nginx/conf.d" ]; then
    echo "📂 Detected conf.d directory (RHEL/CentOS style)"
    CONFIG_FILE="/etc/nginx/conf.d/oncotracker.conf"
    USE_SITES_ENABLED=false
else
    echo "📂 Detected sites-available directory (Debian/Ubuntu style)"
    CONFIG_FILE="/etc/nginx/sites-available/oncotracker"
    USE_SITES_ENABLED=true
fi

# Create Nginx configuration
echo "📝 Creating Nginx configuration at $CONFIG_FILE..."

if [ -z "$DOMAIN_NAME" ]; then
    # Configuration without domain (IP access only)
    cat > "$CONFIG_FILE" << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name _;

    # Supabase Dashboard
    location /supabase/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Supabase API
    location /supabase/v1/ {
        proxy_pass http://127.0.0.1:8000/api/v1/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Next.js Application
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
else
    # Configuration with domain
    cat > "$CONFIG_FILE" <<EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;

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
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
fi

# Enable the site
if [ "$USE_SITES_ENABLED" = true ]; then
    echo "🔗 Enabling site..."
    ln -sf $CONFIG_FILE /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
fi

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

# Restart Nginx
echo "🔄 Restarting Nginx..."
sudo systemctl restart nginx

echo ""
echo "✅ Nginx configured successfully!"
echo ""

# Setup SSL if domain is provided
if [ ! -z "$DOMAIN_NAME" ]; then
    read -p "Do you want to set up SSL with Let's Encrypt? (y/n): " SETUP_SSL
    
    if [ "$SETUP_SSL" = "y" ] || [ "$SETUP_SSL" = "Y" ]; then
        echo "🔒 Installing Certbot..."
        sudo apt install certbot python3-certbot-nginx -y
        
        echo "🔒 Obtaining SSL certificate..."
        sudo certbot --nginx -d ${DOMAIN_NAME}
        
        echo "✅ SSL certificate installed!"
        echo "Your site is now available at: https://${DOMAIN_NAME}"
    fi
else
    echo "⚠️  No domain configured. Your site is available at: http://YOUR_ECS_IP"
fi

echo ""
echo "========================================="
echo "✅ Nginx setup complete!"
echo "========================================="
echo ""
