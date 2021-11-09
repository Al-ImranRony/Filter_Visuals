//
//  PolynomialTransformer.swift
//  FilterVisuals
//
//  Created by Bitmorpher 4 on 11/2/21.
//

import Foundation
import Accelerate
import UIKit
import Combine
import SwiftUI

@objc class PolynomialTransformer: NSObject, ObservableObject {
    
    /// The number of control points on each color curve.
    static let count = 5
    
    var sourceImage = UIImage(named: "Photo1") {
        didSet {
            setup()
        }
    }
    
//    / This app assumes supplied images are RGBA, 8-bit per channel.
    let sourceImageFormat = vImage_CGImageFormat(bitsPerComponent: 8,
                                                 bitsPerPixel: 32,
                                                 colorSpace: CGColorSpaceCreateDeviceRGB(),
                                                 bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue))!
    /// Interleaved source and destination image buffers.
    var sourceImageBuffer: vImage_Buffer!
    var destinationImageBuffer: vImage_Buffer!
    
    /// Planar source buffers.
    var planarRedSourceBuffer: vImage_Buffer!
    var planarGreenSourceBuffer: vImage_Buffer!
    var planarBlueSourceBuffer: vImage_Buffer!
    
    /// Planar destination buffers.
    var planarRedDestinationBuffer: vImage_Buffer!
    var planarGreenDestinationBuffer: vImage_Buffer!
    var planarBlueDestinationBuffer: vImage_Buffer!
    
    /// Planar alpha buffer.
    var planarAlphaBuffer: vImage_Buffer!
    
    deinit {
        sourceImageBuffer.free()
        destinationImageBuffer.free()
        planarRedSourceBuffer.free()
        planarGreenSourceBuffer.free()
        planarBlueSourceBuffer.free()
        planarRedDestinationBuffer.free()
        planarGreenDestinationBuffer.free()
        planarBlueDestinationBuffer.free()
    }
    
    init(sourceImage: UIImage) {
        super.init()
        self.sourceImage = sourceImage
        setup()
    }
    
    @Published var outputImage: CGImage!
    
    @Published var redCoefficients = [Float](repeating: 0,
                                             count: PolynomialTransformer.count)
    
    @Published var redValues: [Double]! {
        didSet {
            applyPolynomial(values: redValues,
                            source: &planarRedSourceBuffer,
                            coefficientsDestination: &redCoefficients,
                            destination: &planarRedDestinationBuffer)
            
            displayPlanarDestinationBuffers()
        }
    }
    
    @Published var greenCoefficients = [Float](repeating: 0,
                                               count: PolynomialTransformer.count)
    
    @Published var greenValues: [Double]! {
        didSet {
            applyPolynomial(values: greenValues,
                            source: &planarGreenSourceBuffer,
                            coefficientsDestination: &greenCoefficients,
                            destination: &planarGreenDestinationBuffer)
            
            displayPlanarDestinationBuffers()
        }
    }
    
    @Published var blueCoefficients = [Float](repeating: 0,
                                            count: PolynomialTransformer.count)
    
    @Published var blueValues: [Double]! {
        didSet {
            applyPolynomial(values: blueValues,
                            source: &planarBlueSourceBuffer,
                            coefficientsDestination: &blueCoefficients,
                            destination: &planarBlueDestinationBuffer)
            
            displayPlanarDestinationBuffers()
        }
    }
    
    /// The Vandermonde matrix that calculates the polynomial coefficients.
    let vandermonde: [[Double]] = vDSP.ramp(
        in: Double() ... 255,
        count: PolynomialTransformer.count).map { base in
            
            let bases = [Double](repeating: base,
                                 count: PolynomialTransformer.count)
            let exponents = vDSP.ramp(
                in: Double() ... 4,
                count: PolynomialTransformer.count)
            
            return vForce.pow(bases: bases,
                              exponents: exponents)
    }
    
    override init() {
        super.init()
        setup()
    }
    
    func setup() {
        /// If the source image has a dimension greater than 1024 pixels, resize to fit within a 1024 x 1024
        /// bounding box. This improves performance in the app. In a production app, you save or export
        /// a final image that matches the original image's dimensions.
        let maxDimension: CGFloat = 1024
        if max(sourceImage!.size.width, sourceImage!.size.height) > maxDimension {

            let ratio = maxDimension / max(sourceImage!.size.width, sourceImage!.size.height)

            if let proxyImage = PolynomialTransformer.scaleImage(sourceImage!,
                                                                 ratio: ratio) {
                sourceImage = proxyImage
            } else {
                NSLog("`PolynomialTransformer.scaleImage` failed, using original image.")
            }
        }

//        var rect = CGRect(origin: .zero, size: sourceImage!.size)

        guard
            let sourceCGImage = sourceImage!.cgImage,
//            let sourceImageBuffer = try? vImage_Buffer(cgImage: sourceCGImage,
//                                                       format: sourceImageFormat),
//            let destinationImageBuffer = try? vImage_Buffer(size: sourceImageBuffer.size,
//                                                            bitsPerPixel: sourceImageFormat.bitsPerPixel),
            let sourceImageBuffer = try? vImage_Buffer(cgImage: sourceCGImage, format: sourceImageFormat),
            let destinationImageBuffer = try? vImage_Buffer(width: Int(sourceImageBuffer.width), height: Int(sourceImageBuffer.height), bitsPerPixel: sourceImageFormat.bitsPerPixel)
        else {
            fatalError("Error initializing `PolynomialTransformer` instance.")
        }

        outputImage = sourceCGImage

        self.sourceImageBuffer = sourceImageBuffer
        self.destinationImageBuffer = destinationImageBuffer

//        initializePlanarSourceBuffers(size: sourceImageBuffer.size)
        initializePlanarSourceBuffers(width: Int(sourceImageBuffer.width), height: Int(sourceImageBuffer.height))
//
        /// Create default values for each color channel that represent a linear response curve.
        redValues = vDSP.ramp(in: 0 ... 255,
                              count: PolynomialTransformer.count)
        
        greenValues = vDSP.ramp(in: 0 ... 255,
                                count: PolynomialTransformer.count)
        
        blueValues = vDSP.ramp(in: 0 ... 255,
                               count: PolynomialTransformer.count)
        
        populatePlanarSourceBuffers()
        
        applyPolynomialsToAllChannels()
    }

    /// Initialize the planar image buffers.
