//
//  Data.swift
//  OctreePaletteExample
//
//  Created by Victor Ragojos on 11/16/20.
//

import UIKit

enum DataType {
    case theme
    case palette
}

struct Data {
    let image: UIImage
    let type: DataType
}
