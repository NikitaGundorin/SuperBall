//
//  InfinityGameEngine.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 13.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation

class InfinityGameEngine: GameEngine {
    override var scoreLabelText: String? {
        guard status != .pause else { return nil }
        return "SCORE: \(cubesCount)"
    }
    
    override init() {
        super.init()

        currentLevel = try! LevelsDataProvider.shared.getLevel(withNumber: 0)
    }
    
    override func prepareNewGame() {
        addTargetNodes(count: 100)
        if let record = UserDefaults.standard.value(forKey: "record") as? Int {
            vc?.roundLabel.text = "\(record)"
        } else {
            vc?.roundLabel.text = "0"
        }
    }
    
    override func prepareEndGame() {
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
        status = .pause
        setRecord()
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
}
