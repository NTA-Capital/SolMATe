// SPDX-License-Identifier: BSD-4-Clause
pragma solidity >=0.8.4;
import "prb-math/contracts/PRBMathSD59x18.sol";
import "./VectorUtils.sol";

library MatrixUtils {
    using PRBMathSD59x18 for int256;
    using VectorUtils for int256[];

    function createMatrix(uint dim1, uint dim2) internal pure returns (int256[][] memory) {
        int256[][] memory result = new int256[][](dim1);
        for (uint i=0; i<dim1; i++) {
            result[i] = new int256[](dim2);
        }
        return result;
    }

    function convertTo59x18(int256[][] memory a) internal pure returns (int256[][] memory) {
        int256[][] memory result = new int256[][](a.length);
        for (uint i=0; i<a.length; i++) {
            result[i] = a[i].convertTo59x18();
        }
        return result;
    }
    function outerProduct(int256[] memory a, int256[] memory b) internal pure returns (int256[][] memory) {
        int256[][] memory result = createMatrix(a.length, b.length);
        for (uint i=0; i<a.length; i++) {
            for (uint j=0; j<b.length; j++) {
                result[i][j] = a[i].mul(b[j]);
            }
        }
        return result;
    }
    function mul(int256[][] memory a, int256 b) internal pure returns (int256[][] memory) {
        int256[][] memory result = createMatrix(a.length, a[0].length);
        for (uint i=0; i<a.length; i++) {
            for (uint j=0; j<a[0].length; j++) {
                result[i][j] = a[i][j].mul(b);
            }
        }
        return result;
    }
    function add(int256[][] memory a, int256[][] memory b) internal pure returns (int256[][] memory) {
        int256[][] memory result = createMatrix(a.length, a[0].length);
        for (uint i=0; i<a.length; i++) {
            for (uint j=0; j<a[0].length; j++) {
                result[i][j] = a[i][j] + b[i][j];
            }
        }
        return result;
    }
    function add(int256[][] memory a, int256 b) internal pure returns (int256[][] memory) {
        int256[][] memory result = createMatrix(a.length, a[0].length);
        for (uint i=0; i<a.length; i++) {
            for (uint j=0; j<a[0].length; j++) {
                result[i][j] = a[i][j] + b;
            }
        }
        return result;
    }
    function dot(int256[][] memory a, int256[][] memory b) internal pure returns (int256[][] memory) {
        uint l1 = a.length;
        uint l2 = b[0].length;
        uint zipsize = b.length;
        int256[][] memory c = new int256[][](l1);
        for (uint fi=0; fi<l1; fi++) {
            c[fi] = new int256[](l2);
            for (uint fj=0; fj<l2; fj++) {
                int256 entry = 0e18;
                for (uint i=0; i<zipsize; i++) {
                    entry += a[fi][i].mul(b[i][fj]);
                }
                c[fi][fj] = entry;
            }
        }
        return c;
    }
    function T(int256[][] memory a) internal pure returns (int256[][] memory) {
        int256[][] memory transpose = new int256[][](a[0].length);
        for (uint j=0; j<a[0].length; j++) {
            transpose[j] = new int256[](a.length);
            for (uint i=0; i<a.length; i++) {
                transpose[j][i] = a[i][j];
            }
        }
        return transpose;
    }
    function diag(int256[][] memory a) internal pure returns (int256[] memory) {
        int256[] memory diagonal_vector = new int256[](a.length);
        for (uint i=0; i<a.length; i++) {
            diagonal_vector[i] = a[i][i];
        }
        return diagonal_vector;
    }

    function sliceVector(int256[][] memory a, uint dim1_start, uint dim1_end, uint dim2_start, uint dim2_end) internal pure returns (int256[] memory) {
        if (dim1_start == dim1_end) {
            uint length = dim2_end - dim2_start;
            int256[] memory result = new int256[](length);
            for (uint i=dim2_start; i < dim2_end; i++) {
                result[i] = a[dim1_start][i];
            }
            return result;
        } else {
            uint length = dim1_end - dim1_start;
            int256[] memory result = new int256[](length);
            for (uint i=dim1_start; i < dim1_end; i++) {
                result[i] = a[i][dim2_start];
            }
            return result;
        }
    }
    function sliceMatrix(int256[][] memory a, uint dim1_start, uint dim1_end, uint dim2_start, uint dim2_end) internal pure returns (int256[][] memory) {
        uint dim1 = dim1_end - dim1_start;
        uint dim2 = dim2_end - dim2_start;
        int256[][] memory result = createMatrix(dim1, dim2);
        for (uint i=0; i<dim1; i++) {
            for (uint j=0; j<dim2; j++) {
                result[i][j] = a[i+dim1_start][j+dim2_start];
            }
        }
        return result;
    }
    function eye(uint size) internal pure returns (int256[][] memory) {
        int256[][] memory result = createMatrix(size,size);
        for (uint i=0; i<size; i++) {
            result[i][i] = 1e18;
        }
        return result;
    }
    function assign(int256[][] memory a, int256[][] memory b, uint i, uint j) internal pure returns (int256[][] memory) {
        int256[][] memory result = a;
        for (uint ii=0; ii<b.length; ii++) {
            for (uint jj=0; jj<b[0].length; jj++) {
                result[ii+i][jj+j] = b[ii][jj];
            }
        }
        return result;
    }
    function QRDecompositionHouseholder(int256[][] memory a, int256[][] memory h_prev, uint pivot_idx) internal pure returns (int256[][] memory, int256[][] memory) {
        // Find QR decomposition using Householder reflections
        if ((a.length - pivot_idx < 1) || (a[0].length - pivot_idx < 1)) {
            return (h_prev, a);
        }
        int256[][] memory a_sub = sliceMatrix(a,pivot_idx,a.length,pivot_idx,a[0].length);
        int256[] memory a_1 = sliceVector(a_sub,0,a_sub.length,0,0);
        int256[] memory e_1 = new int256[](a_sub.length);
        e_1[0] = 1e18;
        int256 sign;
        if (a_1[0] > 0) {
            sign = 1e18;
        }
        else {
            sign = -1e18;
        }
        int256 prefactor = a_1.norm().mul(sign);
        int256[] memory v_1 = a_1.add(e_1.mul(prefactor));

        // Set new prefactor for matrix computation
        prefactor = -2e18;
        prefactor = prefactor.div(v_1.dot(v_1));
        int256[][] memory h_1 = add(eye(a_sub.length), mul(outerProduct(v_1,v_1), prefactor));
        
        int256[][] memory h1_full = eye(a.length);
        h1_full = assign(h1_full, h_1, pivot_idx, pivot_idx);

        int256[][] memory r_1 = dot(h1_full, a);

        return QRDecompositionHouseholder(r_1, dot(h_prev, h1_full), pivot_idx+1);
    }

    function QRDecomposition(int256[][] memory a) internal pure returns (int256[][] memory, int256[][] memory) {
        return QRDecompositionHouseholder(a, eye(a.length), 0);
    }

    function QRDecompositionGramSchmidt(int256[][] memory a) internal pure returns (int256[][] memory, int256[][] memory) {
        // Get QR decomposition using Gram-Schmidt orthogonalization. Must be full-rank square matrix.
        int256[][] memory q = createMatrix(a.length, a[0].length);
        
        // Initialize U matrix
        int256[][] memory u_columns = new int256[][](a[0].length);

        // Populate U matrix
        for (uint i=0; i<a[0].length; i++) {
            // Grab the i'th column from a and store into a_column
            int256[] memory a_column = new int256[](a.length);
            int256[] memory u_column = new int256[](a.length);
            int256[] memory e_column = new int256[](a.length);
            for (uint j=0; j<a.length; j++) {
                a_column[j] = a[j][i];
            }
            // Calculate the i'th U column
            u_column = a_column; // Assume solidity copies arrays upon assignment (not necessarily true)
            for (uint j=0; j<i; j++) {
                u_column = u_column.add(a_column.projection(u_columns[j]).mul(-1e18));
            }
            u_columns[i] = u_column;

            // Calculate the i'th E column
            e_column = u_column.normalize();
            //e_column = u_column;

            // Load the E column into Q
            for (uint j=0; j<a.length; j++) {
                q[j][i] = e_column[j];
            }
        }
        int256[][] memory r = dot(T(q),a);

        return (q,r);
    }

    function eigenvalues(int256[][] memory a) internal pure returns (int256[] memory) {
        int256[][] memory q;
        int256[][] memory r;
        for (uint i=0; i<15; i++) {
            (q,r) = QRDecomposition(a);
            a = dot(r, q);
        }
        return diag(a);
    }

    function backSubstitute(int256[][] memory u, int256[][] memory y) internal pure returns (int256[][] memory) {
        // Solve the equation Ux = y where U is an mxn upper triangular matrix, y is length m, x is length n.
        uint dim = u[0].length;
        int256[][] memory x = createMatrix(dim, 1);
        for (uint step=0; step<dim; step++) {
            uint i = dim - step - 1;
            int256 target = y[i][0];
            // Subtract already-solved variables
            for (uint step2=0; step2<step; step2++) {
                uint j = dim - step2 - 1;
                target = target - u[i][j].mul(x[j][0]);
            }
            // Solve for unknown variable
            x[i][0] = target.div(u[i][i]);
        }
        return x;
    }
}
