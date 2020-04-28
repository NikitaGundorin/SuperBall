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

class GameViewModel: NSObject, SCNPhysicsContactDelegate {
    weak var vc: GameViewController?
    var message: String = ""
    
    var score = 0 {
        didSet {
            vc?.scoreLabel.text = "Score: \(score)"
        }
    }
    
    var ballColor: Color! {
        didSet {
            vc?.ballButton.backgroundColor = ballColor.value
        }
    }
    
    var colors: [Color] = []
    
    var targetsCount = 100
    
    static let totalSeconds = 10
    
    var seconds = totalSeconds {
        didSet {
            vc?.timerLabel.text = "\(seconds)"
        }
    }
    
    var timer = Timer()
    
    func setBall() {
        if vc != nil && vc!.ballButton.isEnabled || colors.count == 0 {
            return
        }
        let color = getRandomColor()
        ballColor = color
        
        vc?.ballButton.isEnabled = true
    }
    
    func startGame() {
        guard let vc = vc else { return }
        stopTimer()
        score = 0
        colors = []
        seconds = GameViewModel.totalSeconds
        vc.sceneView.scene.rootNode.childNodes.filter{$0.name == "box"}.forEach{$0.removeFromParentNode()}
        addTargetNodes()
        setBall()
        runTimer()
    }
    
    func endGame(message: String) {
        stopTimer()
        let defaults = UserDefaults.standard
        let record = UserDefaults.standard.value(forKey: "record") as? Int
        if score > record ?? 0 {
            defaults.set(score, forKey: "record")
        }
        
        vc?.endGame(message: message)
    }
    
    func addTargetNodes() {
        for _ in 1...targetsCount {
            let color = Color.random()
            colors.append(color)
            let box = Box(color: color)
            
            vc?.sceneView.scene.rootNode.addChildNode(box)
        }
    }
    
    func throwBall() {
        let (direction, position) = getUserVector()
        let ball = Ball(color: ballColor, direction: direction, position: position)
        vc?.sceneView.scene.rootNode.addChildNode(ball)
        vc?.ballButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if ball.parent != nil {
                ball.removeFromParentNode()
                self.setBall()
            } else if self.vc?.sceneView.scene.rootNode.childNodes.filter({ $0.name == "box" }).count == 0 {
                self.endGame(message: "You won!")
            }
        }
    }
    
    func runTimer() {
        vc?.timerLabel.text = "\(seconds)"
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: (#selector(self.updateTimer)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @objc func updateTimer() {
        if seconds == 0 {
            stopTimer()
            endGame(message: "Time is over!")
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
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    if (contact.nodeA.parent != nil && contact.nodeB.parent != nil) {
                        self.endGame(message: "You lose!")
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
        }
        
        let explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
        explosion?.particleColor = nodeAColor
        contact.nodeB.addParticleSystem(explosion!)
    }
}
