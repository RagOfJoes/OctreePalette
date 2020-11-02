//
//  PixelExtractor.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/1/20.
//

import UIKit

public enum PixelExtractorQuality: CGFloat {
    case low = 16
    case regular = 64
    case high = 256
    case none = 0
}

public class PixelExtractor {
    public let image: UIImage
    
    public init(_ img: UIImage) {
        image = img
    }
    
    /**
     * Resize Image to reduce number of operations
     * - Parameter newSize: Size to resize image to
     */
    fileprivate func resizeImage(newSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        // Disables HDR
        format.preferredRange = .standard
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let result = renderer.image { (context) in
            image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        }
        return result
    }
    
    /**
     * Generate an Array of Pixel Data from Image
     *
     * To ensure that performance and quality of extraction is balanced, omit argument.
     * Otherwise emit .high for a higher quality extraction and .low for better performance
     *
     * - Parameter quality: Quality of extraction
     */
    public func generatePixels(quality: PixelExtractorQuality = .regular) -> [PixelData] {
        // 1. Resize Image if needed
        var scaleDownSize: CGSize = image.size
        if quality != .none {
            if image.size.width < image.size.height {
                let ratio = image.size.height / image.size.width
                scaleDownSize = CGSize(width: quality.rawValue / ratio, height: quality.rawValue)
            } else {
                let ratio = image.size.width / image.size.height
                scaleDownSize = CGSize(width: quality.rawValue, height: quality.rawValue / ratio)
            }
        }
        let resizedImage = self.resizeImage(newSize: scaleDownSize)
        
        // 2. Convert Image to CGImage to enable extraction of more
        // data
        guard let cgImage = resizedImage.cgImage else { return [] }
        
        assert(cgImage.bitsPerPixel == 32, "OctreePalette.PixelExtractor.generatePixels failed: Library only supports 32-bit images")
        assert(cgImage.bitsPerComponent == 8,  "OctreePalette.PixelExtractor.generatePixels failed: Library only supports 8 bit per channel")
        
        guard let imageData = cgImage.dataProvider?.data as Data? else {
            return []
        }
        
        // 3. Extract and allocate image's bitmap data
        let size = cgImage.width * cgImage.height
        let buffer = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: size)
        _ = imageData.copyBytes(to: buffer)
        var result = [PixelData]()
        result.reserveCapacity(size)
        
        for pixel in buffer {
            var r: UInt32 = 0
            var g: UInt32 = 0
            var b: UInt32 = 0
            
            // 3a. Get Pixel Format
            if cgImage.byteOrderInfo == .orderDefault || cgImage.byteOrderInfo == .order32Big {
                r = pixel & 255
                g = (pixel >> 8) & 255
                b = (pixel >> 16) & 255
            } else if cgImage.byteOrderInfo == .order32Little {
                r = (pixel >> 16) & 255
                g = (pixel >> 8) & 255
                b = pixel & 255
            }
            let color = PixelData(red: r, green: g, blue: b)
            result.append(color)
        }
        return result
    }
}
