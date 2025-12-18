# OncoTracker Deployment Guide - Alibaba Cloud Singapore

## 🔑 Current Production Server Access

**Server:** `biotinto.cn`  
**User:** `ecs-user` (NOT `root`)  
**SSH Key:** `./oncoali.pem` (in repository root)

```bash
# Connect to production server
ssh -i ../oncoali.pem ecs-user@biotinto.cn

# Quick status check
ssh -i ../oncoali.pem ecs-user@biotinto.cn "pm2 status; systemctl status nginx --no-pager"
```

> **Note:** See [`SERVER_ACCESS.md`](../../SERVER_ACCESS.md) in repository root for detailed access guide and common commands.

## HTTPS Configuration (IMPORTANT)

**Production URL:** `https://biotinto.cn` (with Let's Encrypt certificate)

### SSL Certificate Status

- **Certificate:** Let's Encrypt (trusted, auto-renews)
- **Expires:** Check with `ssh -i ../oncoali.pem ecs-user@biotinto.cn "sudo certbot certificates"`
- **Auto-renewal:** Configured via certbot systemd timer

### If HTTPS Issues Occur

**Symptom:** Browser shows "Not Secure" or falls back to HTTP even when typing `https://`

**Root Cause:** Malformed Nginx configuration mixing HTTP/HTTPS listeners in same server block

**Solution:**

```bash
# On server, run the automated fix script
ssh -i ../oncoali.pem ecs-user@biotinto.cn
sudo /home/ecs-user/fix-nginx-ssl.sh
```

**Manual fix:** Use the corrected configuration in `deployment/oncotracker_idn.conf`

**Files:**

- `fix-nginx-ssl.sh` - Automated Let's Encrypt installation
- `oncotracker_idn.conf` - Corrected dual-block Nginx configuration

---

## Quick Start

You've created an ECS instance in Singapore. Follow these steps to deploy OncoTracker:

### Step 1: Configure Security Groups

In your Alibaba Cloud console, ensure these ports are open:

- **Port 22** - SSH access
- **Port 80** - HTTP
- **Port 443** - HTTPS (for SSL)
- **Port 3000** - Next.js (optional, for direct access)
- **Port 54323** - Supabase Studio (optional, for admin access)

### Step 2: Connect to Your ECS Instance

```bash
# Get your ECS public IP from Alibaba Cloud console
ssh root@YOUR_ECS_PUBLIC_IP
```

### Step 3: Run Server Setup Script

On your LOCAL machine, upload the setup script:

```bash
cd /Users/zephryj/Documents/oncotracker/oncotracker\ v0.5/oncotracker-next

# Upload setup script to ECS
scp deployment/01-setup-server.sh root@YOUR_ECS_IP:/root/

# SSH into ECS and run it
ssh root@YOUR_ECS_IP
chmod +x /root/01-setup-server.sh
./01-setup-server.sh
```

This will install:

- Docker & Docker Compose
- Node.js 18
- Nginx
- PM2
- Git

### Step 4: Setup Supabase

Still on your ECS instance:

```bash
# Upload Supabase setup script
# (On local machine)
scp deployment/02-setup-supabase.sh root@YOUR_ECS_IP:/root/

# (On ECS)
chmod +x /root/02-setup-supabase.sh
./02-setup-supabase.sh
```

**IMPORTANT**: When prompted, edit the `.env` file with secure values:

```bash
cd /opt/supabase/supabase/docker
nano .env

# Update these values:
# - POSTGRES_PASSWORD (create a strong password)
# - JWT_SECRET (generate with: openssl rand -base64 32)
# - ANON_KEY (see instructions in script output)
# - SERVICE_ROLE_KEY (see instructions in script output)
# - SITE_URL (your domain or http://YOUR_ECS_IP)
```

### Step 5: Migrate Your Local Supabase Data

Export data from your local Supabase:

```bash
# On your LOCAL machine
cd /Users/zephryj/Documents/oncotracker/oncotracker\ v0.5/oncotracker-next

# Export your local Supabase schema and data
# (You'll need to do this through Supabase Studio or pg_dump)
```

Then import to your ECS Supabase instance.

### Step 6: Configure Production Environment

On your LOCAL machine:

```bash
# Copy the template
cp deployment/.env.production.template .env.production

# Edit with your ECS details
nano .env.production

# Update:
# - YOUR_ECS_IP with your actual IP
# - ANON_KEY and SERVICE_ROLE_KEY from Supabase .env
```

### Step 7: Deploy Next.js Application

On your LOCAL machine:

```bash
# Edit the deployment script with your ECS IP
nano deployment/03-deploy-app.sh
# Change: ECS_IP="YOUR_ECS_PUBLIC_IP"

# Make it executable
chmod +x deployment/03-deploy-app.sh

# Run deployment
./deployment/03-deploy-app.sh
```

This will:

1. Build your Next.js app
2. Upload to ECS
3. Install dependencies
4. Start with PM2

### Step 8: Configure Nginx

On your ECS instance:

```bash
# Upload Nginx setup script
# (On local machine)
scp deployment/04-setup-nginx.sh root@YOUR_ECS_IP:/root/

# (On ECS)
chmod +x /root/04-setup-nginx.sh
./04-setup-nginx.sh
```

Follow the prompts to:

- Enter your domain name (or skip for IP access)
- Optionally set up SSL with Let's Encrypt

### Step 9: Verify Deployment

Visit your application:

- **Without domain**: `http://YOUR_ECS_IP`
- **With domain**: `https://yourdomain.com`

Check that:

- ✅ Application loads
- ✅ Login works
- ✅ Data upload works
- ✅ Visualization displays correctly

---

## Troubleshooting

### Application won't start

```bash
# On ECS, check PM2 logs
pm2 logs oncotracker-next

# Check if port 3000 is in use
sudo lsof -i :3000
```

### Supabase not accessible

```bash
# Check Docker containers
cd /opt/supabase/supabase/docker
docker-compose ps

# View logs
docker-compose logs -f
```

### Nginx errors

```bash
# Check Nginx status
sudo systemctl status nginx

# View error logs
sudo tail -f /var/log/nginx/error.log
```

---

## Useful Commands

### PM2 Management

```bash
pm2 status              # View app status
pm2 logs                # View logs
pm2 restart all         # Restart app
pm2 stop all            # Stop app
pm2 delete all          # Remove app from PM2
```

### Docker Management

```bash
cd /opt/supabase/supabase/docker
docker-compose ps       # View services
docker-compose logs -f  # View logs
docker-compose restart  # Restart all services
docker-compose down     # Stop all services
docker-compose up -d    # Start all services
```

### Nginx Management

```bash
sudo systemctl status nginx    # Check status
sudo systemctl restart nginx   # Restart
sudo nginx -t                  # Test configuration
```

---

## Next Steps After Deployment

1. **Set up monitoring** - Use Alibaba Cloud CloudMonitor
2. **Configure backups** - Set up automated database backups
3. **Set up CI/CD** - Automate deployments with GitHub Actions
4. **Performance tuning** - Optimize based on usage patterns
5. **Security hardening** - Set up firewall rules, fail2ban, etc.
