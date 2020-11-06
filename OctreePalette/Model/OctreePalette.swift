//
//  OctreePalette.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/1/20.
//

import UIKit

fileprivate typealias Palette = (color: PixelData, count: Int)

public class OctreePalette {
    public static let MAX_DEPTH = 8
    
    private var root: OctreeNode!
    private var levels: [[OctreeNode]?]
    
    public init() {
        self.levels = [[OctreeNode]](repeating: [OctreeNode](), count: OctreePalette.MAX_DEPTH)
        self.root = OctreeNode(level: 0, parent: self)
    }
    
    func addLevelNode(level: Int, node: OctreeNode) -> Void {
        levels[level]?.append(node)
    }
    
    public func addColor(color: PixelData) {
        root.insert(color: color, at: 0, of: self)
    }
    
    private func buildPalette(colorCount: Int) -> [Palette] {
        var leafCount = root.leafNodes.count
        
        var paletteIndex = 0
        var palette: [Palette] = [Palette]()
        
        // 1. Reduce Leaf Nodes
        for level in stride(from: OctreePalette.MAX_DEPTH - 1, through: 0, by: -1) {
            if levels[level] != nil {
                for node in levels[level]! {
                    leafCount -= node.removeLeaves()
                    if leafCount <= colorCount {
                        break
                    }
                }
                
                if leafCount <= colorCount {
                    break
                }
                levels[level] = []
            }
        }
        
        var leafNodes = root.leafNodes
        leafNodes.sort {
            $0!.pixelCount > $1!.pixelCount
        }
        
        // 2. Build Palette
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
        
        // 3. Sort by count
        palette.sort {
            return $0.count > $1.count
        }
        
        // 4. Reset
        root = OctreeNode(level: 0, parent: self)
        
        return palette
    }
    
    /**
     * Makes  a palette from an array of colors
     * - Parameter colorCount: How much color to extract
     */
    public func makePalette(colorCount: Int) -> [PixelData] {
       let palette = buildPalette(colorCount: colorCount)
        
        var res: [PixelData] = [PixelData]()
        for node in palette {
            res.append(node.color)
        }
                
        return res
    }
    
    /**
     * Get domain colors of an Image
     * - Parameter image: Image to generate domain colors from
     */
    public func getDomainColors(from image: UIImage) -> DomainColors {
        // To reduce the change of colors not being returned
        // we'll set a minimum of 255
        let COLOR_COUNT: Int = 255
        var domainColors: [PixelData?] = [PixelData?](repeating: nil, count: 4)
        
        // 1. Resizes image, then retrieves colors from its pixels
        // Add colors to instance to be evaluated
        let pixels = PixelExtractor(image).generatePixels()
        for pixel in pixels {
            addColor(color: pixel)
        }
        
        // 2. Build Palette
        let palette = buildPalette(colorCount: COLOR_COUNT)
                
        // 3. Check for edge cases
        if palette.count > 0 {
            domainColors[0] = palette[0].color
        } else {
            domainColors[0] = PixelData(red: 0, green: 0, blue: 0)
        }
        
        // 4. Retrieve domain colors from generated palette
        let background = domainColors[0]!
        for node in palette {
            let color = node.color
            
            if domainColors[1] == nil && color.constrasts(color: background) && background.distinct(from: color) {
                domainColors[1] = color
            } else if domainColors[2] == nil {
                guard let primary = domainColors[1] else {
                    continue
                }
                
                if color.constrasts(color: background) && primary.distinct(from: color) {
                    domainColors[2] = color
                }
            } else if domainColors[3] == nil {
                guard let primary = domainColors[1] else {
                    continue
                }
                
                
                guard let secondary = domainColors[2] else {
                    continue
                }
                
                if color.constrasts(color: background) && primary.distinct(from: color) && secondary.distinct(from: color) {
                    domainColors[2] = color
                    break
                }
            }
        }
        
        // 5. Fill any uninitialized colors
        for i in 1...3 {
            if domainColors[i] == nil {
                domainColors[i] = background.isDark ? PixelData(red: 255, green: 255, blue: 255) : PixelData(red: 0, green: 0, blue: 0)
            }
        }
        
        return DomainColors(background: background, primary: domainColors[1]!, secondary: domainColors[2]!, tertiary: domainColors[3]!)
    }
}
