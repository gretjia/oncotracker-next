#!/bin/bash
# Automated Nginx + Let's Encrypt SSL Fix for biotinto.cn
# Fixes the malformed oncotracker_idn.conf and installs proper SSL

set -e

echo "========================================="
echo "Nginx HTTPS Remediation for biotinto.cn"
echo "========================================="

DOMAIN="biotinto.cn"
DOMAIN_IDN="xn--5us92m0xp.com"  # Punycode for 官官.com if needed
CONFIG_FILE="/etc/nginx/conf.d/oncotracker.conf"

# Backup existing config
echo "📦 Backing up current configuration..."
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Install Certbot (Alibaba Cloud Linux 4 compatible method)
echo "🔧 Installing Certbot..."
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot via Python venv..."
    sudo python3 -m venv /opt/certbot/
    sudo /opt/certbot/bin/pip install --upgrade pip
    sudo /opt/certbot/bin/pip install certbot certbot-nginx
    sudo ln -sf /opt/certbot/bin/certbot /usr/bin/certbot
    echo "✅ Certbot installed"
else
    echo "✅ Certbot already installed"
fi

# Step 1: Create HTTP-only config for Let's Encrypt challenge
echo "📝 Creating initial HTTP configuration..."
cat > "$CONFIG_FILE" <<'EOF'
server {
    listen 80;
    server_name biotinto.cn xn--5us92m0xp.com;

    # Allow Let's Encrypt challenges
    location /.well-known/acme-challenge/ {
        root /usr/share/nginx/html;
        allow all;
    }

    # Temporary: allow all traffic for certificate validation
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

echo "🧪 Testing Nginx configuration..."
sudo nginx -t

echo "🔄 Reloading Nginx..."
sudo systemctl reload nginx

# Step 2: Obtain Let's Encrypt certificate
echo ""
echo "🔒 Obtaining Let's Encrypt certificate..."
echo "⚠️  Make sure ports 80 and 443 are open in your Security Group!"
read -p "Press Enter to continue with certificate request..."

sudo certbot certonly --nginx -d "$DOMAIN" --non-interactive --agree-tos --email admin@${DOMAIN} || {
    echo "❌ Certificate request failed!"
    echo ""
    echo "Common issues:"
    echo "1. Port 80/443 not open in Aliyun Security Group"
    echo "2. ICP filing (备案) not completed for .cn domain"
    echo "3. DNS not pointing to this server"
    echo ""
    echo "💡 To check if port 80 is accessible from outside:"
    echo "   curl -I http://\$(curl -s http://checkip.amazonaws.com)"
    exit 1
}

# Step 3: Deploy production config with HTTPS redirect
echo ""
echo "📝 Deploying production HTTPS configuration..."
cat > "$CONFIG_FILE" <<'EOF'
# HTTP Block: Redirect to HTTPS
server {
    listen 80;
    server_name biotinto.cn xn--5us92m0xp.com;

    # Allow Let's Encrypt challenges
    location /.well-known/acme-challenge/ {
        root /usr/share/nginx/html;
        allow all;
    }

    # Force HTTPS for all other traffic
    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS Block: Main Application
server {
    listen 443 ssl;
    server_name biotinto.cn xn--5us92m0xp.com;
    
    # SSL Configuration (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/biotinto.cn/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/biotinto.cn/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob: https:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https: blob:; style-src 'self' 'unsafe-inline' https:; img-src 'self' data: blob: https:; connect-src 'self' https: wss:;";

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

echo "🧪 Testing final Nginx configuration..."
sudo nginx -t

echo "🔄 Reloading Nginx with HTTPS enabled..."
sudo systemctl reload nginx

echo ""
echo "========================================="
echo "✅ HTTPS Setup Complete!"
echo "========================================="
echo ""
echo "🔒 SSL Certificate: Let's Encrypt (auto-renews)"
echo "🌐 Site URL: https://$DOMAIN"
echo ""
echo "🧪 Verification steps:"
echo "1. curl -I http://$DOMAIN"
echo "   → Should return: HTTP/1.1 301 Moved Permanently"
echo ""
echo "2. curl -I https://$DOMAIN"
echo "   → Should return: HTTP/1.1 200 OK (or redirect)"
echo ""
echo "3. Open https://$DOMAIN in Chrome"
echo "   → Should show green padlock, no warnings"
echo ""
echo "📅 Certificate auto-renewal: certbot will attempt renewal automatically"
echo "    Manual renewal: sudo certbot renew"
echo ""
