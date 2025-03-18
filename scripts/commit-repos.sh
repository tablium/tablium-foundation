#!/bin/bash

# Function to commit and push a repository
commit_and_push() {
    local repo_path=$1
    local repo_name=$2
    
    echo "Processing $repo_name..."
    cd "$repo_path"
    
    # Initialize git if not already initialized
    if [ ! -d ".git" ]; then
        git init
    fi
    
    # Remove existing remotes if any
    git remote | while read remote; do
        git remote remove "$remote"
    done
    
    # Add HTTPS remote
    git remote add origin "https://github.com/tablium/$repo_name.git"
    
    # Add all files
    git add .
    
    # Create initial commit
    git commit -m "Initial commit: Set up $repo_name repository structure"
    
    # Push to GitHub
    git push -u origin main || git push -u origin master
    
    cd - > /dev/null
    echo "Completed $repo_name"
}

# Core Services
commit_and_push "temp-repos/core/tablium-api-gateway" "tablium-api-gateway"
commit_and_push "temp-repos/core/tablium-auth-service" "tablium-auth-service"
commit_and_push "temp-repos/core/tablium-user-service" "tablium-user-service"
commit_and_push "temp-repos/core/tablium-wallet-service" "tablium-wallet-service"
commit_and_push "temp-repos/core/tablium-db-config" "tablium-db-config"

# Game Services
commit_and_push "temp-repos/game/tablium-game-state" "tablium-game-state"
commit_and_push "temp-repos/game/tablium-realtime" "tablium-realtime"
commit_and_push "temp-repos/game/tablium-game-engines" "tablium-game-engines"
commit_and_push "temp-repos/game/tablium-tournament-service" "tablium-tournament-service"
commit_and_push "temp-repos/game/tablium-matchmaking-service" "tablium-matchmaking-service"
commit_and_push "temp-repos/game/tablium-leaderboard-service" "tablium-leaderboard-service"
commit_and_push "temp-repos/game/tablium-replay-service" "tablium-replay-service"

# Blockchain Services
commit_and_push "temp-repos/blockchain/tablium-token-contract" "tablium-token-contract"
commit_and_push "temp-repos/blockchain/tablium-game-contract" "tablium-game-contract"
commit_and_push "temp-repos/blockchain/tablium-tournament-contract" "tablium-tournament-contract"

# Support Services
commit_and_push "temp-repos/support/tablium-analytics-service" "tablium-analytics-service"
commit_and_push "temp-repos/support/tablium-notification-service" "tablium-notification-service"
commit_and_push "temp-repos/support/tablium-ai-engine" "tablium-ai-engine"

# Frontend
commit_and_push "temp-repos/frontend/tablium-frontend" "tablium-frontend"

# Infrastructure
commit_and_push "temp-repos/infrastructure/tablium-k8s" "tablium-k8s"
commit_and_push "temp-repos/infrastructure/tablium-terraform" "tablium-terraform"
commit_and_push "temp-repos/infrastructure/tablium-ci-cd" "tablium-ci-cd"
commit_and_push "temp-repos/infrastructure/tablium-monitoring" "tablium-monitoring"
commit_and_push "temp-repos/infrastructure/tablium-go-service-discovery" "tablium-go-service-discovery"
commit_and_push "temp-repos/infrastructure/tablium-py-service-discovery" "tablium-py-service-discovery"
commit_and_push "temp-repos/infrastructure/tablium-go-errors" "tablium-go-errors"
commit_and_push "temp-repos/infrastructure/tablium-py-errors" "tablium-py-errors"
commit_and_push "temp-repos/infrastructure/tablium-ts-errors" "tablium-ts-errors"
commit_and_push "temp-repos/infrastructure/tablium-rs-errors" "tablium-rs-errors"
commit_and_push "temp-repos/infrastructure/tablium-sol-errors" "tablium-sol-errors"
commit_and_push "temp-repos/infrastructure/tablium-go-rabbitmq" "tablium-go-rabbitmq"
commit_and_push "temp-repos/infrastructure/tablium-py-rabbitmq" "tablium-py-rabbitmq"
commit_and_push "temp-repos/infrastructure/tablium-integration" "tablium-integration"
commit_and_push "temp-repos/infrastructure/tablium-test-infrastructure" "tablium-test-infrastructure"

echo "All repositories have been committed and pushed to GitHub!" 