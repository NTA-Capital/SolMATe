<img src="https://user-images.githubusercontent.com/5258974/147603258-8abef830-9d86-4701-bd80-523ef8033f8a.png" alt="nta_consulting_small" height="200" align="right"/> 

# SolMATe - The Solidity Matrix Environment 

![](https://img.shields.io/badge/PRs-welcome-brightgreen) ![](https://img.shields.io/badge/solidity-0.8.11-blue)

**SolMATe is the fundamental package for floating-point math, array manipulation, and linear algebra in Ethereum smart contracts.** With SolMATe you get:

- Gas-efficient operations with signed 59.18-decimal fixed-point numbers
- Functions for manipulating vectors and matrice
- Linear algebra routines enabling the implementation of machine learning algorithms, such as multivariate linear regression and deep neural networks

| ℹ️ **Contributors**: Please see the [Development](#development) section of this README. |
| --- |

- **Website:** https://TBD
- **Documentation:** https://TBD
- **Mailing list:** https://TBD
- **Source code:** https://github.com/naveenarun/SolMATe/
- **Contributing:** https://TBD
- **Bug reports:** https://github.com/naveenarun/SolMATe/issues
- **Report a security vulnerability:** https://TBD

# Install

TBD

# Usage

The following smart contract calculates the eigenvalues of a 2x2 matrix, and consumes 884090 gas.

```solidity
// SPDX-License-Identifier: TBD
pragma solidity >=0.8.4;
import "./PRBMathSD59x18.sol";
import "./VectorUtils.sol";
import "./MatrixUtils.sol";

contract EigenvalueSolver {
    using PRBMathSD59x18 for int256;
    using VectorUtils for int256[];
    using MatrixUtils for int256[][];
    
    function eigensolve() public returns (int256[] memory) {
        // Get eigenvalues of matrix [[0,1],[-2,-3]]
        // Matrix is represented as [[0e18,1e18],[-2e18,-3e18]] in SolMATe due to 59x18 fixed-point notation.
        int256[][] memory a = MatrixUtils.createMatrix(2, 2);
        a[0][0] = 0e18;
        a[1][0] = 1e18;
        a[0][1] = -2e18;
        a[1][1] = -3e18;
        
        // Calculate the eigenvalues
        return a.eigenvalues(); // Returns [-2, -1], represented as [-2.000045778229896671e18, -.999954221770103365e18]
    }
}
```

In SolMATe, all fixed point numbers are scaled by `1e18` and stored as `int256` data. Importing the `PRBMathSD59x18` package allows one to perform math operations on these numbers.

```solidity
using PRBMathSD59x18 for int256;
int256 a = 1.5e18; // represents a = 2
int256 b = 2e18; // represents b = 2
a.mul(b);  // returns 3e18, or 3000000000000000000, which represents 3
```


# Installation

Copy the files TBD to your Solidity project.



Call for Contributions
----------------------

TBD


