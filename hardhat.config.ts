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
    harmony: { url: "https://api.harmony.one", chainId: 1666600000, accounts },
    harmonyTest: { url: "https://api.s0.b.hmny.io", chainId: 1666700000, accounts },
    optimisticEthereum: { url: "https://mainnet.optimism.io", chainId: 10, accounts },
    polygon: { url: "https://polygon-mainnet.public.blastapi.io", chainId: 137, accounts },
    arbitrumOne: { url: "https://arb1.arbitrum.io/rpc", chainId: 42161, accounts: accounts },
    opera: { url: "https://fantom-mainnet.public.blastapi.io", chainId: 250, accounts },
    avalanche: { url: "https://rpc.ankr.com/avalanche", chainId: 43114, accounts },
    cronos: { url: "https://evm.cronos.org", chainId: 25, accounts },
    boba: { url: "https://mainnet.boba.network", chainId: 288, accounts },
    base: { url: "https://developer-access-mainnet.base.org", chainId: 8453, accounts },
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY,
      harmony: "not needed",
      harmonyTest: "not needed",
      optimisticEthereum: process.env.OPTIMISTIC_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
      arbitrumOne: process.env.ARBISCAN_API_KEY,
      opera: process.env.FTMSCAN_API_KEY,
      avalanche: process.env.SNOWTRACE_API_KEY,
      cronos: process.env.CRONOSCAN_API_KEY,
      boba: process.env.BOBASCAN_API_KEY,
      base: process.env.BASESCAN_API_KEY,
    },
    customChains: [
      {
        network: "cronos",
        chainId: 25,
        urls: { apiURL: "https://api.cronoscan.com/api", browserURL: "https://cronoscan.com/" },
      },
      {
        network: "boba",
        chainId: 43288,
        urls: {
          apiURL: "https://blockexplorer.avax.boba.network/api",
          browserURL: "https://blockexplorer.avax.boba.network",
        },
      },
      {
        network: "base",
        chainId: 8453,
        urls: { apiURL: "https://api.basescan.org/api", browserURL: "https://basescan.org/" },
      },
    ],
  },
};
