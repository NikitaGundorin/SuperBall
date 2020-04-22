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

class PhysicsContactDelegate: NSObject, SCNPhysicsContactDelegate {
    weak var viewController: ViewController?
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard let nodeAphysicsBody = contact.nodeA.physicsBody,
            let nodeBphysicsBody = contact.nodeB.physicsBody,
            nodeAphysicsBody.categoryBitMask == CollisionCategory.targetCategory.rawValue
                || nodeBphysicsBody.categoryBitMask == CollisionCategory.targetCategory.rawValue,
            let nodeAColor = contact.nodeA.geometry?.firstMaterial?.diffuse.contents as? UIColor,
            let nodeBColor = contact.nodeB.geometry?.firstMaterial?.diffuse.contents as? UIColor,
            nodeAColor == nodeBColor
            else {
                DispatchQueue.main.async {
                    self.viewController?.endGame(message: "wrong color")
                }
                return
            }
        
        DispatchQueue.main.async {
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
            self.viewController?.score += 1
        }
        
        let explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
        explosion?.particleColor = nodeAColor
        contact.nodeB.addParticleSystem(explosion!)
    }
}
