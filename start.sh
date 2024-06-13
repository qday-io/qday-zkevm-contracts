#!/bin/bash

rm -rf ./out
# node docker/scripts/fund-accounts.js

npx hardhat run deployment/testnet/prepareTestnet.js --network localhost
rm -f .openzeppelin/unknown-31337.json && node deployment/1_createGenesis.js
npx hardhat run deployment/2_deployPolygonZKEVMDeployer.js --network localhost
npx hardhat run deployment/3_deployContracts.js --network localhost

sleep 10

mkdir out
mv ./deployment/genesis.json ./out/
mv ./deployment/deploy_output.json ./out/

