#!/bin/bash
# Next.js Application Deployment Script
# Run this on your LOCAL machine to build and deploy to ECS

set -e

# Configuration - UPDATE THESE VALUES
ECS_IP="47.236.227.167"  # ECS Public IP
ECS_USER="ecs-user"        # SSH user
DEPLOY_PATH="/opt/oncotracker"

echo "========================================="
echo "OncoTracker Deployment"
echo "========================================="

# Check if ECS_IP is set
if [ "$ECS_IP" = "YOUR_ECS_PUBLIC_IP" ]; then
    echo "❌ Error: Please update ECS_IP in this script with your actual ECS public IP"
    exit 1
fi

# Build Next.js application
# Build Next.js application
echo "🔨 Building Next.js application..."
# Check for .env.production and source it to override .env.local
if [ -f ".env.production" ]; then
    echo "Using .env.production variables for build..."
    set -a
    source .env.production
    set +a
fi
npm run build

# Create deployment package
echo "📦 Creating deployment package..."
tar -czf oncotracker-deploy.tar.gz \
    .next \
    package.json \
    package-lock.json \
    public \
    next.config.ts

# Upload to ECS
echo "📤 Uploading to ECS..."
scp -i ../oncoali.pem -o StrictHostKeyChecking=no oncotracker-deploy.tar.gz ${ECS_USER}@${ECS_IP}:${DEPLOY_PATH}/

# Upload environment file (you'll need to create this)
if [ -f ".env.production" ]; then
    echo "📤 Uploading environment variables..."
    scp -i ../oncoali.pem -o StrictHostKeyChecking=no .env.production ${ECS_USER}@${ECS_IP}:${DEPLOY_PATH}/.env.local
else
    echo "⚠️  Warning: .env.production not found. You'll need to create it on the server."
fi

# SSH into server and deploy
echo "🚀 Deploying on server..."
ssh -i ../oncoali.pem -o StrictHostKeyChecking=no ${ECS_USER}@${ECS_IP} << 'ENDSSH'
cd /opt/oncotracker

# Extract deployment package
echo "📦 Extracting files..."
tar -xzf oncotracker-deploy.tar.gz
rm oncotracker-deploy.tar.gz

# Install dependencies
echo "📥 Installing dependencies..."
npm ci --production

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'oncotracker-next',
    script: 'node_modules/next/dist/bin/next',
    args: 'start --hostname 0.0.0.0',
    cwd: '/opt/oncotracker',
    instances: 2,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      HOSTNAME: '0.0.0.0'
    }
  }]
}
EOF

# Stop existing PM2 process (if any)
pm2 delete oncotracker-next 2>/dev/null || true

# Start application with PM2
echo "🚀 Starting application..."
pm2 start ecosystem.config.js
pm2 save

# Show status
pm2 status

echo ""
echo "✅ Application deployed successfully!"
echo ""
ENDSSH

# Clean up local deployment package
rm oncotracker-deploy.tar.gz

echo ""
echo "========================================="
echo "✅ Deployment complete!"
echo "========================================="
echo ""
echo "Your application is now running on:"
echo "  http://${ECS_IP}:3000"
echo ""
echo "Next steps:"
echo "1. Configure Nginx reverse proxy (run 04-setup-nginx.sh on server)"
echo "2. Set up SSL certificate"
echo "3. Configure your domain name"
echo ""
