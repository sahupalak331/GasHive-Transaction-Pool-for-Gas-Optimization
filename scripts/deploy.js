const hre = require("hardhat");

async function main() {
  const executorAddress = "0xYourExecutorAddressHere"; // Replace with real address

  const GasHive = await hre.ethers.getContractFactory("GasHive");
  const gasHive = await GasHive.deploy(executorAddress);

  await gasHive.deployed();
  console.log("GasHive deployed to:", gasHive.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
