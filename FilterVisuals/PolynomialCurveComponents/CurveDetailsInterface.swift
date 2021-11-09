//
//  CurveDetailsInterface.swift
//  FilterVisuals
//
//  Created by Bitmorpher 4 on 11/2/21.
//  iRny

import Foundation
import UIKit
import SwiftUI

@objc class CurveDetailsInterface: NSObject {
    let polynomialObj = PolynomialTransformer()
    @objc lazy var outputImage = polynomialObj.outputImage

    @objc func makeHostingVC(sourceImage: UIImage) -> UIViewController{
        let detailsCV = ContentView().environmentObject(PolynomialTransformer(sourceImage: sourceImage))
        return UIHostingController(rootView: detailsCV)
    }
}

