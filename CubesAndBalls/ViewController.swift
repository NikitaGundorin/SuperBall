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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        sceneView.pointOfView?.addChildNode(lightNode)
        
        addTargetNodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func addTargetNodes(){
        for _ in 1...100 {
//            var node = SCNNode()
//
//            if (index > 9) && (index % 10 == 0) {
//                let scene = SCNScene(named: "art.scnassets/mouthshark.dae")
//                node = (scene?.rootNode.childNode(withName: "shark", recursively: true)!)!
//                node.scale = SCNVector3(0.3,0.3,0.3)
//                node.name = "shark"
//            }else{
//                let scene = SCNScene(named: "art.scnassets/bath.dae")
//                node = (scene?.rootNode.childNode(withName: "Cube_001", recursively: true)!)!
//                node.scale = SCNVector3(0.02,0.02,0.02)
//                node.name = "bath"
//            }
            let color = Colors(rawValue: Int.random(in: 0...5))?.value
            let box = SCNGeometry.Box(width: 0.5, height: 0.5, length: 0.5)
            box.firstMaterial?.diffuse.contents = color
            let node = SCNNode(geometry: box)
            node.name = "box"
            
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody?.isAffectedByGravity = false
            
            //place randomly, within thresholds
            node.position = SCNVector3(randomFloat(min: -10, max: 10), randomFloat(min: -4, max: 5), randomFloat(min: -10, max: 10))
            
            //rotate
            let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
            let forever = SCNAction.repeatForever(action)
            node.runAction(forever)
            
            //for the collision detection
//            node.physicsBody?.categoryBitMask = CollisionCategory.targetCategory.rawValue
//            node.physicsBody?.contactTestBitMask = CollisionCategory.missileCategory.rawValue
            
            //add to scene
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return Float.random(in: 0...1.0) * (max - min) + min
    }
}
