//
//  PhysicsContactDelegate.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 22.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class GameViewModel: NSObject {
    weak var vc: GameViewController?
    var currentLevel: Level = {
        do {
            return try LevelsDataProvider.shared.getCurrentLevel()
        } catch {
            print(error.localizedDescription)
            return Level()
        }
    }()
    
    var score = 0 {
        didSet {
            vc?.cubesCountLabel.text = "\(score)"
        }
    }
    var status: GameStatus?
    private var colors: [Color] = []
    private var timer = Timer()
    private var isBallThrown = false {
        didSet {
            vc?.ballButton.isEnabled = isBallThrown ? false : true
        }
    }
    
    private var ballColor: Color! {
        didSet {
            vc?.ballButton.backgroundColor = ballColor.value
        }
    }
    
    private var seconds: Int = 0 {
        didSet {
            vc?.roundLabel.text = "\(seconds)"
        }
    }

    func throwBall() {
        let (direction, position) = getUserVector()
        let ball = Ball(color: ballColor, direction: direction, position: position)
        vc?.sceneView.scene.rootNode.addChildNode(ball)
        isBallThrown = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if ball.parent != nil {
                ball.removeFromParentNode()
                self.setBall()
            }
        }
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
    
    func startGame() {
        guard let vc = vc else { return }
        stopTimer()
        score = 0
        colors = []
        seconds = Int(currentLevel.timeLimit)
        vc.sceneView.scene.rootNode.childNodes.filter{$0.name == "box"}.forEach{$0.removeFromParentNode()}
        addTargetNodes()
        setBall()
        runTimer()
    }
    
    private func endGame(status: GameStatus) {
        stopTimer()
        self.status = status
        if status == .win {
            LevelsDataProvider.shared.levelUp()
            do {
                self.currentLevel = try LevelsDataProvider.shared.getCurrentLevel()
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        vc?.endGame(status: status)
    }
    
    private func setBall() {
        if colors.count == 0 {
            endGame(status: .win)
            return
        }
        let color = getRandomColor()
        ballColor = color
        
        isBallThrown = false
    }
    
    private func addTargetNodes() {
        for _ in 1...currentLevel.cubesCount {
            let color = Color.random()
            colors.append(color)
            
            let range = getPositionRange(numberOfBoxes: currentLevel.cubesCount)
            let box = Box(color: color, positionRange: range)
            
            vc?.sceneView.scene.rootNode.addChildNode(box)
        }
    }
    
    @objc private func updateTimer() {
        if seconds == 0 {
            stopTimer()
            endGame(status: .timesUp)
            return
        }
        
        seconds -= 1
    }
    
    private func getRandomColor() -> Color {
        var color: Color
        repeat {
            color = Color.random()
        } while !self.colors.contains(color)
        
        return color
    }
    
    private func getUserVector() -> (SCNVector3, SCNVector3) {
        if let frame = vc?.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    private func getPositionRange(numberOfBoxes: Int16) -> BoxPositionRange {
        var max = 0.08 * Float(numberOfBoxes) + 1.6
        switch max {
        case ...2:
            max = 2
        case 10...:
            max = 10
        default:
            break
        }
        
        return BoxPositionRange(x: (-max, max), y: (-max, max), z: (-10, -2))
    }
}

extension GameViewModel: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard let nodeAPhysicsBody = contact.nodeA.physicsBody,
            let nodeBPhysicsBody = contact.nodeB.physicsBody,
            nodeAPhysicsBody.categoryBitMask == CollisionCategory.boxCategory.rawValue
                && nodeBPhysicsBody.categoryBitMask == CollisionCategory.ballCategory.rawValue
                || nodeAPhysicsBody.categoryBitMask == CollisionCategory.ballCategory.rawValue
                && nodeBPhysicsBody.categoryBitMask == CollisionCategory.boxCategory.rawValue
            else { return }
        
        guard let nodeAColor = contact.nodeA.geometry?.firstMaterial?.diffuse.contents as? UIColor,
            let nodeBColor = contact.nodeB.geometry?.firstMaterial?.diffuse.contents as? UIColor,
            nodeAColor == nodeBColor
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    if (contact.nodeA.parent != nil && contact.nodeB.parent != nil) {
                        self.endGame(status: .wrongColor)
                        contact.nodeA.removeFromParentNode()
                        contact.nodeB.removeFromParentNode()
                    }
                }
                return
        }
        
        DispatchQueue.main.async {
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
            self.score += 1
            if let color = Color.value(ofUIColor: nodeAColor),
                let index = self.colors.lastIndex(of: color) {
                self.colors.remove(at: index)
                self.setBall()
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        let explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
        explosion?.particleColor = nodeAColor
        contact.nodeB.addParticleSystem(explosion!)
    }
}
