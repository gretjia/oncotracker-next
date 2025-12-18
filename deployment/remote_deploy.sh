#!/bin/bash
set -e
cd /opt/oncotracker

echo "📦 Extracting files..."
tar -xzf oncotracker-deploy.tar.gz
rm oncotracker-deploy.tar.gz

echo "📥 Installing dependencies..."
npm ci --production

echo "⚙️ Creating PM2 config..."
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

# Restart PM2
pm2 delete oncotracker-next 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save

echo "✅ Deployment Finalized!"
