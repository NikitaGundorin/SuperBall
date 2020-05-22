//
//  LevelViewModel.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 13.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation

class LevelViewModel {
    let number: Int
    let ballsCount: Int
    let cubesCount: Int
    let timeLimit: Int
    let levelType: LevelType
    
    lazy var name: String = {
        switch levelType {
        case .infinityMode:
            return "INFINITY MODE"
        case .timeLimit, .ballsLimit, .oneColor:
            return "LEVEL \(number)"
        }
    }()
    
    lazy var engine: GameEngine = {
        switch levelType {
        case .infinityMode:
            return InfinityGameEngine()
        case .timeLimit:
            return TimeGameEngine()
        case .ballsLimit:
            return BallGameEngine()
        case .oneColor:
            return OneColorGameEngine()
        }
    }()
    
    init(level: Level) {
        number = Int(level.number)
        ballsCount = Int(level.ballsCount)
        cubesCount = Int(level.cubesCount)
        timeLimit = Int(level.timeLimit)
        levelType = LevelType(rawValue: level.levelType)!
    }
}
