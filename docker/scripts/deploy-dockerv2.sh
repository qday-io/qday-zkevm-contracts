#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting deployment process..."

# Initialize ethermint
echo "📦 Initializing ethermint..."
./docker/scripts/init-ethermint.sh

# Remove deploymentOutput directory if it exists
echo "🧹 Cleaning up previous deployment output..."
rm -fr docker/deploymentOutput

# Start ethermint
echo "🔧 Starting ethermint node..."
docker compose -f docker/docker-compose.yml up -d
echo "⏳ Waiting for node to be ready..."
sleep 30

# Build parameters
echo "⚙️  Building deployment parameters..."
node docker/scripts/build_parameters.js

# Fund accounts
echo "💰 Funding accounts..."
node docker/scripts/fund-accounts.js

# Copy deploy_parameters_docker.json and genesis_docker.json to deployment directory
echo "📋 Copying configuration files..."
cp docker/scripts/deploy_parameters_docker.json deployment/deploy_parameters.json
cp docker/scripts/genesis_docker.json deployment/genesis.json

# Run deploy script
echo "🏗️  Deploying contracts..."
npm run deploy:testnet:ZkEVM:localhost

# Get latest block number and update deploy_output.json
echo "📊 Getting latest block number..."
node docker/scripts/get-latest-block.js

# 导出 ethermint 地址和私钥
#bash docker/scripts/ethermint-key-export.sh

# Create deploymentOutput directory
echo "📁 Creating deployment output directory..."
mkdir -p docker/deploymentOutput

# Move deploy_output.json to deploymentOutput directory
echo "📄 Moving deployment output..."
cp deployment/deploy_output.json docker/deploymentOutput/

# Stop ethermint
echo "🛑 Stopping ethermint node..."
docker compose -f docker/docker-compose.yml down

# Build docker image
echo "🐳 Building docker image..."
sudo chown -R $(id -u):$(id -g) docker/ethermintData
docker build -t ethermint-zkevm-contracts -f docker/Dockerfile .

# Remove files if they exist
echo "🧹 Cleaning up temporary files..."
rm -fr docker/ethermintData

echo "✅ Deployment process completed successfully!"
echo "📦 Docker image: ethermint-zkevm-contracts"
echo "📄 Deployment output: docker/deploymentOutput/deploy_output.json"