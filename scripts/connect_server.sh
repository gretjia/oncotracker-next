#!/bin/bash

# Configuration
SERVER_IP="8.222.155.67"
USER="root"
# KEY_FILE=""  # Uncomment and set path if you use a specific key file

echo "🔌 Connecting to OncoTracker Server ($SERVER_IP)..."

# Try to connect
ssh -i deployment/oncotracker.pem -o StrictHostKeyChecking=no ${USER}@${SERVER_IP}
