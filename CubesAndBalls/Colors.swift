//
//  Colors.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 21.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation
import UIKit

enum Colors: Int {
    case red = 0
    case green = 1
    case blue = 2
    case yellow = 3
    case pink = 4
    case purple = 5
    
    var value: UIColor {
        switch self {
        case .blue:
            return UIColor.systemBlue
        case .green:
            return UIColor.systemGreen
        case .pink:
            return UIColor.systemPink
        case .purple:
            return UIColor.systemPurple
        case .red:
            return UIColor.systemRed
        case .yellow:
            return UIColor.systemYellow
        }
    }
}
