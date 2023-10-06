import * as tenderly from "@tenderly/hardhat-tenderly";
import '@nomicfoundation/hardhat-verify';

import "@dirtycajunrice/hardhat-tasks/internal/type-extensions"
import "@dirtycajunrice/hardhat-tasks";
import "dotenv/config";
import "./tasks";
import '@openzeppelin/hardhat-upgrades';

import { NetworksUserConfig } from "hardhat/types";

tenderly.setup({ automaticVerifications: false });

const networkData = [
  {
    name: "mainnet",
    chainId: 1,
    urls: {
      rpc: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      api: "",
      browser: "",
    },
  },
  {
    name: "arbitrumOne",
    chainId: 42_161,
    urls: {
      rpc: `https://arb1.arbitrum.io/rpc`,
      api: "",
      browser: "",
    },
  },
  {
    name: "avalanche",
    chainId: 43_114,
    urls: {
      rpc: `https://rpc.ankr.com/avalanche`,
      api: "",
      browser: "",
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
      api: "",
      browser: "",
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
      api: "",
      browser: "",
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
];

module.exports = {
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
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY,
      arbitrumOne: process.env.ARBISCAN_API_KEY,
      avalanche: process.env.SNOWTRACE_API_KEY,
      boba: process.env.BOBASCAN_API_KEY,
      base: process.env.BASESCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
      polygonZkevm: process.env.ZKEVM_POLYGONSCAN_API_KEY,
      optimisticEthereum: process.env.OPTIMISTIC_API_KEY,
      bsc: process.env.BSCSCAN_API_KEY,
      dfk: process.env.AVASCAN_API_KEY,
    },
    customChains: networkData.map(network => ({
      network: network.name,
      chainId: network.chainId,
      urls: { apiURL: network.urls.api, browserURL: network.urls.browser },
    }))
  },
  tenderly: {
    project: 'tradescrow',
    username: 'DirtyCajunRice',
  }
};
