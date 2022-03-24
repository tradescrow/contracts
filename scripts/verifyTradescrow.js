const hre = require("hardhat");

async function main() {
  console.log("Verifying Tradescrow")
  await hre.run("verify:verify", {
    address: "0xF8565d545a60DD5849b8C626404f96738da5bDfB"
  })
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })