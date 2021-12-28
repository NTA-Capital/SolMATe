// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const SolMATe_demo = await hre.ethers.getContractFactory("SolMATe_demo");
  const solmate_demo = await SolMATe_demo.deploy();

  await solmate_demo.deployed();
  const inputMat = [[43,1],[21,1],[25,1],[42,1],[57,1],[59,1]]
  const b = [99,65,79,75,87,81]
  const result = await solmate_demo.multipleLinearRegression(inputMat, b);
  console.log(result);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
