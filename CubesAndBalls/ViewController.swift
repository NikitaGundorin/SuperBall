//
//  ViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 21.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var ballButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var ballColor: Color! {
        didSet {
            ballButton.backgroundColor = ballColor.value
        }
    }
    
    var colors: [Color] = []
    
    let physicsContactDelegate = PhysicsContactDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ballButton.layer.cornerRadius = ballButton.layer.frame.width / 2
        ballButton.isEnabled = false
        
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = physicsContactDelegate
        physicsContactDelegate.viewController = self
        
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        sceneView.pointOfView?.addChildNode(lightNode)
        addTargetNodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @IBAction func ballTouched(_ sender: Any) {
        throwBall(withColor: ballColor)
    }
    
    func setBallButton() {
        if ballButton.isEnabled || colors.count == 0 {
            return
        }
        var color: Color
        repeat {
            color = Color.random()
        } while !self.colors.contains(color)
        ballColor = color
        ballButton.isEnabled = true
    }
    
    func endGame(message: String) {
        print(message)
    }
    
    private func addTargetNodes() {
        for _ in 1...10 {
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
            
            sceneView.scene.rootNode.addChildNode(node)
        }
        setBallButton()
    }
    
    private func throwBall(withColor color: Color) {
        let ball = SCNSphere(radius: 0.5)
        ball.firstMaterial?.diffuse.contents = color.value
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
        
        sceneView.scene.rootNode.addChildNode(node)
        ballButton.isEnabled = false
        
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
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
}
