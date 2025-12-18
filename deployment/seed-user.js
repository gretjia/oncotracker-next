const { createClient } = require('@supabase/supabase-js');

// Allow self-signed certificates
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const SUPABASE_URL = 'https://47.236.227.167/supabase';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIiwiaXNzIjoic3VwYWJhc2UtZGVtbyIsImlhdCI6MTc2NTk3MzgwNywiZXhwIjoyMDgxMzMzODA3fQ.Xx72XXYmhSun7itXn6ul3HEg3CBupM1kg8W083wGYnI';

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

async function seedUser() {
    const email = 'doctor@oncotracker.com';
    const password = 'Password@123';

    console.log(`Creating user: ${email}...`);

    const { data, error } = await supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { role: 'doctor' }
    });

    if (error) {
        console.error('Error creating user:', error.message);
        if (error.message.includes('already registered')) {
            console.log('User already exists. Skipping.');
        } else {
            process.exit(1);
        }
    } else {
        console.log('✅ User created successfully:', data.user.id);
    }
}

seedUser();
