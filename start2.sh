#!/bin/bash

rm -rf ./out
rm -rf .openzeppelin
rm -f deployment/deploy_ongoing.json
# node docker/scripts/fund-accounts.js

# clean
echo "clean workspace start"
sh clean.sh

echo "clean finished"

# deploy
echo "deploy start"
sh docker/scripts/deploy-dockerv2.sh

echo "deploy finished"


sleep 10

mkdir out
mv ./deployment/genesis.json ./out/
mv ./deployment/deploy_output.json ./out/
mv ./deployment/deploy_parameters.json ./out/

