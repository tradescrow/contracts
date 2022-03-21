const { ethers } = require("hardhat")

async function deploy(name) {
    // Deploying
    console.log("Starting deployment...")
    const contractFactory = await ethers.getContractFactory(name)
    console.log("Deploying " + name)
    const contract = await contractFactory.deploy()
    console.log(name + " deployed! Address:", contract.address)
    return {name, address: contract.address}
}

async function main() {
  await deploy("Tradescrow")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })