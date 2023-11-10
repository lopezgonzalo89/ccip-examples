const getConfig = (network) => {
  switch (network) {
    case "sepolia":
      return {
        routerAddress: "0xD0daae2231E9CB96b94C8512223533293C3693Bf", // Sepolia
        link: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
      };
    case "mumbai":
      return {
        routerAddress: "0x70499c328e1E2a3c41108bd3730F6670a44595D1", // Mumbai
        link: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
      };
    case "fuji":
      return {
        routerAddress: "0x554472a2720e5e7d5d3c817529aba05eed5f82d8", // fuji
        link: "0x0b9d5d9136855f6fec3c0993fee6e9ce8a297846",
      };
    case "arbitrum":
      return {
        routerAddress: "0x88e492127709447a5abefdab8788a15b4567589e", // Arbitrum
        link: "0xd14838a68e8afbade5efb411d5871ea0011afd28",
      };
    case "optimism":
      return {
        routerAddress: "0xeb52e9ae4a9fb37172978642d4c141ef53876f26", // Optimism
        link: "0xdc2cc710e42857672e7907cf474a69b63b93089f",
      };
    case "base":
      return {
        routerAddress: "0xa8c0c11bf64af62cdca6f93d3769b88bdd7cb93d", // Base
        link: "0xd886e2286fd1073df82462ea1822119600af80b6",
      };
    case "bsc":
      return {
        routerAddress: "0x9527e2d01a3064ef6b50c1da1c0cc523803bcff2", // BSC
        link: "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06",
      };
    default:
      throw new Error("Invalid network");
  }
};

module.exports = getConfig;
