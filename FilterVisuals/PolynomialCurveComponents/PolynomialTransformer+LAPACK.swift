//
//  PolynomialTransformer+LAPACK.swift
//  FilterVisuals
//
//  Created by Bitmorpher 4 on 11/2/21.
//

import Foundation
import Accelerate

// LAPACK Linear Solver wrapper.
extension PolynomialTransformer {
    
    /// Overwrites the parameter `b` with the _x_ in _Ax = b_.
    static func solveLinearSystem(a: inout [Double],
                                  a_rowCount: Int, a_columnCount: Int,
                                  b: inout [Double],
                                  b_count: Int) throws {
        
        var info = Int32(0)
        
        // 1: Specify transpose.
        var trans = Int8("T".utf8.first!)
        
        // 2: Define constants.
        var m = __CLPK_integer(a_rowCount)
        var n = __CLPK_integer(a_columnCount)
        var lda = __CLPK_integer(a_rowCount)
        var nrhs = __CLPK_integer(1) // Assumes `b` is a column matrix.
        var ldb = __CLPK_integer(b_count)
        
        // 3: Workspace query.
        var workDimension = Double(0)
        var minusOne = Int32(-1)
        
        dgels_(&trans, &m, &n,
               &nrhs,
               &a, &lda,
               &b, &ldb,
               &workDimension, &minusOne,
               &info)
        
        if info != 0 {
            throw LAPACKError.internalError
        }
        
        // 4: Create workspace.
        var lwork = Int32(workDimension)
        var workspace = [Double](repeating: 0,
                                 count: Int(workDimension))
        
        // 5: Solve linear system.
        dgels_(&trans, &m, &n,
               &nrhs,
               &a, &lda,
               &b, &ldb,
               &workspace, &lwork,
               &info)
        
        if info < 0 {
            throw LAPACKError.parameterHasIllegalValue(parameterIndex: abs(Int(info)))
        } else if info > 0 {
            throw LAPACKError.diagonalElementOfTriangularFactorIsZero(index: Int(info))
        }
    }
    
    public enum LAPACKError: Swift.Error {
        case internalError
        case parameterHasIllegalValue(parameterIndex: Int)
        case diagonalElementOfTriangularFactorIsZero(index: Int)
    }
}
