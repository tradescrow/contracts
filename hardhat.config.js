require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-etherscan");

require("dotenv").config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
        {
            version: "0.8.9",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        },
        {
            version: "0.6.0",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        }
    ]
},
  networks: {
    harmony: {
      url: process.env.PRIVATE_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]
    },
    avalanche: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      chainId: 43114,
      accounts: [process.env.PRIVATE_KEY]
    },
    fantom: {
      url: 'https://rpc.ftm.tools',
      chainId: 250,
      accounts: [process.env.PRIVATE_KEY]
    },
    polygon: {
      url: 'https://polygon-rpc.com',
      chainId: 137,
      accounts: [process.env.PRIVATE_KEY]
    }
  },
    etherscan: {
        apiKey: {
          harmony: '',
          avalanche: process.env.SNOWTRACE_API_KEY,
          opera: process.env.FTMSCAN_API_KEY,
          polygon: process.env.POLYGONSCAN_API_KEY
        }
    }
};
