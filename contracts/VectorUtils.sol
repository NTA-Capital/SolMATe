// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;
import "prb-math/contracts/PRBMathSD59x18.sol";

library VectorUtils {
    using PRBMathSD59x18 for int256;

    function convertTo59x18(int256[] memory a) internal pure returns (int256[] memory) {
        int256[] memory result = new int256[](a.length);
        for (uint i=0; i<a.length; i++) {
            result[i] = a[i]*1e18;
        }
        return result;
    }

    function normalize(int256[] memory a) internal pure returns (int256[] memory) {
        int256 total = 0e18;
        int256[] memory newVec = new int256[](a.length);
        for (uint i=0; i<a.length; i++) {
            // Square sum
            total += a[i].mul(a[i]);
        }
        for (uint i=0; i<a.length; i++) {
            // Input normalized values
            newVec[i] = a[i].div(total.sqrt());
        }
        return newVec;
    }
    function dot(int256[] memory a, int256[] memory b) internal pure returns (int256) {
        int256 total = 0e18;
        for (uint i=0; i<a.length; i++) {
            total += a[i].mul(b[i]);
        }
        return total;
    }
    function add(int256[] memory a, int256[] memory b) internal pure returns (int256[] memory) {
        int256[] memory result = new int256[](a.length);
        for (uint i=0; i<a.length; i++) {
            result[i] = a[i] + b[i];
        }
        return result;
    }
    function mul(int256[] memory a, int256 b) internal pure returns (int256[] memory) {
        int256[] memory result = new int256[](a.length);
        for (uint i=0; i<a.length; i++) {
            result[i] = a[i].mul(b);
        }
        return result;
    }
    function projection(int256[] memory a, int256[] memory u) internal pure returns (int256[] memory) {
        // Projects first vector onto second vector
        int256 coeff = dot(u,a).div(dot(u,u));
        int256[] memory result = mul(u, coeff);
        return result;
    }
    function norm(int256[] memory a) internal pure returns (int256) {
        return dot(a,a).sqrt();
    }
    function toMatrix(int256[] memory a) internal pure returns (int256[][] memory) {
        int256[][] memory result = new int256[][](a.length);
        for(uint i=0; i<a.length; i++) {
            result[i] = new int256[](1);
            result[i][0] = a[i];
        }
        return result;
    }
}