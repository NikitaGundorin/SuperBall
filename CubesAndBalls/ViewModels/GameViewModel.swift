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
    
    func setBallButton() {
        if vc != nil && vc!.ballButton.isEnabled || colors.count == 0 {
            return
        }
        var color: Color
        repeat {
            color = Color.random()
        } while !self.colors.contains(color)
        ballColor = color
        vc?.ballButton.isEnabled = true
    }
    
    func endGame(message: String) {
        let defaults = UserDefaults.standard
        let record = UserDefaults.standard.value(forKey: "record") as? Int
        if score > record ?? 0 {
            defaults.set(score, forKey: "record")
        }
        
        vc?.dismiss(animated: true, completion: nil)
    }
    
    func addTargetNodes() {
        for _ in 1...100 {
            let size = CGFloat(0.5)
            let color = Color.random()
            colors.append(color)
            let box = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = color.value
            let node = SCNNode(geometry: box)
            node.name = "box"
            
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody?.isAffectedByGravity = false
            
            node.position = SCNVector3(randomFloat(min: -10, max: 10), randomFloat(min: -4, max: 5), randomFloat(min: -10, max: -2))
            
            let action: SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
            let forever = SCNAction.repeatForever(action)
            node.runAction(forever)
            
            node.physicsBody?.categoryBitMask = CollisionCategory.boxCategory.rawValue
            node.physicsBody?.contactTestBitMask = CollisionCategory.ballCategory.rawValue
            
            vc?.sceneView.scene.rootNode.addChildNode(node)
        }
        setBallButton()
    }
    
    func throwBall() {
        let ball = SCNSphere(radius: 0.5)
        ball.firstMaterial?.diffuse.contents = ballColor.value
        let node = SCNNode(geometry: ball)
        node.name = "ball"
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        
        node.physicsBody?.categoryBitMask = CollisionCategory.ballCategory.rawValue
        node.physicsBody?.collisionBitMask = CollisionCategory.boxCategory.rawValue
        
        let (direction, position) = self.getUserVector()
        node.position = position
        let nodeDirection = SCNVector3(direction.x*4, direction.y*4, direction.z*4)
        node.physicsBody?.applyForce(nodeDirection, at: SCNVector3(0.1,0,0), asImpulse: true)
        node.physicsBody?.applyForce(nodeDirection, asImpulse: true)
        
        vc?.sceneView.scene.rootNode.addChildNode(node)
        vc?.ballButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            node.removeFromParentNode()
            self.setBallButton()
        }
    }
    
    private func randomFloat(min: Float, max: Float) -> Float {
        var result: Float = 0
        while((-1...1).contains(result)) { //cube is not too close to the camera
            result = Float.random(in: 0...1.0) * (max - min) + min
        }
        return result
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
                DispatchQueue.main.async {
                    self.endGame(message: "wrong color")
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
                self.setBallButton()
            }
        }
        
        let explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
        explosion?.particleColor = nodeAColor
        contact.nodeB.addParticleSystem(explosion!)
    }
}
