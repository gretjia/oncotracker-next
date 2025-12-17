const { createClient } = require('@supabase/supabase-js');

// Allow self-signed certificates
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const SUPABASE_URL = 'https://8.222.155.67/supabase';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q';

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
