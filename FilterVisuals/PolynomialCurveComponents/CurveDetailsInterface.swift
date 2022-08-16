//
//  CurveDetailsInterface.swift
//  FilterVisuals
//
//  Created by iRny on 11/2/21.
//  

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

