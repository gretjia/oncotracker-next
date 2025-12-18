#!/bin/bash

# Server Configuration
SERVER_IP="47.236.227.167"
USER="ecs-user"

echo "Connecting to OncoTracker Cloud Server (${SERVER_IP})..."
echo "==================================================="

# SSH with identity file
ssh -i ../oncoali.pem -o StrictHostKeyChecking=no ${USER}@${SERVER_IP}
