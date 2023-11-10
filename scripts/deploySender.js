const hre = require("hardhat");
const getConfig = require("../utils/index.js");

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const network = await hre.ethers.provider._networkName;
  const { routerAddress, link } = getConfig(network);

  const [deployer] = await hre.ethers.getSigners();

  if (!routerAddress || !link) {
    console.error(
      "Usage: npx hardhat run scripts/deploySender.js --network localhost"
    );
    process.exit(1);
  }

  console.log("-- Deploying --");
  console.log("Deployer address:", deployer.address);
  console.log("");

  const Sender = await hre.ethers.getContractFactory("Sender");

  const sender = await Sender.deploy(routerAddress, link);

  await sender.waitForDeployment();

  console.log("-- Deployed --");
  console.log("Sender address:", sender.target);
  console.log("Router Address: ", routerAddress);
  console.log("Link Address: ", link);
  console.log("");

  console.log("-- Verifying --");
  await delay(30000);

  await hre.run("verify:verify", {
    address: sender.target,
    constructorArguments: [routerAddress, link],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
