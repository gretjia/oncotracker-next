#!/bin/bash
cd /opt/supabase/supabase/docker

# Reset to example
cp .env.example .env

# Helper to escape special chars for sed
escape_sed() {
    echo "$1" | sed -e 's/[]\/$*.^[]/\\&/g'
}

MW_JWT="WgTPS4rGCvUYrMioLys2vVvxLfYk4SeJQJ8Bqh8G8aoPOA_78LV7lQ"
MW_ANON="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlLWRlbW8iLCJpYXQiOjE3NjU5NzM4MDcsImV4cCI6MjA4MTMzMzgwN30.jxPTThuoooFVnpPcXmCLWag8YeXT7mnJWTW2l1hA_vo"
MW_SERVICE="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIiwiaXNzIjoic3VwYWJhc2UtZGVtbyIsImlhdCI6MTc2NTk3MzgwNywiZXhwIjoyMDgxMzMzODA3fQ.Xx72XXYmhSun7itXn6ul3HEg3CBupM1kg8W083wGYnI"
MW_PASS="OncoTrackerDB_Secur3_2025!"
MW_URL="https://biotinto.cn"

# Replace values
sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$MW_PASS|" .env
sed -i "s|^JWT_SECRET=.*|JWT_SECRET=$MW_JWT|" .env
sed -i "s|^ANON_KEY=.*|ANON_KEY=$MW_ANON|" .env
sed -i "s|^SERVICE_ROLE_KEY=.*|SERVICE_ROLE_KEY=$MW_SERVICE|" .env
sed -i "s|^SITE_URL=.*|SITE_URL=$MW_URL|" .env
sed -i "s|^API_EXTERNAL_URL=.*|API_EXTERNAL_URL=https://biotinto.cn|" .env
sed -i "s|^SUPABASE_PUBLIC_URL=.*|SUPABASE_PUBLIC_URL=https://biotinto.cn|" .env

# Set dashboard auth
sed -i "s|^DASHBOARD_USERNAME=.*|DASHBOARD_USERNAME=admin|" .env
sed -i "s|^DASHBOARD_PASSWORD=.*|DASHBOARD_PASSWORD=OncoTrackerAdmin2025!|" .env

echo "✅ .env configured successfully"
