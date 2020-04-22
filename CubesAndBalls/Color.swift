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
    case orange = 4
    case purple = 5
    
    var value: UIColor {
        switch self {
        case .blue:
            return UIColor.systemBlue
        case .green:
            return UIColor.systemGreen
        case .orange:
            return UIColor.systemOrange
        case .purple:
            return UIColor.systemPurple
        case .red:
            return UIColor.systemRed
        case .yellow:
            return UIColor.systemYellow
        }
    }
    
    static func random() -> Color {
        return Color(rawValue: Int.random(in: 0...5)) ?? Color.red
    }
    
    static func value(ofUIColor color: UIColor) -> Color? {
        switch color {
        case .systemBlue:
            return .blue
        case .systemGreen:
            return .green
        case .systemOrange:
            return .orange
        case .systemPurple:
            return .purple
        case .systemRed:
            return .red
        case .systemYellow:
            return .yellow
        default:
            return nil
        }
    }
}
