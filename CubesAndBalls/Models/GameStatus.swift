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
    case timesUp
    
    var message: String {
        switch self {
        case .win:
            return "You won!"
        case .wrongColor:
            return "Ooops! Wrong color!"
        case .timesUp:
            return "Time's up!"
        }
    }
}
