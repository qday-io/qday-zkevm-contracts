#!/bin/bash

echo "Cleaning hardhat cache..."
rm -rf cache artifacts

echo "Cleaning node_modules and lock file..."
rm -rf node_modules package-lock.json

echo "Cleaning npm cache..."
npm cache clean --force

echo "Reinstalling dependencies..."
npm install