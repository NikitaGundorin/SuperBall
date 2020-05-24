//
//  BallGameEngine.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 12.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation

class BallGameEngine: GameEngine {
    private var ballsCount: Int = 0 {
        didSet {
            vc?.roundLabel.text = "\(ballsCount)"
        }
    }
    
    override func newGameWillStart() {
        ballsCount = Int(currentLevel.ballsCount)
    }
    
    override func countBall() {
        ballsCount -= 1
    }
    
    override func checkBallAvailable() {
        if ballsCount == 0 {
            endGame(status: .ballsOver)
        }
    }
    
    override func addExtraLife() {
        ballsCount += 1
        hasExtra = true
    }
    
    override func addExtra() {
        ballsCount += 10
        hasExtra = true
        status = .extraAdded
    }
}
