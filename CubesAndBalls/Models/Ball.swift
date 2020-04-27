//
//  Ball.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 25.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation
import ARKit

class Ball: SCNNode {
    var color: Color
    
    init(color: Color, direction: SCNVector3, position: SCNVector3) {
        self.color = color
        super.init()
        let geometry = SCNSphere(radius: 0.2)
        geometry.firstMaterial?.diffuse.contents = color.value
        self.geometry = geometry
        self.name = "ball"
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionCategory.ballCategory.rawValue
        self.physicsBody?.collisionBitMask = CollisionCategory.boxCategory.rawValue
        
        self.position = position
        
        let nodeDirection = SCNVector3(direction.x * 15, direction.y * 15, direction.z * 15)
        self.physicsBody?.applyForce(nodeDirection, asImpulse: true)
    }
        
    required init?(coder: NSCoder) {
        self.color = .red
        super.init(coder: coder)
    }
}
