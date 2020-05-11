//
//  Color.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 21.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation
import UIKit

enum Color: Int {
    case red = 0
    case green = 1
    case blue = 2
    case yellow = 3
    case purple = 4
    
    var value: UIColor {
        switch self {
        case .blue:
            return Appearance.blue
        case .green:
            return Appearance.green
        case .purple:
            return Appearance.purple
        case .red:
            return Appearance.red
        case .yellow:
            return Appearance.yellow
        }
    }
    
    static func random() -> Color {
        return Color(rawValue: Int.random(in: 0...5)) ?? Color.red
    }
    
    static func value(ofUIColor color: UIColor) -> Color? {
        switch color {
        case Appearance.blue:
            return .blue
        case Appearance.green:
            return .green
        case Appearance.purple:
            return .purple
        case Appearance.red:
            return .red
        case Appearance.yellow:
            return .yellow
        default:
            return nil
        }
    }
}
