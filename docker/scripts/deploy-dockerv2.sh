#!/bin/bash

# Initialize ethermint
./docker/scripts/init-ethermint.sh

# Remove deploymentOutput directory if it exists
rm -fr docker/deploymentOutput

# Start ethermint
docker compose -f docker/docker-compose.yml up -d
sleep 30

# Build parameters
node docker/scripts/build_parameters.js

# Fund accounts
node docker/scripts/fund-accounts.js

# Copy deploy_parameters_docker.json and genesis_docker.json to deployment directory
cp docker/scripts/deploy_parameters_docker.json deployment/deploy_parameters.json
cp docker/scripts/genesis_docker.json deployment/genesis.json

# Run deploy script
npm run deploy:testnet:ZkEVM:localhost

# Create deploymentOutput directory
mkdir docker/deploymentOutput

# Move deploy_output.json to deploymentOutput directory
mv deployment/deploy_output.json docker/deploymentOutput
cp docker/scripts/deploy_parameters_docker.json docker/deploymentOutput/deploy_parameters.json
cp docker/scripts/genesis_docker.json docker/deploymentOutput/genesis.json

# Stop ethermint
docker compose -f docker/docker-compose.yml down

# Build docker image
sudo chown -R $(id -u):$(id -g) docker/ethermintData
docker build -t ethermint-zkevm-contracts -f docker/Dockerfile .

# Remove files if they exist
rm -fr docker/ethermintData deployment/deploy_parameters.json