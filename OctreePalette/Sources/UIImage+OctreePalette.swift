//
//  UIImage+OctreePalette.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/17/20.
//

import UIKit

extension UIImage {
    /**
     * Get the color theme from an Image asynchronously
     * - Parameter tolerance: Controls how distinct returned colors are from one another.  0 indicates the lowest color difference, 100 indicates complete distortion
     * - Parameter quality: Image quality to extract colors from. It's recommended to omit this option to ensure performance isn't reduced significantly
     * - Parameter completion: Completion handler
     */
    public func getColorTheme(tolerance: Int = 42, quality: PixelExtractorQuality = .regular) -> ColorTheme {
        let octreePalette: OctreePalette = OctreePalette()
        return octreePalette.getColorTheme(from: self, tolerance: tolerance, quality: quality)
    }
    
    /**
     * Get the color theme from an Image asynchronously
     * - Parameter tolerance: Controls how distinct returned colors are from one another.  0 indicates the lowest color difference, 100 indicates complete distortion
     * - Parameter quality: Image quality to extract colors from. It's recommended to omit this option to ensure performance isn't reduced significantly
     * - Parameter completion: Completion handler
     */
    public func getColorTheme(tolerance: Int = 42, quality: PixelExtractorQuality = .regular, _ completion: @escaping (ColorTheme) -> Void) {
        let octreePalette: OctreePalette = OctreePalette()
        octreePalette.getColorTheme(from: self, tolerance: tolerance, quality: quality, completion)
    }
}
