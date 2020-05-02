//
//  Box.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 25.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation
import ARKit

class Box: SCNNode {
    init(color: Color, positionRange: BoxPositionRange) {
        super.init()
        let size = CGFloat(0.5)
        let box = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = color.value
        self.geometry = box
        self.name = "box"
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.isAffectedByGravity = false
        
        self.position = SCNVector3(randomFloat(positionRange.x),
                                   randomFloat(positionRange.y),
                                   randomFloat(positionRange.z))
        
        let action: SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
        let forever = SCNAction.repeatForever(action)
        self.runAction(forever)
        
        self.physicsBody?.categoryBitMask = CollisionCategory.boxCategory.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.ballCategory.rawValue
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func randomFloat(_ range: (min: Float, max: Float)) -> Float {
        var result: Float = 0
        while((-1...1).contains(result)) { //cube is not too close to the camera
            result = Float.random(in: 0...1.0) * (range.max - range.min) + range.min
        }
        return result
    }
}

struct BoxPositionRange {
    let x: (min: Float, max: Float)
    let y: (min: Float, max: Float)
    let z: (min: Float, max: Float)
}
