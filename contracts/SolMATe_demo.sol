// SPDX-License-Identifier: BSD-4-Clause
pragma solidity >=0.8.4;
import "prb-math/contracts/PRBMathSD59x18.sol";
import "./VectorUtils.sol";
import "./MatrixUtils.sol";

contract SolMATe_demo {
    using PRBMathSD59x18 for int256;
    using VectorUtils for int256[];
    using MatrixUtils for int256[][];

    function eigensolve() public pure returns (int256[] memory) {
        // Get eigenvalues of matrix [[0,1],[-2,-3]]
        int256[][] memory a = MatrixUtils.createMatrix(2, 2);
        a[0][0] = 0e18;
        a[1][0] = 1e18;
        a[0][1] = -2e18;
        a[1][1] = -3e18;
        return a.eigenvalues();
    }

    function get_eigenvalues(int256[][] memory a) public pure returns (int256[] memory) {
        return a.convertTo59x18().eigenvalues();
    }

    function multipleLinearRegression(int256[][] memory a, int256[] memory b) public pure returns (int256[][] memory) {
        int256[][] memory q;
        int256[][] memory r;
        int256[][] memory b_mat = b.convertTo59x18().toMatrix();
        (q,r) = a.convertTo59x18().QRDecomposition();
        return r.backSubstitute(q.T().dot(b_mat));
    }

}
