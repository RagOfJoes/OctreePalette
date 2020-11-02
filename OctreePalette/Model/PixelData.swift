//
//  PixelData.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/1/20.
//

import Foundation

public class PixelData {
    public var red: UInt32
    public var green: UInt32
    public var blue: UInt32
    
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
}
