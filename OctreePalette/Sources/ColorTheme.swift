//
//  ColorTheme.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/5/20.
//

import Foundation

public struct ColorTheme {
    public var background: OctreeColor!
    public var primary: OctreeColor!
    public var secondary: OctreeColor!
    public var tertiary: OctreeColor!
    
    public init(background: OctreeColor, primary: OctreeColor, secondary: OctreeColor, tertiary: OctreeColor) {
        self.background = background
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }
}
