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
        
        let nodeDirection = SCNVector3(direction.x*4, direction.y*4, direction.z*4)
        self.physicsBody?.applyForce(nodeDirection, at: SCNVector3(0.1,0,0), asImpulse: true)
        self.physicsBody?.applyForce(nodeDirection, asImpulse: true)
    }
        
    required init?(coder: NSCoder) {
        self.color = .red
        super.init(coder: coder)
    }
}
