require('dotenv').config();
require('@nomiclabs/hardhat-waffle');
require('hardhat-gas-reporter');
require('solidity-coverage');
require('@nomiclabs/hardhat-etherscan');
require('@openzeppelin/hardhat-upgrades');
require('hardhat-dependency-compiler');
require("hardhat-function-signatures");
require('./task/PolygonZkEVM');
require('./task/common');
require('./task/ERC20PermitMock');
require('./task/PolygonZkEVMGlobalExitRoot');
require('./task/PolygonZkEVMTimelock');
// require('./docker/scripts/fund-accounts');

const DEFAULT_MNEMONIC = process.env.MNEMONIC;

if (!process.env.MNEMONIC) {
  throw new Error('MNEMONIC is not set. Please set it in your .env file.');
}

/*
 * You need to export an object to set up your config
 * Go to https://hardhat.org/config/ to learn more
 */

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    dependencyCompiler: {
        paths: [
            '@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol',
            '@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol',
            '@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol',
        ], // ,
        // keep: true
    },
    solidity: {
        compilers: [
            {
                version: '0.8.13',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 999999,
                    },
                },
            },
            {
                version: '0.6.11',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 999999,
                    },
                },
            },
            {
                version: '0.5.12',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 999999,
                    },
                },
            },
            {
                version: '0.5.16',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 999999,
                    },
                },
            },
        ],
    },
    networks: {
        mainnet: {
            url: process.env.MAINNET_PROVIDER ? process.env.MAINNET_PROVIDER : `https://mainnet.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 20,
            },
        },
        ropsten: {
            url: process.env.ROPSTEN_PROVIDER ? process.env.ROPSTEN_PROVIDER : `https://ropsten.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 20,
            },
        },
        goerli: {
            url: process.env.GOERLI_PROVIDER ? process.env.GOERLI_PROVIDER : `https://goerli.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 20,
            },
        },
        rinkeby: {
            url: process.env.RINKEBY_PROVIDER ? process.env.RINKEBY_PROVIDER : `https://rinkeby.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 20,
            },
        },
        localhost: {
            url: 'http://127.0.0.1:8545',
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 20,
            },
        },
        hardhat: {
            initialDate: '0',
            allowUnlimitedContractSize: true,
            initialBaseFeePerGas: '0',
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 20,
            },
        },
        polygonZKEVMTestnet: {
            url: 'https://rpc.public.zkevm-test.net',
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 20,
            },
        },
        polygonZKEVMMainnet: {
            url: 'https://zkevm-rpc.com',
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 20,
            },
        },
        polygonL1net: {
            url: 'http://192.168.50.51:8545',
            chainId: 1337,
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 25,
            },
        },
        polygonL2net: {
            url: 'http://192.168.50.51:8123',
            chainId: 1001,
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 25,
            },
        },
        abenode: {
            // url: "http://127.0.0.1:8555",
            url: 'http://124.243.132.119:8545',
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 25,
            },
        },
        b2rollup: {
            url: 'http://192.168.50.127:8123',
            chainId: 1002,
            accounts: {
                mnemonic: process.env.MNEMONIC || DEFAULT_MNEMONIC,
                path: "m/44'/60'/0'/0",
                initialIndex: 0,
                count: 25,
            },
        },

    },
    gasReporter: {
        enabled: !!process.env.REPORT_GAS,
        outputFile: process.env.REPORT_GAS_FILE ? './gas_report.md' : null,
        noColors: !!process.env.REPORT_GAS_FILE,
    },
    etherscan: {
        apiKey: {
            polygonZKEVMTestnet: `${process.env.ETHERSCAN_ZKEVM_API_KEY}`,
            polygonZKEVMMainnet: `${process.env.ETHERSCAN_ZKEVM_API_KEY}`,
            goerli: `${process.env.ETHERSCAN_API_KEY}`,
            mainnet: `${process.env.ETHERSCAN_API_KEY}`,
            polygonL1net: "abc"
        },
        customChains: [
            {
                network: 'polygonZKEVMMainnet',
                chainId: 1101,
                urls: {
                    apiURL: 'https://api-zkevm.polygonscan.com/api',
                    browserURL: 'https://zkevm.polygonscan.com/',
                },
            },
            {
                network: 'polygonZKEVMTestnet',
                chainId: 1442,
                urls: {
                    apiURL: 'https://api-testnet-zkevm.polygonscan.com/api',
                    browserURL: 'https://testnet-zkevm.polygonscan.com/',
                },
            },
            {
                network: 'polygonL1net',
                chainId: 1337,
                urls: {
                    apiURL: 'http://192.168.50.127:4000/api',
                    browserURL: 'http://192.168.50.127:4000',
                },
            },
        ],
    },
};
