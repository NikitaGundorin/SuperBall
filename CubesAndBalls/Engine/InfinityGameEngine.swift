//
//  InfinityGameEngine.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 13.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class InfinityGameEngine: GameEngine {
    private var timer = Timer()
    private var currentSpeed: Double {
        let speed = 2.25 - 0.05 * Double(cubesCount)
        if speed <= 0.5 {
            return 0.5
        }
        return speed
    }
    
    override var scoreLabelText: String? {
        guard status != .pause else { return nil }
        return "SCORE: \(cubesCount)"
    }
    
    override init() {
        super.init()

        currentLevel = try! LevelsDataProvider.shared.getLevel(withNumber: 0)
    }
    
    override func setBall() {}
    
    override func newGameWillStart() {
        stopTimer()
        addTargetNodes(count: 100)
        if let record = UserDefaults.standard.value(forKey: "record") as? Int {
            vc?.roundLabel.text = "\(record)"
        } else {
            vc?.roundLabel.text = "0"
        }
        vc?.ballButton.isEnabled = false
    }
    
    override func newGameDidStart() {
        runTimer()
    }
    
    override func gameWillEnd() {
        stopTimer()
        guard let record = UserDefaults.standard.value(forKey: "record") as? Int
            else {
                if cubesCount > 0 {
                    UserDefaults.standard.setValue(cubesCount, forKey: "record")
                    status = .newRecord
                }
                return
            }
        
        if cubesCount > record {
            status = .newRecord
            UserDefaults.standard.setValue(cubesCount, forKey: "record")
        }
    }
    
    override func countScore() {
        cubesCount += 1
        addNode()
    }
    
    override func pauseGame() {
        stopTimer()
        status = .pause
        setRecord()
    }
    
    override func resumeGame() {
        runTimer()
    }
    
    override func checkBallAfterThrow(ball: Ball) {
        if ball.parent != nil {
            ball.removeFromParentNode()
        }
    }
    
    private func addNode() {
        let color = Color.random()
        colors.append(color)
        
        let range = getPositionRange(numberOfBoxes: 100)
        let box = Box(color: color, positionRange: range)
        
        vc?.sceneView.scene.rootNode.addChildNode(box)
    }
    
    private func setRecord() {
        guard let record = UserDefaults.standard.value(forKey: "record") as? Int else {
            UserDefaults.standard.setValue(cubesCount, forKey: "record")
            return
        }
        if cubesCount > record {
            UserDefaults.standard.setValue(cubesCount, forKey: "record")
        }
    }
    
    private func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: currentSpeed, target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
        animateBallButton()
    }
    
    private func stopTimer() {
        timer.invalidate()
    }
    
    @objc private func updateTimer() {
        stopTimer()
        throwBall()
        ballColor = getRandomColor()
        runTimer()
    }
    
    private var circleLayer = CAShapeLayer()
    
    private func animateBallButton() {
        guard let button = vc?.ballButton else { return }
        circleLayer.removeFromSuperlayer()
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: button.frame.size.width / 2.0, y: button.frame.size.height / 2.0),
                                      radius: (button.frame.size.width + 10)/2,
                                      startAngle: CGFloat(-Double.pi / 2),
                                      endAngle: CGFloat(Double.pi * 2.0 - Double.pi / 2),
                                      clockwise: true)

        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = ballColor.value.cgColor
        circleLayer.lineWidth = 5.0;
        circleLayer.strokeEnd = 0.0

        button.layer.addSublayer(circleLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = currentSpeed
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        circleLayer.strokeEnd = 1.0

        circleLayer.add(animation, forKey: "animateCircle")
    }
}
