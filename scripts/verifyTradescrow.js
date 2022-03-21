const hre = require("hardhat");

async function main() {
  console.log("Verifying Tradescrow")
  await hre.run("verify:verify", {
    address: "0x83FB618e5288dF061d687c78D821674D1100e18B"
  })
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })