const hre = require("hardhat");
const getConfig = require("../utils/index.js");

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const network = await hre.ethers.provider._networkName;
  const { routerAddress, link } = getConfig(network);

  const [deployer] = await hre.ethers.getSigners();

  if (!routerAddress) {
    console.error(
      "Usage: npx hardhat run scripts/deployMessenger.js --network localhost"
    );
    process.exit(1);
  }

  console.log("-- Deploying --");
  console.log("Deployer address:", deployer.address);
  console.log("Router Address: ", routerAddress);
  console.log("Link Address: ", link);
  console.log("");

  const Messenger = await hre.ethers.getContractFactory("Messenger");
  const messenger = await Messenger.deploy(routerAddress, link);

  await messenger.waitForDeployment();

  console.log("-- Deployed --");
  console.log("Messenger address:", messenger.target);
  console.log("");

  console.log("-- Verifying --");
  await delay(30000);

  await hre.run("verify:verify", {
    address: messenger.target,
    constructorArguments: [routerAddress, link],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
