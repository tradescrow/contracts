import { getContractAndData } from "@dirtycajunrice/hardhat-tasks/internal/helpers";
import hre from 'hardhat';
import { parseUnits } from "ethers";
import "dotenv/config";

const chainId = 53935;
const fee = 1; // in USDC
const usdc = "0x3AD9DFE640E1A9Cc1D9B0948620820D975c3803a";
const treasury = "0x4082e997Ec720A4894EFec53b0d9AabfeeA44cBE";

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
