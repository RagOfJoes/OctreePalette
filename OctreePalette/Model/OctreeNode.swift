//
//  OctreeNode.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/1/20.
//

import Foundation

public class OctreeNode {
    // MARK: - Internal Properties
    let color: PixelData
    
    var pixelCount: Int
    var paletteIndex: Int
    
    var children: [OctreeNode?] = [OctreeNode?]()
    
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
    
    var normalizedColor: PixelData {
        get {
            return PixelData(red: self.color.red / UInt32(self.pixelCount), green: self.color.green / UInt32(self.pixelCount), blue: self.color.blue / UInt32(self.pixelCount))
        }
    }
    
    // MARK: - Life Cycle
    init(level: Int, parent: OctreePalette) {
        self.color = PixelData(red: 0, green: 0, blue: 0)
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
    public func insert(color: PixelData, at level: Int, of parent: OctreePalette) -> Void {
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
    
    public func removeLeaves() -> Int {
        var result: Int = 0
        for node in leafNodes {
            if node != nil {
                self.color.add(color: node!.color)
                self.pixelCount += node!.pixelCount
                result += 1
            }
        }
        children = []
        return result - 1
    }
}

// MARK: - Getters
extension OctreeNode {
    public func getPaletteIndex(color: PixelData, level: Int) -> Int {
        var result: Int!
        if isLeaf {
            return paletteIndex
        }
        
        let index = getColorIndex(for: level, color: color)
        if leafNodes[index] != nil {
            result = leafNodes[index]?.getPaletteIndex(color: color, level: level + 1)
        } else {
            for node in leafNodes {
                if node != nil {
                    return node!.getPaletteIndex(color: color, level: level + 1)
                }
            }
        }
        
        return result
    }
    
    fileprivate func getColorIndex(for level: Int, color: PixelData) -> Int {
        var index: Int = 0
        
        // 128 bits
        let bits: UInt32 = 0b10000000
        
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
