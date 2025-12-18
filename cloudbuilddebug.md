# OncoTracker Cloud Deployment & Debugging Guide

This document preserves the critical fixes and configurations applied during the deployment of OncoTracker v0.5 to an Aliyun ECS Linux environment. Use this as a reference for future rebuilds or server migrations.

## 1. Environment Preparation

### Swap Space (Crucial for 4GB RAM)

Next.js builds are memory-intensive. Without swap, the build will likely fail with `Killed` or `Error: write EPIPE`.

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/hosts
```

### Internal DNS Resolution

The application must be able to resolve its own domain internally to avoid SSL hostname mismatches and routing errors.

- **File**: `/etc/hosts`
- **Add**: `127.0.0.1 biotinto.cn`

---

## 2. Next.js Standalone Deployment

The project uses `output: 'standalone'` in `next.config.ts`. Next.js DOES NOT automatically copy static assets to the standalone folder.

### Mandatory Copy Steps

After running `npm run build`, you MUST manually copy these directories:

```bash
cp -r public .next/standalone/
cp -r .next/static .next/standalone/.next/
```

Failure to do this will result in 404s for all CSS, JS, and image assets.

---

## 3. PM2 Process Configuration

The application requires specific environment variables and flags to handle self-signed certificates and internal routing.

### Startup Command

```bash
NODE_TLS_REJECT_UNAUTHORIZED=0 \
NEXT_PUBLIC_SUPABASE_URL=https://biotinto.cn/supabase \
NEXT_PUBLIC_SITE_URL=https://biotinto.cn \
pm2 start "node .next/standalone/server.js" --name "oncotracker" --cwd /opt/oncotracker
```

- **`NODE_TLS_REJECT_UNAUTHORIZED=0`**: Essential if using self-hosted Supabase with a self-signed certificate. It prevents `fetch failed` errors during server-side auth/data calls.
- **`NEXT_PUBLIC_SUPABASE_URL`**: Must use the domain name (`biotinto.cn`), not the IP, to match the SSL certificate and Kong routing.

---

## 4. Supabase Storage Synchronization

**DO NOT** copy files directly into the Docker volumes (e.g., `/var/lib/storage/...`). This leads to `ENODATA` errors (Extended Attribute mismatch between macOS/Linux) and missing database metadata.

### Canonical Migration Pattern

1. **Metadata**: Sync the `storage.buckets` and `storage.objects` tables via SQL dump/load.
2. **Files**: If migrating from macOS to Linux, use a Node.js script to re-upload files via the API to ensure correct filesystem attributes:

    ```javascript
    const { createClient } = require('@supabase/supabase-js');
    const supabase = createClient(URL, KEY);
    await supabase.storage.from('patient-data').upload(name, content, { upsert: true });
    ```

### Storage Directory Structure (Self-Hosted)

The default self-hosted Supabase storage volume expects a nested structure:
`/volumes/storage/stub/stub/[bucket_name]/[object_id]/[version]`

---

## 5. Known Issues & Fixes

| Issue | Root Cause | Fix |
|-------|------------|-----|
| Missing Styles on Production | Tailwind `@import` missing | Ensure `@import "tailwindcss";` is at the top of `globals.css` |
| `Bucket not found` | Hostname mismatch | Use Domain name in `SUPABASE_URL` and update `/etc/hosts` |
| `ENODATA` (500 Error) | Missing/Corrupt xattrs| Re-upload files through Supabase API, don't copy via SFTP directly to volumes |
| `fetch failed` (Login) | SSL Certificate | Set `NODE_TLS_REJECT_UNAUTHORIZED=0` |

---
*Last Updated: 2025-12-18*
