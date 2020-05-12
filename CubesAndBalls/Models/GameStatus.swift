//
//  GameStatus.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 02.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation

enum GameStatus {
    case win
    case wrongColor
    case timeUp
    case ballsOver
    case none
    
    var titles: (title: String, button: String) {
        switch self {
        case .wrongColor:
            return ("WRONG COLOR", "EXTRA LIFE")
        case .timeUp:
            return ("TIME'S UP", "+30 SECS")
        case .ballsOver:
            return ("BALLS'RE OVER", "+10 BALLS")
        case .win:
            return ("YOU WON", "NEXT LEVEL")
        case .none:
            return ("", "")
        }
    }
}
