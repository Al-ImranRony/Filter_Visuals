//
//  PolynomialTransformer+ImageResize.swift
//  FilterVisuals
//
//  Created by Bitmorpher 4 on 11/2/21.
//

import Foundation
import UIKit
import Accelerate

// `NSImage` Resize Function

extension PolynomialTransformer {
    
    // Returns a new `NSImage` instance that's a scaled copy of the specified image.
    static func scaleImage(_ sourceImage: UIImage, ratio: CGFloat) -> UIImage? {
        

        let scaledSize = CGSize(width: floor(sourceImage.size.width * ratio),
                               height: floor(sourceImage.size.height * ratio))
//        var rect = CGRect(origin: .zero, size: sourceImage.size)
        
        guard
            let cgImage = sourceImage.cgImage,
            let format = vImage_CGImageFormat(cgImage: cgImage),
            var sourceBuffer = try? vImage_Buffer(cgImage: cgImage,
                                             format: format),
//            var destinationBuffer = try? vImage_Buffer(size: scaledSize,
//                                                  bitsPerPixel: format.bitsPerPixel) else {
            var destinationBuffer = try? vImage_Buffer(width:Int(scaledSize.width), height: Int(scaledSize.height), bitsPerPixel: format.bitsPerPixel)
        else{
            return nil
        }

        defer {
            sourceBuffer.free()
            destinationBuffer.free()
        }
        
        vImageScale_ARGB8888(&sourceBuffer,
                             &destinationBuffer,
                             nil,
                             vImage_Flags(kvImageNoFlags))
        
        if let scaledImage = try? destinationBuffer.createCGImage(format: format) {
            return UIImage(cgImage: scaledImage)
        } else {

            return nil
        }
    }
}
