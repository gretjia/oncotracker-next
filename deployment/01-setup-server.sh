#!/bin/bash
# OncoTracker ECS Server Setup Script - Alibaba Cloud Linux
# Run this script on your Alibaba Cloud ECS instance (Singapore)

set -e  # Exit on error

echo "========================================="
echo "OncoTracker ECS Server Setup"
echo "Alibaba Cloud Linux 3"
echo "========================================="

# Update system packages
echo "📦 Updating system packages..."
yum update -y

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
    systemctl start docker || true
fi

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

# Install Node.js 18.x
echo "📗 Installing Node.js 18..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs
    echo "✅ Node.js installed: $(node --version)"
else
    echo "✅ Node.js already installed: $(node --version)"
fi

# Install Nginx
echo "🌐 Installing Nginx..."
if ! command -v nginx &> /dev/null; then
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "✅ Nginx installed"
else
    echo "✅ Nginx already installed"
    systemctl start nginx || true
fi

# Install PM2 globally
echo "⚙️  Installing PM2..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
    echo "✅ PM2 installed"
else
    echo "✅ PM2 already installed"
fi

# Install Git (if not already installed)
echo "📚 Checking Git..."
if ! command -v git &> /dev/null; then
    yum install -y git
    echo "✅ Git installed"
else
    echo "✅ Git already installed"
fi

# Create application directory
echo "📁 Creating application directory..."
mkdir -p /opt/oncotracker
chown -R ecs-user:users /opt/oncotracker
chmod 755 /opt/oncotracker

# Create Supabase directory
echo "📁 Creating Supabase directory..."
mkdir -p /opt/supabase
chown -R ecs-user:users /opt/supabase
chmod 755 /opt/supabase

echo ""
echo "========================================="
echo "✅ Server setup complete!"
echo "========================================="
echo ""
echo "Installed versions:"
echo "  - Docker: $(docker --version)"
echo "  - Docker Compose: $(docker-compose --version)"
echo "  - Node.js: $(node --version)"
echo "  - npm: $(npm --version)"
echo "  - Nginx: $(nginx -v 2>&1)"
echo "  - PM2: $(pm2 --version)"
echo ""
echo "Next steps:"
echo "1. Run: bash /root/02-setup-supabase.sh"
echo "2. Deploy your Next.js application"
echo ""
