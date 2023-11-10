require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("dotenv").config();

module.exports = {
  solidity: "0.8.19",
  networks: {
    sepolia: {
      url: process.env.RPC_SEPOLIA,
      accounts: [process.env.PK_DEPLOYER],
    },
    mumbai: {
      url: process.env.RPC_MUMBAI,
      accounts: [process.env.PK_DEPLOYER],
    },
    fuji: {
      url: process.env.RPC_AVALANCHE_FUJI,
      accounts: [process.env.PK_DEPLOYER],
    },
    arbitrum: {
      url: process.env.RPC_ARBITRUM_GOERLI,
      accounts: [process.env.PK_DEPLOYER],
    },
    optimism: {
      url: process.env.RPC_OPTIMISTIC_GOERLI,
      accounts: [process.env.PK_DEPLOYER],
    },
    base: {
      url: process.env.RPC_BASE_GOERLI,
      accounts: [process.env.PK_DEPLOYER],
    },
    bsc: {
      url: process.env.RPC_BSC_TESTNET,
      accounts: [process.env.PK_DEPLOYER],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY_SEPOLIA,
      polygonMumbai: process.env.ETHERSCAN_API_KEY_MUMBAI,
      avalancheFujiTestnet: process.env.ETHERSCAN_API_KEY_AVALANCHE_FUJI,
      arbitrumGoerli: process.env.ETHERSCAN_API_KEY_ARBITRUM_GOERLI,
      optimisticGoerli: process.env.ETHERSCAN_API_KEY_OPTIMISTIC_GOERLI,
      baseGoerli: process.env.ETHERSCAN_API_KEY_BASE_GOERLI,
      bscTestnet: process.env.ETHERSCAN_API_KEY_BSC_TESTNET,
    },
  },
  sourcify: {
    enabled: true,
  },
};
