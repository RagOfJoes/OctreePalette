//
//  PixelData.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/1/20.
//

import UIKit

public class PixelData {
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
    
    init(red: UInt32, green: UInt32, blue: UInt32) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    public func add(color: PixelData) {
        red += color.red
        green += color.green
        blue += color.blue
    }
    
    public func normalize(with pixelCount: Int) -> PixelData {
        return PixelData(red: self.red / UInt32(pixelCount), green: self.green / UInt32(pixelCount), blue: self.blue / UInt32(pixelCount))
    }
}

// MARK: - Comparators
extension PixelData {
    public func constrasts(color: PixelData) -> Bool {
        let darkerColor = max(self.luminance, color.luminance)
        let lighterColor = min(self.luminance, color.luminance)
        let ratio = 1 / ((lighterColor + 0.05) / (darkerColor + 0.05))
        
        return ratio > 1.8
    }
    
    public func distinct(from color: PixelData) -> Bool {
        let otherRed = color.red
        let otherGreen = color.green
        let otherBlue = color.blue
        
        return (abs(Float(self.red) - Float(otherRed)) > 63.75 || abs(Float(self.green) - Float(otherGreen)) > 63.75 || abs(Float(self.blue) - Float(otherBlue)) > 63.75) && !(abs(Float(self.red) - Float(self.green)) < 7.65 && abs(Float(self.red) - Float(self.blue)) < 7.65 && abs(Float(otherRed) - Float(otherGreen)) < 7.65 && abs(Float(otherRed) - Float(otherBlue)) < 7.65)
    }
}
