import { getContractAndData } from "@dirtycajunrice/hardhat-tasks/internal/helpers";
import  hre from 'hardhat';
import { parseUnits } from "ethers";
import "dotenv/config";

const updateFee = async () => {
  const { contract } = await getContractAndData( hre, "Tradescrow");
  const newFee = parseUnits("1", 6);
  const currentFee = await contract.userFee();
  if (currentFee === newFee) {
    console.log(`Contract fee already set to ${newFee.toString()} for ${hre.network.name}`);
    return;
  }
  console.log("Updating fee to", newFee.toString());
  const tx = await contract.setFee(newFee);
  await tx.wait();

  console.log(`Contract fee updated on ${hre.network.name}`);
}

updateFee().then(() => {
  console.log('Fee updated')
  process.exit(0)
}).catch((err) => {
  console.error(err)
  process.exit(1)
})
