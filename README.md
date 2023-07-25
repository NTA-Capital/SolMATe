<img src="https://user-images.githubusercontent.com/5258974/147603258-8abef830-9d86-4701-bd80-523ef8033f8a.png" alt="nta_consulting_small" height="200" align="right"/> 

# SolMATe - The Solidity Matrix Environment 

![](https://img.shields.io/badge/PRs-welcome-brightgreen) ![](https://img.shields.io/badge/solidity-0.8.11-blue)

**SolMATe is the fundamental package for floating-point math, array manipulation, and linear algebra in Ethereum smart contracts.** With SolMATe you get:

- Gas-efficient operations with signed 59.18-decimal fixed-point numbers
- Functions for manipulating vectors and matrices
- Linear algebra routines enabling the implementation of machine learning algorithms, such as multivariate linear regression and deep neural networks

**SolMATe is the first-ever package making it possible to engage in all aspects of a machine learning pipeline directly on the blockchain** - from data collection to model training and evaluation - without having to involve an off-chain oracle. See below for an example of a key ML algorithm (multiple linear regression) implemented as a smart contract.

# Usage

The following smart contract performs multiple linear regression solving the equation `Ax=b`, where `A` is a matrix of coefficients, `b` is a vector of outputs, and `x` is the solution vector. It uses approximately `8e7` gas - making it impractical for Layer 1 applications but practical for Layer 2 as of 2022.

```solidity
// SPDX-License-Identifier: BSD-4-Clause
pragma solidity >=0.8.4;
import "prb-math/contracts/PRBMathSD59x18.sol";
import "./VectorUtils.sol";
import "./MatrixUtils.sol";

contract SolMATe_demo {
    using PRBMathSD59x18 for int256;
    using VectorUtils for int256[];
    using MatrixUtils for int256[][];

    function multipleLinearRegression(int256[][] memory a, int256[] memory b) public pure returns (int256[][] memory) {
        int256[][] memory q;
        int256[][] memory r;
        int256[][] memory b_mat = b.convertTo59x18().toMatrix();
        (q,r) = a.convertTo59x18().QRDecomposition();
        return r.backSubstitute(q.T().dot(b_mat));
    }
}
```

We can then run the contract using the following Hardhat script:

```javascript
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
```

In SolMATe, all fixed point numbers are scaled by `1e18` and stored as `int256` data. Importing the `PRBMathSD59x18` package allows one to perform math operations on these numbers.

```solidity
using PRBMathSD59x18 for int256;
int256 a = 1.5e18; // represents a = 1.5
int256 b = 2e18; // represents b = 2
a.mul(b);  // returns 3e18, or 3000000000000000000, which represents 3
```

# Contributing

SolMATe uses Hardhat for scripts and unit testing. Pull requests are welcome - especially those pertaining to documentation, optimizing algorithms, and developing test cases.