//    func initializePlanarSourceBuffers(size: CGSize)
    
    func initializePlanarSourceBuffers(width: Int, height: Int) {
        guard
            let planarRedSourceBuffer = try? vImage_Buffer(width: width, height: height, bitsPerPixel: sourceImageFormat.bitsPerPixel),
            let planarGreenSourceBuffer = try? vImage_Buffer(width: width, height: height, bitsPerPixel: sourceImageFormat.bitsPerPixel),
            let planarBlueSourceBuffer = try? vImage_Buffer(width: width, height: height, bitsPerPixel: sourceImageFormat.bitsPerPixel),
            let planarRedDestinationBuffer = try? vImage_Buffer(width: width, height: height, bitsPerPixel: sourceImageFormat.bitsPerPixel),
            let planarGreenDestinationBuffer = try? vImage_Buffer(width: width, height: height, bitsPerPixel: sourceImageFormat.bitsPerPixel),
            let planarBlueDestinationBuffer = try? vImage_Buffer(width: width, height: height, bitsPerPixel: sourceImageFormat.bitsPerPixel),
            let planarAlphaBuffer = try? vImage_Buffer(width: width, height: height, bitsPerPixel: sourceImageFormat.bitsPerPixel)
        else{
            fatalError("Error initializing planar buffers.")
            
        }
        
        self.planarRedSourceBuffer = planarRedSourceBuffer
        self.planarGreenSourceBuffer = planarGreenSourceBuffer
        self.planarBlueSourceBuffer = planarBlueSourceBuffer
        
        self.planarRedDestinationBuffer = planarRedDestinationBuffer
        self.planarGreenDestinationBuffer = planarGreenDestinationBuffer
        self.planarBlueDestinationBuffer = planarBlueDestinationBuffer
        
        self.planarAlphaBuffer = planarAlphaBuffer
    }
    
    /// Populates the planar buffers from the interleaved source image buffer.
    func populatePlanarSourceBuffers() {
        var maxFloats: [Float] = [255, 255, 255, 255]
        var minFloats: [Float] = [0, 0, 0, 0]
        
        vImageConvert_ARGB8888toPlanarF(&sourceImageBuffer,
                                        &planarRedSourceBuffer,
                                        &planarGreenSourceBuffer,
                                        &planarBlueSourceBuffer,
                                        &planarAlphaBuffer,
                                        &maxFloats, &minFloats,
                                        vImage_Flags(kvImageNoFlags))
    }
    
    /// Applies the polynomials to each of the red, green, and blue planar image buffers.
    func applyPolynomialsToAllChannels() {
        applyPolynomial(values: redValues,
                        source: &planarRedSourceBuffer,
                        coefficientsDestination: &redCoefficients,
                        destination: &planarRedDestinationBuffer)
        
        applyPolynomial(values: greenValues,
                        source: &planarGreenSourceBuffer,
                        coefficientsDestination: &greenCoefficients,
                        destination: &planarGreenDestinationBuffer)
        
        applyPolynomial(values: blueValues,
                        source: &planarBlueSourceBuffer,
                        coefficientsDestination: &blueCoefficients,
                        destination: &planarBlueDestinationBuffer)
        
        displayPlanarDestinationBuffers()
    }
    
    /// Applies the polynomial with the coefficients you derive from the specified values to the specified image buffer.
    ///
    /// This function also overwrites `coefficientsDestination` with the calculated coefficients.
    func applyPolynomial(values: [Double],
                         source: inout vImage_Buffer,
                         coefficientsDestination: inout [Float],
                         destination: inout vImage_Buffer) {
        
        coefficientsDestination = calculateCoefficients(values: values).map {
            return Float($0)
        }
  
        coefficientsDestination.withUnsafeBufferPointer { coefficientsPtr in
            var coefficientsBaseAddress = coefficientsPtr.baseAddress
            vImagePiecewisePolynomial_PlanarF(&source,
                                              &destination,
                                              &coefficientsBaseAddress,
                                              [-.infinity, .infinity],
                                              UInt32(coefficientsDestination.count - 1),
                                              0,
                                              vImage_Flags(kvImageNoFlags))
        }
    }
    
    /// Sets the output image to an RGB representation of the transformed planar buffers.
    func displayPlanarDestinationBuffers() {
        var maxFloats: [Float] = [255, 255, 255, 255]
        var minFloats: [Float] = [0, 0, 0, 0]
        
        vImageConvert_PlanarFToARGB8888(&planarRedDestinationBuffer,
                                        &planarGreenDestinationBuffer,
                                        &planarBlueDestinationBuffer,
                                        &planarAlphaBuffer,
                                        &destinationImageBuffer,
                                        &maxFloats, &minFloats,
                                        vImage_Flags(kvImageNoFlags))

        guard let result = try? destinationImageBuffer.createCGImage(format: sourceImageFormat,
                                                                     flags: .printDiagnosticsToConsole)
        else {
            NSLog("Can't create output `CGImage`.")
            return
        }
        
        outputImage = result
    }
    
    /// Returns the coefficients for an interpolating polynomial using the Vandermonde Method from the
    /// specified values.
    ///
    /// The coefficients are the _x_ in _Ax = b_ where _A_ is a Vandermonde matrix and the elements
    /// of `b` are the five value sliders in the user interface.
    func calculateCoefficients(values: [Double]) -> [Double] {
        var a = vandermonde.flatMap { $0 }
        var b = values
        
        do {
            try PolynomialTransformer.solveLinearSystem(a: &a,
                                                        a_rowCount: values.count,
                                                        a_columnCount: values.count,
                                                        b: &b,
                                                        b_count: values.count)
        } catch {
            fatalError("Unable to solve linear system.")
        }
        
        return b
    }
}
