//
//  OctreePalette.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/1/20.
//

import UIKit

fileprivate typealias Palette = (color: OctreeColor, count: Int)

public enum ColorThemeType: CGFloat {
    case interface = 7.0
    
    case smallText = 3.5
    case largeText = 4.0
}

public class OctreePalette {
    // MARK: - Internal Properties
    public static let MAX_DEPTH = 8
    private var root: OctreeNode!
    private var levels: [[OctreeNode]?]
    
    // MARK: - Life Cycle
    public init() {
        self.levels = [[OctreeNode]](repeating: [OctreeNode](), count: OctreePalette.MAX_DEPTH)
        self.root = OctreeNode(level: 0, parent: self)
    }
    public func addColor(color: OctreeColor) {
        self.root.insert(color: color, at: 0, of: self)
    }
    func addLevelNode(level: Int, node: OctreeNode) -> Void {
        self.levels[level]?.append(node)
    }
    private func buildPalette(colorCount: Int) -> [Palette] {
        var leafCount = self.root.leafNodes.count
        
        var paletteIndex = 0
        var palette: [Palette] = [Palette]()
        
        // 1. Reduce Leaf Nodes
        for level in stride(from: OctreePalette.MAX_DEPTH - 1, through: 0, by: -1) {
            if self.levels[level] != nil {
                for node in self.levels[level]! {
                    leafCount -= node.removeLeaves()
                    if leafCount <= colorCount {
                        break
                    }
                }
                
                if leafCount <= colorCount {
                    break
                }
                self.levels[level] = []
            }
        }
        
        // 2. Sort by count
        var leafNodes = self.root.leafNodes
        leafNodes.sort {
            $0!.pixelCount > $1!.pixelCount
        }
        
        // 3. Build Palette
        for node in leafNodes {
            if paletteIndex >= colorCount {
                break
            }
            
            if node != nil, node!.isLeaf {
                let color = node!.color.normalize(with: node!.pixelCount)
                palette.append((color: color, count: node!.pixelCount))
            }
            node!.paletteIndex = paletteIndex
            paletteIndex += 1
        }
        
        return palette
    }
}

// MARK: - Exposed Functions
extension OctreePalette {
    /**
     * Makes  a palette from an array of colors
     * - Parameter colorCount: How much color to extract
     */
    public func makePalette(colorCount: Int) -> [OctreeColor] {
        let palette = self.buildPalette(colorCount: colorCount)
        
        var res: [OctreeColor] = [OctreeColor]()
        for node in palette {
            res.append(node.color)
        }
        
        return res
    }
    
    /**
     * Get the color theme from an Image
     * - Parameter image: Image to generate domain colors from
     * - Parameter tolerance: Controls how distinct returned colors are from one another.  0 indicates the lowest color difference, 100 indicates complete distortion
     * - Parameter type: Controls how contrasted other colors are from the background. Uses: [WCAG 2.0](https://www.w3.org/TR/UNDERSTANDING-WCAG20/visual-audio-contrast-contrast.html)
     * - Parameter quality: Image quality to extract colors from. It's recommended to omit this option to ensure performance isn't reduced significantly
     */
    public func getColorTheme(from image: UIImage, tolerance: Int = 50, type: ColorThemeType = .interface, quality: PixelExtractorQuality = .regular) -> ColorTheme {
        // To reduce the change of colors not being returned
        // we'll set a minimum of 255
        let COLOR_COUNT: Int = 255
        var colors: [OctreeColor?] = [OctreeColor?](repeating: nil, count: 4)
        
        // 1. Resizes image, then retrieves colors from its pixels
        // Add colors to instance to be evaluated
        let pixels = PixelExtractor(image).generatePixels(quality: quality)
        for pixel in pixels {
            self.addColor(color: pixel)
        }
        
        // 2. Build Palette
        let palette = self.buildPalette(colorCount: COLOR_COUNT)
        
        // 3. Check for edge cases
        if palette.count > 0 {
            colors[0] = palette[0].color
        } else {
            colors[0] = OctreeColor(red: 0, green: 0, blue: 0)
        }
        
        // 4. Retrieve color theme from generated palette
        let background = colors[0]!
        for node in palette {
            let color = node.color
            let constrastsFromBg: Bool = background.contrasts(color: color, threshold: type.rawValue)
            if colors[1] == nil {
                if constrastsFromBg {
                    colors[1] = color
                }
            } else if colors[2] == nil {
                guard let primary = colors[1] else {
                    continue
                }
                
                if constrastsFromBg && primary.distinct(from: color, with: tolerance) {
                    colors[2] = color
                }
            } else if colors[3] == nil {
                guard let primary = colors[1], let secondary = colors[2] else {
                    continue
                }
                
                if constrastsFromBg && primary.distinct(from: color, with: tolerance) && secondary.distinct(from: color, with: tolerance) {
                    colors[3] = color
                    break
                }
            }
        }
        
        // 5. Fill any uninitialized colors
        for i in 1...3 {
            if colors[i] == nil {
                colors[i] = background.isDark ? OctreeColor(red: 255, green: 255, blue: 255) : OctreeColor(red: 0, green: 0, blue: 0)
            }
        }
        
        let colorTheme: ColorTheme = ColorTheme(background: background, primary: colors[1]!, secondary: colors[2]!, tertiary: colors[3]!)
        
        return colorTheme
    }
    
    /**
     * Get the color theme from an Image asynchronously
     * - Parameter image: Image to generate domain colors from
     * - Parameter tolerance: Controls how distinct returned colors are from one another.  0 indicates the lowest color difference, 100 indicates complete distortion
     * - Parameter type: Controls how contrasted other colors are from the background. Uses: [WCAG 2.0](https://www.w3.org/TR/UNDERSTANDING-WCAG20/visual-audio-contrast-contrast.html)
     * - Parameter quality: Image quality to extract colors from. It's recommended to omit this option to ensure performance isn't reduced significantly
     * - Parameter completion: Completion handler
     */
    public func getColorTheme(from image: UIImage, tolerance: Int = 50, type: ColorThemeType = .interface, quality: PixelExtractorQuality = .regular, _ completion: @escaping (ColorTheme) -> Void) {
        DispatchQueue.global().async {
            let colorTheme = self.getColorTheme(from: image, tolerance: tolerance, type: type, quality: quality)
            
            completion(colorTheme)
        }
    }
}
