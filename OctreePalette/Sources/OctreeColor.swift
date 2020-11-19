//
//  OctreeColor.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/1/20.
//

import UIKit

public class OctreeColor {
    // MARK: - Internal Properties
    public var red: UInt32
    public var green: UInt32
    public var blue: UInt32
    public var isDark: Bool {
        get {
            return luminance < 0.5
        }
    }
    public var uiColor: UIColor {
        get {
            return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
        }
    }
    public var HexCode: String {
        get {
            return String(format:"#%02X%02X%02X", self.red, self.green, self.blue)
        }
    }
    public var debug: String {
        get {
            return "Red: \(red), Green: \(green), Blue: \(blue)"
        }
    }
    fileprivate var luminance: CGFloat {
        get {
            let colorArray = [red, green, blue]
            
            let array = colorArray.map { (v) -> CGFloat in
                let float = CGFloat(v) / 255
                return float <= 0.03928
                    ? float / 12.92
                    : pow((float + 0.055) / 1.055, 2.4)
            }
            
            return array[0] * 0.2126 + array[1] * 0.7152 + array[2] * 0.0722
        }
    }
    
    // MARK: - Life Cycle
    init(red: UInt32, green: UInt32, blue: UInt32) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

// MARK: - Helpers
extension OctreeColor {
    public func add(color: OctreeColor) {
        self.red += color.red
        self.green += color.green
        self.blue += color.blue
    }
    
    public func normalize(with pixelCount: Int) -> OctreeColor {
        return OctreeColor(red: self.red / UInt32(pixelCount), green: self.green / UInt32(pixelCount), blue: self.blue / UInt32(pixelCount))
    }
    
    public func contrasts(color: OctreeColor, threshold: CGFloat = 7.0) -> Bool {
        let darkerColor = max(self.luminance, color.luminance)
        let lighterColor = min(self.luminance, color.luminance)
        let ratio = (darkerColor + 0.05) / (lighterColor + 0.05)
        
        return ratio > threshold
    }
}

// MARK: - Delta E
extension OctreeColor {
    /**
     * Transforms RGB ito XYZ Color Space
     * ### Reference
     * [Wikipeda](https://en.wikipedia.org/wiki/SRGB#The_forward_transformation_(CIE_XYZ_to_sRGB))
     */
    public var XYZColor: (X: CGFloat, Y: CGFloat, Z: CGFloat) {
        get {
            // Converts RGB values to within 0 to 1 range
            var r: CGFloat = CGFloat(self.red) / 255
            var g: CGFloat = CGFloat(self.green) / 255
            var b: CGFloat = CGFloat(self.blue) / 255
            
            let u: CGFloat = 0.4045
            
            if r <= u {
                r /= 12.92
            } else {
                r = pow(((r + 0.055) / 1.055), 2.4)
            }
            
            if g <= u {
                g /= 12.92
            } else {
                g = pow(((r + 0.055) / 1.055), 2.4)
            }
            
            if b <= u {
                b /= 12.92
            } else {
                b = pow(((r + 0.055) / 1.055), 2.4)
            }
            
            r *= 100
            g *= 100
            b *= 100
            
            // For Illuminant D65
            let x: CGFloat = r * 0.4124 + g * 0.3576 + b * 0.1805
            let y: CGFloat = r * 0.2126 + g * 0.7152 + b * 0.0722
            let z: CGFloat = r * 0.0193 + g * 0.1192 + b * 0.9505
            
            return (x, y, z)
        }
    }
    
    /**
     * Transforms XYZ to LAB Color Space
     * ### Reference
     * [Wikipedia](https://en.wikipedia.org/wiki/CIELAB_color_space#From_CIEXYZ_to_CIELAB)
     */
    public var LABColor: (L: CGFloat, A: CGFloat, B: CGFloat) {
        get {
            let refX: CGFloat = 95.047
            let refY: CGFloat = 100.0
            let refZ: CGFloat = 108.883
            
            // For Illuminant D65
            var X: CGFloat = self.XYZColor.X / refX
            var Y: CGFloat = self.XYZColor.Y / refY
            var Z: CGFloat = self.XYZColor.Z / refZ
            
            let t: CGFloat = 0.008856
            
            if X > t {
                X = pow(X, 1 / 3.0)
            } else {
                X = (7.787 * X) + (16.0 / 116.0)
            }
            if Y > t {
                Y = pow(Y, 1 / 3.0)
            } else {
                Y = (7.787 * Y) + (16.0 / 116.0)
            }
            if Z > t {
                Z = pow(Z, 1 / 3.0)
            } else {
                Z = (7.787 * Z) + (16.0 / 116.0)
            }
            
            let L: CGFloat = 116 * Y - 16
            let A: CGFloat = 500 * (X - Y)
            let B: CGFloat = 200 * (Y - Z)
            
            return (L, A, B)
        }
    }
    
    /**
     * Get Delta E
     * - Parameter other: The other color to compare to
     *
     * ### Reference
     * [Wikipedia](https://en.wikipedia.org/wiki/Color_difference#CIE76)
     */
    public func getDeltaE(with other: OctreeColor) -> CGFloat {
        let L1: CGFloat = self.LABColor.L
        let A1: CGFloat = self.LABColor.A
        let B1: CGFloat = self.LABColor.B
        let L2: CGFloat = other.LABColor.L
        let A2: CGFloat = other.LABColor.A
        let B2: CGFloat = other.LABColor.B
        
        return sqrt(pow(L1 - L2, 2) + pow(A1 - A2, 2) + pow(B1 - B2, 2))
    }
    
    /**
     * Determine whether a color is perceptually different from another color using the Delta E formula.
     * - Parameter color: The other color to compare to
     * - Parameter tolerance: Controls how distinct returned colors are from one another.  0 indicates the lowest color difference, 100 indicates complete distortion
     */
    public func distinct(from color: OctreeColor, with tolerance: Int = 42) -> Bool {
        var fixedTolerance: Int = tolerance
        if tolerance < 0 {
            fixedTolerance = 0
        } else if tolerance > 100 {
            fixedTolerance = 100
        }
        let deltaE = self.getDeltaE(with: color)
        return deltaE > CGFloat(fixedTolerance)
    }
}
