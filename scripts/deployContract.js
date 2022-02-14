const { ethers, upgrades } = require("hardhat");
require("dotenv").config();
async function main() {
  // Deploying
  console.log("Starting deploy");
  const Tradescrow = await ethers.getContractFactory("Tradescrow");
  console.log("Deploying");
  const instance = await Tradescrow.deploy(1, "0x4082e997Ec720A4894EFec53b0d9AabfeeA44cBE");
  console.log("Initially Deployed", instance.address);
  
}

main();