//
//  GameViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 21.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var ballButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    let viewModel = GameViewModel()
    var statusText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ballButton.layer.cornerRadius = ballButton.layer.frame.width / 2
        ballButton.isEnabled = false
        
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = viewModel
        viewModel.vc = self
        
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        sceneView.pointOfView?.addChildNode(lightNode)
        
        setUpNewGame()
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
        viewModel.throwBall()
    }
    
    func setUpNewGame() {
        viewModel.addTargetNodes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? EndGameViewController else { return }
        
        vc.score = viewModel.score
        vc.statusText = self.statusText
    }
}
