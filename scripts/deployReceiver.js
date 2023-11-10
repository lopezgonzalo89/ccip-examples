const hre = require("hardhat");
const getConfig = require("../utils/index.js");

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const network = await hre.ethers.provider._networkName;
  const { routerAddress } = getConfig(network);

  const [deployer] = await hre.ethers.getSigners();

  if (!routerAddress) {
    console.error(
      "Usage: npx hardhat run scripts/deployReceiver.js --network localhost"
    );
    process.exit(1);
  }

  console.log("-- Deploying --");
  console.log("Deployer address:", deployer.address);
  console.log("Router Address: ", routerAddress);
  console.log("");

  const Receiver = await hre.ethers.getContractFactory("Receiver");
  const receiver = await Receiver.deploy(routerAddress);

  await receiver.waitForDeployment();

  console.log("-- Deployed --");
  console.log("Receiver address:", receiver.target);
  console.log("");

  console.log("-- Verifying --");
  await delay(30000);

  await hre.run("verify:verify", {
    address: receiver.target,
    constructorArguments: [routerAddress],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
