//
//  DomainColors.swift
//  OctreePalette
//
//  Created by Victor Ragojos on 11/5/20.
//

import Foundation

public struct DomainColors {
    public var background: PixelData!
    public var primary: PixelData!
    public var secondary: PixelData!
    public var tertiary: PixelData!
    
    public init(background: PixelData, primary: PixelData, secondary: PixelData, tertiary: PixelData) {
        self.background = background
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }
}
