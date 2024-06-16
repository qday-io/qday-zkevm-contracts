#!/bin/bash

rm -rf ./out
rm -rf .openzeppelin
rm -f deployment/deploy_ongoing.json
# node docker/scripts/fund-accounts.js

npx hardhat run deployment/testnet/prepareTestnet.js --network abenode
rm -f .openzeppelin/unknown-31337.json && node deployment/1_createGenesis.js
npx hardhat run deployment/2_deployPolygonZKEVMDeployer.js --network abenode
npx hardhat run deployment/3_deployContracts.js --network abenode

sleep 10

mkdir out
mv ./deployment/genesis.json ./out/
mv ./deployment/deploy_output.json ./out/

