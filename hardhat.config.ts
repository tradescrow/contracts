import * as tenderly from "@tenderly/hardhat-tenderly";

tenderly.setup({ automaticVerifications: false });


import "@dirtycajunrice/hardhat-tasks/internal/type-extensions"
import "@dirtycajunrice/hardhat-tasks";
import "dotenv/config";
import '@openzeppelin/hardhat-upgrades';
import '@nomicfoundation/hardhat-verify';
import { HardhatUserConfig, NetworksUserConfig } from "hardhat/types";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";
import "hardhat-abi-exporter";

const networkData = [
  {
    name: "mainnet",
    chainId: 1,
    urls: {
      rpc: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      api: "https://api.etherscan.io/api",
      browser: "https://etherscan.io/",
    },
  },
  {
    name: "arbitrumOne",
    chainId: 42_161,
    urls: {
      rpc: `https://arb1.arbitrum.io/rpc`,
      api: "https://api.arbiscan.io/api",
      browser: "https://arbiscan.io/",
    },
  },
  {
    name: "avalanche",
    chainId: 43_114,
    urls: {
      rpc: `https://api.avax.network/ext/bc/C/rpc`,
      api: "https://api.snowtrace.io/api",
      browser: "https://snowtrace.io",
    },
  },
  {
    name: "boba",
    chainId: 288,
    urls: {
      rpc: `https://mainnet.boba.network`,
      api: "https://api.bobascan.com/api",
      browser: "https://bobascan.com",
    },
  },
  {
    name: "base",
    chainId: 8_453,
    urls: {
      rpc: `https://developer-access-mainnet.base.org`,
      api: "https://api.basescan.org/api",
      browser: "https://basescan.org/",
    },
  },
  {
    name: "polygon",
    chainId: 137,
    urls: {
      rpc: `https://polygon-mainnet.public.blastapi.io`,
      api: "https://api.polygonscan.com/api",
      browser: "https://polygonscan.com/",
    },
  },
  {
    name: "polygonZkevm",
    chainId: 1_101,
    urls: {
      rpc: `https://zkevm-rpc.com`,
      api: "https://api-zkevm.polygonscan.com/api",
      browser: "https://zkevm.polygonscan.com/",
    },
  },
  {
    name: "optimisticEthereum",
    chainId: 10,
    urls: {
      rpc: `https://mainnet.optimism.io`,
      api: "https://api-optimistic.etherscan.io/api",
      browser: "https://optimistic.etherscan.io/",
    },
  },
  {
    name: "bsc",
    chainId: 56,
    urls: {
      rpc: `https://bsc-rpc.gateway.pokt.network`,
      api: "",
      browser: "",
    },
  },
  {
    name: "dfk",
    chainId: 53_935,
    urls: {
      rpc: `https://subnets.avax.network/defi-kingdoms/dfk-chain/rpc`,
      api: "https://api.avascan.info/v2/network/mainnet/evm/53935/etherscan",
      browser: "https://avascan.info/blockchain/dfk",
    },
    accounts: [ process.env.PRIVATE_KEY! ],
  },
  {
    name: "klaytn",
    chainId: 8_217,
    urls: {
      rpc: `https://klaytn-pokt.nodies.app`,
      api: "",
      browser: "https://klaytnscope.com/",
    },
    accounts: [ process.env.PRIVATE_KEY_2! ],
  },
];

const config: HardhatUserConfig = {
  paths: {
    sources: "./src/contracts",
  },
  solidity: {
    compilers: [ "8.20", "8.9", "8.2", "6.0" ].map(v => ({
      version: `0.${v}`,
      settings: { ...(v === "8.20" ? { evmVersion: "london" } : {} ), optimizer: { enabled: true, runs: 200 } },
    })),
    overrides: {
      "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol": {
        version: "0.8.9",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol": {
        version: "0.8.9",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol": {
        version: "0.8.9",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol": {
        version: "0.8.9",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
      "contracts/proxy.sol": {
        version: "0.8.9",
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
    },
  },
  networks: networkData.reduce((o, network) => {
    o[network.name] = {
      url: network.urls.rpc,
      chainId: network.chainId,
      accounts: network.accounts || [ process.env.PRIVATE_KEY! ]
    }
    return o;
  }, {} as NetworksUserConfig),
  etherscan: {
    apiKey: networkData.reduce((o, network) => {
      o[network.name] = process.env[`${network.name.toLowerCase()}_API_KEY`] || "not-needed";
      return o;
    }, {} as Record<string, string>),
    customChains: networkData.map(network => ({
      network: network.name,
      chainId: network.chainId,
      urls: { apiURL: network.urls.api, browserURL: network.urls.browser },
    }))
  },
  tenderly: {
    project: 'tradescrow',
    username: 'DirtyCajunRice',
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
    strict: true,
    only: [':Trade.*'],
    except: [],
  },
  abiExporter: {
    path: "./abis",
    runOnCompile: true,
    clear: true,
    flat: true,
    only: [ ':Tradescrow' ],
    spacing: 2,
    pretty: true,
  },
  sourcify: {
    enabled: true,
  },
};

export default config;
