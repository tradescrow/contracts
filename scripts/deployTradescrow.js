const { ethers } = require("hardhat")
const { hre } = require("@nomiclabs/hardhat-etherscan")
require("dotenv").config()

async function deploy(name, args) {
    // Deploying
    console.log("Starting deployment...")
    const contractFactory = await ethers.getContractFactory(name)
    console.log("Deploying " + name)
    const contract = await contractFactory.deploy(...args)
    console.log(name + " deployed! Address:", contract.address)
    return {name, args, address: contract.address}
}

async function verify(contract) {
    console.log("Verifying " + contract.name)
    await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: contract.args,
    })
}
async function main() {
    const signers = await ethers.getSigners()
    const constructorArguments = [
        "1000000000000000000",
        signers[0].address
    ]
  await deploy("Tradescrow", constructorArguments)
      .then(async (contract) => await verify(contract))
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })