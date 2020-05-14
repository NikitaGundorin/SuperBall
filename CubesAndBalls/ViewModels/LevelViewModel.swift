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
    lazy var levelType: LevelType = {
        if ballsCount == 0 && cubesCount == 0 && timeLimit == 0 {
            return .infinityMode
        }
        if ballsCount == 0 {
            return .timeLimit
        }
        return .ballsLimit
    }()
    
    lazy var name: String = {
        switch levelType {
        case .infinityMode:
            return "INFINITY MODE"
        case .timeLimit, .ballsLimit:
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
        }
    }()
    
    init(level: Level) {
        number = Int(level.number)
        ballsCount = Int(level.ballsCount)
        cubesCount = Int(level.cubesCount)
        timeLimit = Int(level.timeLimit)
    }
}
