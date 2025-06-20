#!/bin/bash

# 获取脚本实际所在目录的上两级（即项目根目录）
ENV_PATH="$(cd "$(dirname "$0")/../.." && pwd)/.env"
if [ -f "$ENV_PATH" ]; then
  set -a
  . "$ENV_PATH"
  set +a
else
  echo "Error: $ENV_PATH not found. Please create .env in project root."
  exit 1
fi

# Variables
KEY="mykey"
CHAINID="ethermint_9000-1"
MONIKER="localtestnet"
KEYRING="test"
KEYALGO="eth_secp256k1"

# Import keys from mnemonic
if [ -z "$MNEMONIC" ]; then
  echo "Error: MNEMONIC is not set. Please set it in your .env file."
  exit 1
fi

# Validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "wget not installed."; exit 1; }

# Check if ethermintd directory exists and exit if it does
[ -d ~/.ethermintd ] && { echo >&2 "Error: ~/.ethermintd directory already exists. Please remove it manually if you want to proceed."; exit 1; }

# Download and prepare ethermintd binary
cd docker
wget https://github.com/qday-io/qday-da-node/releases/download/v0.1.1/qday-node-deploy.tar.gz
tar xf qday-node-deploy.tar.gz
mv qday-node-deploy/bin/ethermintd .

# Make install
./ethermintd config keyring-backend $KEYRING
./ethermintd config chain-id $CHAINID

# Set moniker and chain-id for Ethermint (Moniker can be anything, chain-id must be an integer)
./ethermintd init $MONIKER --chain-id $CHAINID


echo "$MNEMONIC" | ./ethermintd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO --recover

# Change parameter token denominations to aphoton
jq '.app_state["staking"]["params"]["bond_denom"]="aphoton"' "$HOME"/.ethermintd/config/genesis.json > "$HOME"/.ethermintd/config/tmp_genesis.json && mv "$HOME"/.ethermintd/config/tmp_genesis.json "$HOME"/.ethermintd/config/genesis.json
jq '.app_state["crisis"]["constant_fee"]["denom"]="aphoton"' "$HOME"/.ethermintd/config/genesis.json > "$HOME"/.ethermintd/config/tmp_genesis.json && mv "$HOME"/.ethermintd/config/tmp_genesis.json "$HOME"/.ethermintd/config/genesis.json
jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="aphoton"' "$HOME"/.ethermintd/config/genesis.json > "$HOME"/.ethermintd/config/tmp_genesis.json && mv "$HOME"/.ethermintd/config/tmp_genesis.json "$HOME"/.ethermintd/config/genesis.json
jq '.app_state["mint"]["params"]["mint_denom"]="aphoton"' "$HOME"/.ethermintd/config/genesis.json > "$HOME"/.ethermintd/config/tmp_genesis.json && mv "$HOME"/.ethermintd/config/tmp_genesis.json "$HOME"/.ethermintd/config/genesis.json

# Set gas limit in genesis
jq '.consensus_params["block"]["max_gas"]="20000000"' "$HOME"/.ethermintd/config/genesis.json > "$HOME"/.ethermintd/config/tmp_genesis.json && mv "$HOME"/.ethermintd/config/tmp_genesis.json "$HOME"/.ethermintd/config/genesis.json

# Allocate genesis accounts (cosmos formatted addresses)
./ethermintd add-genesis-account $KEY 100000000000000000000000000aphoton --keyring-backend $KEYRING

# Sign genesis transaction
./ethermintd gentx $KEY 1000000000000000000000aphoton --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
./ethermintd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
./ethermintd validate-genesis

# disable produce empty block and enable prometheus metrics
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/create_empty_blocks = true/create_empty_blocks = false/g' "$HOME"/.ethermintd/config/config.toml
    sed -i '' 's/prometheus = false/prometheus = true/' "$HOME"/.ethermintd/config/config.toml
    sed -i '' 's/prometheus-retention-time = 0/prometheus-retention-time  = 1000000000000/g' "$HOME"/.ethermintd/config/app.toml
    sed -i '' 's/enabled = false/enabled = true/g' "$HOME"/.ethermintd/config/app.toml
else
    sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' "$HOME"/.ethermintd/config/config.toml
    sed -i 's/prometheus = false/prometheus = true/' "$HOME"/.ethermintd/config/config.toml
    sed -i 's/prometheus-retention-time  = "0"/prometheus-retention-time  = "1000000000000"/g' "$HOME"/.ethermintd/config/app.toml
    sed -i 's/enabled = false/enabled = true/g' "$HOME"/.ethermintd/config/app.toml
fi

if [[ $1 == "pending" ]]; then
    echo "pending mode is on, please wait for the first block committed."
    if [[ $OSTYPE == "darwin"* ]]; then
        sed -i '' 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i '' 's/timeout_propose = "3s"/timeout_propose = "30s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i '' 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i '' 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i '' 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i '' 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i '' 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i '' 's/timeout_commit = "5s"/timeout_commit = "150s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i '' 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' "$HOME"/.ethermintd/config/config.toml
    else
        sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' "$HOME"/.ethermintd/config/config.toml
        sed -i 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' "$HOME"/.ethermintd/config/config.toml
    fi
fi

# Clean up
rm -fr qday-node-deploy qday-node-deploy.tar.gz ethermintd

# Move ethermintd directory to docker folder
mv ~/.ethermintd ./ethermintData