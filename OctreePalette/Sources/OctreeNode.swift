//
//  OctreeNode.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/1/20.
//

import Foundation

public class OctreeNode {
    // MARK: - Internal Properties
    var pixelCount: Int
    let color: OctreeColor
    var paletteIndex: Int
    var children: [OctreeNode?]
    
    var isLeaf: Bool {
        get {
            return pixelCount > 0
        }
    }
    var leafNodes: [OctreeNode?] {
        get {
            var array: [OctreeNode?] = [OctreeNode?]()
            for node in children {
                if node == nil {
                    continue
                }
                
                let unwrappedNode = node!
                if unwrappedNode.isLeaf {
                    array.append(unwrappedNode)
                } else {
                    array.append(contentsOf: unwrappedNode.leafNodes)
                }
                
            }
            return array
        }
    }
    
    // MARK: - Life Cycle
    init(level: Int, parent: OctreePalette) {
        self.color = OctreeColor(red: 0, green: 0, blue: 0)
        self.pixelCount = 0
        self.paletteIndex = 0
        self.children = [OctreeNode?](repeating: nil, count: OctreePalette.MAX_DEPTH)
        
        // Add Node to current level
        if level < OctreePalette.MAX_DEPTH - 1 {
            parent.addLevelNode(level: level, node: self)
        }
    }
}

// MARK: - Mutations
extension OctreeNode {
    /**
     * Insert a color into node
     */
    func insert(color: OctreeColor, at level: Int, of parent: OctreePalette) -> Void {
        if level >= OctreePalette.MAX_DEPTH {
            self.color.add(color: color)
            self.pixelCount += 1
            return
        }
        
        let index: Int = getColorIndex(for: level, color: color)
        
        if children[index] == nil {
            children[index] = OctreeNode(level: level, parent: parent)
        }
        
        children[index]!.insert(color: color, at: level + 1, of: parent)
    }
    
    /**
     * Add leafNodes pixel count and color channels into Parent node
     *
     * - Returns: Count of all removed leaves
     */
    func removeLeaves() -> Int {
        var result: Int = 0
        for node in leafNodes {
            if node != nil {
                self.color.add(color: node!.color)
                self.pixelCount += node!.pixelCount
                result += 1
            }
        }
        return result - 1
    }
}

// MARK: - Getters
extension OctreeNode {
    /**
     * Get Palette Index for `color` and traverse a `level` deeper if not a leaf
     *
     * - Returns: The Palette Index for color
     */
    func getPaletteIndex(color: OctreeColor, level: Int) -> Int {
        var result: Int!
        if isLeaf {
            return paletteIndex
        }
        
        let index = getColorIndex(for: level, color: color)
        if leafNodes[index] != nil {
            return children[index]!.getPaletteIndex(color: color, level: level + 1)
        } else {
            for node in children {
                if node != nil {
                    result = node!.getPaletteIndex(color: color, level: level + 1)
                    break
                }
            }
        }
        
        return result
    }
    
    func getColorIndex(for level: Int, color: OctreeColor) -> Int {
        var index: Int = 0
        
        // 128 bits
        let bits: UInt32 = 0x80
        
        // Bit masking
        // Possible shifted values with a max depth of 8
        // Level: 0, Binary: 10000000, Decimal: 128
        // Level: 1, Binary: 01000000, Decimal: 64
        // Level: 2, Binary: 00100000, Decimal: 32
        // Level: 3, Binary: 00010000, Decimal: 16
        // Level: 4, Binary: 00001000, Decimal: 8
        // Level: 5, Binary: 00000100, Decimal: 4
        // Level: 6, Binary: 00000010, Decimal: 2
        // Level: 7, Binary: 00000001, Decimal: 0
        let mask = bits >> level
        
        // bit masked 4
        if ((color.red & mask) != 0) {
            index |= 0b100
        }
        
        // bit masked 2
        if ((color.green & mask) != 0)  {
            index |= 0b010
        }
        
        // bit masked 1
        if ((color.blue & mask) != 0)  {
            index |= 0b001
        }
        
        return index
    }
}
