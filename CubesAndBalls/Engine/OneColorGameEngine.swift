//
//  OneColorGameEngine.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 21.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation

class OneColorGameEngine: TimeGameEngine {
    override func setBallButton(isEnabled: Bool) {
        vc?.ballButton.isEnabled = true
    }
    
    override func addTargetNodes(count: Int16? = nil) {
        let cubesCount = count ?? currentLevel.cubesCount
        guard cubesCount > 0 else {
            return
        }
        
        let color = Color.random()
        colors = Array(repeating: color, count: Int(cubesCount))
        for _ in 1...cubesCount {
            let range = getPositionRange(numberOfBoxes: cubesCount)
            let box = Box(color: color, positionRange: range)
            
            vc?.sceneView.scene.rootNode.addChildNode(box)
        }
    }
    
    override func checkBallAfterThrow(ball: Ball) {
        if ball.parent != nil {
            ball.removeFromParentNode()
        }
    }
}
