
const hre = require("hardhat");

async function main() {
  
  const Web3 = await hre.ethers.getContractFactory("HolaMetaversoSpeaker");
  const web3 = await Web3.deploy();

  await web3.deployed();

  console.log("Hola Contract deployed to:", web3.address);
  const receipt = await web3.deployTransaction.wait();
  console.log("gasUsed:" , receipt.gasUsed);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
