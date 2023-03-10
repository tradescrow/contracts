import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';
import {
  GetEtherscanCustomChains,
  GetNetworks,
  GetSolidityCompilers
} from "@dirtycajunrice/hardhat-tasks";
import "@dirtycajunrice/hardhat-tasks/tasks";
import 'solidity-docgen';
import "dotenv/config";

const config = {
  solidity: {
    compilers: GetSolidityCompilers(["0.8.17"]),
  },
  networks: {
    ...GetNetworks([process.env.PRIVATE_KEY || ''])
  },
  etherscan: {
    apiKey: {
      avalanche: process.env.SNOWTRACE_API_KEY,
      bobaAvax: 'not needed'
    },
    customChains: GetEtherscanCustomChains(),
  },
  docgen: {
    pages: 'files'
  }
}

export default config;