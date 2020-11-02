//
//  OctreePalette.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/1/20.
//

import Foundation

public class OctreePalette {
    public static let MAX_DEPTH = 8
    
    private var root: OctreeNode!
    private var levels: [[OctreeNode]?]
    
    public init() {
        self.levels = [[OctreeNode]](repeating: [OctreeNode](), count: OctreePalette.MAX_DEPTH)
        self.root = OctreeNode(level: 0, parent: self)
    }
    
    public func addColor(color: PixelData) {
        root.insert(color: color, at: 0, of: self)
    }
    
    public func makePalette(colorCount: Int) -> [PixelData] {
        var leafCount = root.leafNodes.count
        
        var paletteIndex = 0
        var palette: [PixelData] = [PixelData]()
        
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
        
        for node in root.leafNodes {
            if paletteIndex >= colorCount {
                break
            }
            
            if node != nil, node!.isLeaf {
                palette.append(node!.normalizedColor)
            }
            node!.paletteIndex = paletteIndex
            paletteIndex += 1
        }
        
        return palette
    }
    
    public func addLevelNode(level: Int, node: OctreeNode) -> Void {
        levels[level]?.append(node)
    }
}
