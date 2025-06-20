require('dotenv').config({ path: '../../.env' });
const fs = require('fs');
const { Wallet } = require('ethers');

// const mnemonic = 'test test test test test test test test test test test zero'; // 换成你的助记词
const mnemonic = process.env.MNEMONIC;
if (!mnemonic) {
  throw new Error('MNEMONIC is not set. Please set it in your .env file.');
}
const filePath = 'docker/scripts/deploy_parameters_docker.json';
const json = JSON.parse(fs.readFileSync(filePath, 'utf-8'));

// 统一地址
const mainAddr = Wallet.fromMnemonic(mnemonic, "m/44'/60'/0'/0/0").address;
// trustedSequencer 用第二个地址
const trustedSequencer = Wallet.fromMnemonic(mnemonic, "m/44'/60'/0'/0/1").address;
// trustedAggregator 用第三个地址
const trustedAggregator = Wallet.fromMnemonic(mnemonic, "m/44'/60'/0'/0/2").address;

// 替换字段
json.admin = mainAddr;
json.zkEVMOwner = mainAddr;
json.timelockAddress = mainAddr;
json.initialZkEVMDeployerOwner = mainAddr;
json.trustedSequencer = trustedSequencer;
json.trustedAggregator = trustedAggregator;

// 写回文件
fs.writeFileSync(filePath, JSON.stringify(json, null, 2));
console.log('替换完成:');
console.log('mainAddr:', mainAddr);
console.log('trustedSequencer:', trustedSequencer);
console.log('trustedAggregator:', trustedAggregator);