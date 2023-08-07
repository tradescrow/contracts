import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";

import "dotenv/config";

import "./tasks/deployUpgradeable";
import "./tasks/getUpgradeDetails";
import "./tasks/upgrade";

const settings = {
  optimizer: {
    enabled: true,
    runs: 200,
  },
};
const accounts = [ process.env.PRIVATE_KEY_2 ];
module.exports = {
  solidity: {
    compilers: [ "8.19", "8.9", "8.2", "6.0" ].map(v => (
      { version: `0.${v}`, settings }
    )),
  },
  networks: {
    mainnet: { url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`, chainId: 1, accounts },
    arbitrumOne: { url: "https://arb1.arbitrum.io/rpc", chainId: 42161, accounts: accounts },
    avalanche: { url: "https://rpc.ankr.com/avalanche", chainId: 43114, accounts },
    boba: { url: "https://mainnet.boba.network", chainId: 288, accounts },
    base: { url: "https://developer-access-mainnet.base.org", chainId: 8453, accounts },
    polygon: { url: "https://polygon-mainnet.public.blastapi.io", chainId: 137, accounts },
    polygonZkevm: { url: "https://zkevm-rpc.com", chainId: 1101, accounts },
    optimisticEthereum: { url: "https://mainnet.optimism.io", chainId: 10, accounts },
    bsc: { url: "https://bsc-rpc.gateway.pokt.network", chainId: 56, accounts },

    // opera: { url: "https://fantom-mainnet.public.blastapi.io", chainId: 250, accounts },
    // cronos: { url: "https://evm.cronos.org", chainId: 25, accounts },
  },
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
      // opera: process.env.FTMSCAN_API_KEY,
      // cronos: process.env.CRONOSCAN_API_KEY,
    },
    customChains: [
      {
        network: "cronos",
        chainId: 25,
        urls: { apiURL: "https://api.cronoscan.com/api", browserURL: "https://cronoscan.com/" },
      },
      {
        network: "boba",
        chainId: 288,
        urls: {
          apiURL: "https://api.bobascan.com/api",
          browserURL: "https://bobascan.com",
        },
      },
      {
        network: "base",
        chainId: 8453,
        urls: { apiURL: "https://api.basescan.org/api", browserURL: "https://basescan.org/" },
      },
      {
        network: "polygonZkevm",
        chainId: 1101,
        urls: { apiURL: "https://api-zkevm.polygonscan.com/api", browserURL: "https://zkevm.polygonscan.com/" },
      },
    ],
  },
};
