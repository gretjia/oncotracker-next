#!/bin/bash
# Supabase Setup Script
# Run this on your ECS instance after running 01-setup-server.sh

set -e

echo "========================================="
echo "Supabase Setup"
echo "========================================="

# Navigate to Supabase directory
cd /opt/supabase

# Clone Supabase if not already cloned
if [ ! -d "supabase" ]; then
    echo "📥 Cloning Supabase repository..."
    git clone --depth 1 https://github.com/supabase/supabase
else
    echo "✅ Supabase repository already exists"
fi

cd supabase/docker

# Copy example environment file
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from example..."
    cp .env.example .env
    
    echo ""
    echo "⚠️  IMPORTANT: You need to configure the .env file with secure values!"
    echo ""
    echo "Required changes in .env:"
    echo "1. POSTGRES_PASSWORD - Set a strong password"
    echo "2. JWT_SECRET - Generate with: openssl rand -base64 32"
    echo "3. ANON_KEY - Generate at https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys"
    echo "4. SERVICE_ROLE_KEY - Generate at the same URL"
    echo "5. SITE_URL - Set to your domain (e.g., https://yourdomain.com)"
    echo "6. STUDIO_DEFAULT_ORGANIZATION - Set your organization name"
    echo "7. STUDIO_DEFAULT_PROJECT - Set your project name"
    echo ""
    echo "Edit the file with: nano .env"
    echo ""
    read -p "Press Enter after you've configured the .env file..."
else
    echo "✅ .env file already exists"
fi

# Pull Docker images
echo "🐳 Pulling Docker images (this may take a while)..."
docker-compose pull

# Start Supabase
echo "🚀 Starting Supabase services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check service status
echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "========================================="
echo "✅ Supabase setup complete!"
echo "========================================="
echo ""
echo "Supabase is now running on:"
echo "  - API: http://localhost:54321"
echo "  - Studio: http://localhost:54323"
echo "  - Database: postgresql://postgres:postgres@localhost:54322/postgres"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"
echo "To restart: docker-compose restart"
echo ""
