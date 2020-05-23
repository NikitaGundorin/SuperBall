//
//  GameEngine.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 12.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import SceneKit
import ARKit

class GameEngine: NSObject {
    weak var vc: GameViewController?
    lazy var currentLevel: Level = {
        do {
            return try LevelsDataProvider.shared.getCurrentLevel()
        } catch {
            print(error.localizedDescription)
            return Level()
        }
    }()
    
    var cubesCount = 0 {
        didSet {
            vc?.cubesCountLabel.text = "\(cubesCount)"
        }
    }
    var status: GameStatus?
    var hasExtra = false
    var colors: [Color] = []
    
    var isBallThrown = false {
        didSet {
            setBallButton(isEnabled: !isBallThrown)
        }
    }
    
    var ballColor: Color! {
        didSet {
            vc?.ballButton.backgroundColor = ballColor.value
        }
    }
    
    var popupMenuViewModel: PopupMenuViewModel {
        PopupMenuViewModel(titleLabelText: titleLabelText,
                           scoreLabelText: scoreLabelText,
                           quitButtonTitle: quitButtonTitle,
                           restartButtonTitle: restartButtonTitle,
                           resumeButtonTitle: resumeButtonTitle)
    }
    
    private var titleLabelText: String? {
        status?.titles.title
    }
    private var quitButtonTitle: String? {
        if status == .win {
            return nil
        }
        return "QUIT"
    }
    var scoreLabelText: String? { return nil }
    private var restartButtonTitle: String? {
        if status == .win {
            return nil
        }
        if status == .pause {
            return "RESTART"
        }
        return "PLAY AGAIN"
    }
    private var resumeButtonTitle: String? {
        if status == .pause {
            return "RESUME"
        }
        
        if status == .win {
            return status?.titles.button
        }
        
        if hasExtra == true {
            return nil
        }
        
        return status?.titles.button
    }
    
    func throwBall() {
        let (direction, position) = getUserVector()
        let ball = Ball(color: ballColor, direction: direction, position: position)
        vc?.sceneView.scene.rootNode.addChildNode(ball)
        isBallThrown = true
        countBall()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.checkBallAfterThrow(ball: ball)
        }
    }
    
    func checkBallAfterThrow(ball: Ball) {
        if ball.parent != nil {
            ball.removeFromParentNode()
            setBall()
        }
    }
    
    func startGame() {
        guard let vc = vc else { return }
        cubesCount = Int(currentLevel.cubesCount)
        colors = []
        vc.sceneView.scene.rootNode.childNodes.filter{$0.name == "box"}.forEach{$0.removeFromParentNode()}
        newGameWillStart()
        addTargetNodes()
        ballColor = getRandomColor()
        status = nil
        hasExtra = false
        newGameDidStart()
    }
    
    func endGame(status: GameStatus) {
        self.status = status
        gameWillEnd()
        if status == .win {
            LevelsDataProvider.shared.levelUp()
            do {
                self.currentLevel = try LevelsDataProvider.shared.getCurrentLevel()
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        vc?.endGame(status: self.status ?? status)
    }
    
    func setBall() {
        if colors.count == 0 {
            endGame(status: .win)
            isBallThrown = false
            return
        }
        checkBallAvailable()
        ballColor = getRandomColor()
        
        isBallThrown = false
    }
    
    func addTargetNodes(count: Int16? = nil) {
        let cubesCount = count ?? currentLevel.cubesCount
        guard cubesCount > 0 else {
            return
        }
        
        for _ in 1...cubesCount {
            let color = Color.random()
            colors.append(color)
            
            let range = getPositionRange(numberOfBoxes: cubesCount)
            let box = Box(color: color, positionRange: range)
            
            vc?.sceneView.scene.rootNode.addChildNode(box)
        }
    }
    
    func getRandomColor() -> Color {
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
    
    func getPositionRange(numberOfBoxes: Int16) -> BoxPositionRange {
        var max = 0.04 * Float(numberOfBoxes) + 0.8
        switch max {
        case ...1:
            max = 1
        case 5...:
            max = 5
        default:
            break
        }
        
        return BoxPositionRange(x: (-max, max), y: (-max, max), z: (-5, -1))
    }
    
    func setBallButton(isEnabled: Bool) {
        vc?.ballButton.isEnabled = isEnabled
    }
    
    func countScore() {
        cubesCount -= 1
    }
    
    func addExtraLife() {
        hasExtra = true
        resumeGame()
    }
    
    func pauseGame() {
        status = .pause
    }
    
    func addExtra() {}
    func resumeGame() {}
    func newGameWillStart() {}
    func newGameDidStart() {}
    func gameWillEnd() {}
    func countBall() {}
    func checkBallAvailable() {}
}

extension GameEngine: SCNPhysicsContactDelegate {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    if (contact.nodeA.parent != nil && contact.nodeB.parent != nil) {
                        self.endGame(status: .wrongColor)
                        let ball = nodeAPhysicsBody.categoryBitMask == CollisionCategory.ballCategory.rawValue ? contact.nodeA : contact.nodeB
                        ball.removeFromParentNode()
                        self.setBall()
                    }
                }
                return
        }
        
        DispatchQueue.main.async {
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
            self.countScore()
            if let color = Color.value(ofUIColor: nodeAColor),
                let index = self.colors.lastIndex(of: color) {
                self.colors.remove(at: index)
                self.setBall()
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        if let explosion = SCNParticleSystem(named: "Explode", inDirectory: nil) {
            let box = nodeAPhysicsBody.categoryBitMask == CollisionCategory.boxCategory.rawValue ? contact.nodeA : contact.nodeB
            explosion.particleColor = nodeAColor
            box.addParticleSystem(explosion)
        }
    }
}
