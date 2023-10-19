import { getContractAndData } from "@dirtycajunrice/hardhat-tasks/internal/helpers";
import hre from 'hardhat';
import { parseUnits } from "ethers";
import "dotenv/config";

const chainId = 42161;
const fee = 1; // in USDC
const usdc = "0xaf88d065e77c8cC2239327C5EDb3A432268e5831";
const treasury = "0x21D9Ff041F2d71f8767c0249069f7B8390048Ea3";

const updateFee = async () => {
  if (hre.network.config.chainId !== chainId) {
    throw new Error(`Wrong network. Expected ${chainId}, got ${hre.network.config.chainId}`);
  }
  const { contract } = await getContractAndData(hre, "Tradescrow");
  const newFee = parseUnits(fee.toString(), 6);
  const currentFee = await contract.userFee();
  if (currentFee === newFee) {
    console.log(`Contract fee already set to ${newFee.toString()} for ${hre.network.name}`);
  } else {
    console.log("Updating fee to", newFee.toString());
    const tx = await contract.setFee(newFee);
    await tx.wait();

    console.log(`Contract fee updated on ${hre.network.name}`);
  }

  const currentUsdc = await contract.feeToken();
  if (currentUsdc === usdc) {
    console.log(`Contract fee token already set to ${usdc} for ${hre.network.name}`);
  } else {
    console.log("Updating fee token to", usdc);
    const tx = await contract.setFeeToken(usdc);
    await tx.wait();

    console.log(`Contract fee token updated on ${hre.network.name}`);
  }

  const currentTreasury = await contract.feeTreasury();
  if (currentTreasury === treasury) {
    console.log(`Contract fee treasury already set to ${treasury} for ${hre.network.name}`);
  } else {
    console.log("Updating fee treasury to", treasury);
    const tx = await contract.setFeeTreasury(treasury);
    await tx.wait();

    console.log(`Contract fee treasury updated on ${hre.network.name}`);
  }
}

updateFee().then(() => {
  console.log('Done!')
  process.exit(0)
}).catch((err) => {
  console.error(err)
  process.exit(1)
})
