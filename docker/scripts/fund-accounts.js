/* eslint-disable no-await-in-loop */

const ethers = require('ethers');
require('dotenv').config();

const MNEMONIC = process.env.MNEMONIC;
const DEFAULT_NUM_ACCOUNTS = 20;

async function main() {
    if (!MNEMONIC) {
        throw new Error('MNEMONIC is not set. Please set it in your .env file.');
    }
    const currentProvider = new ethers.providers.JsonRpcProvider('http://localhost:8545');
    const signerNode = await currentProvider.getSigner();
    const numAccountsToFund = process.env.NUM_ACCOUNTS || DEFAULT_NUM_ACCOUNTS;

    console.log('signerNode.getAddress()', await signerNode.getAddress());

    for (let i = 0; i < numAccountsToFund; i++) {
        const pathWallet = `m/44'/60'/0'/0/${i}`;
        const accountWallet = ethers.Wallet.fromMnemonic(MNEMONIC, pathWallet);
        const params = [{
            from: await signerNode.getAddress(),
            to: accountWallet.address,
            value: '0x3635C9ADC5DEA00000',
        }];
        const tx = await currentProvider.send('eth_sendTransaction', params);
        if (i === numAccountsToFund - 1) {
            await currentProvider.waitForTransaction(tx);
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
