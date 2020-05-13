//
//  TimeGameEngine.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 12.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation

class TimeGameEngine: GameEngine {
    private var timer = Timer()
    private var seconds: Int = 0 {
        didSet {
            vc?.roundLabel.text = "\(seconds)"
        }
    }
    
    override func prepareNewGame() {
        stopTimer()
        seconds = Int(currentLevel.timeLimit)
        runTimer()
    }
    
    override func prepareEndGame() {
        stopTimer()
    }
    
    override func pauseGame() {
        stopTimer()
        status = .pause
    }
    
    override func resumeGame() {
        runTimer()
    }
    
    override func addExtra() {
        seconds += 30
        hasExtra = true
        vc?.ballButton.isEnabled = true
        resumeGame()
    }
    
    func runTimer() {
        vc?.roundLabel.text = "\(seconds)"
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: (#selector(self.updateTimer)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @objc private func updateTimer() {
        if seconds == 0 {
            stopTimer()
            endGame(status: .timeUp)
            return
        }
        
        seconds -= 1
    }
}
