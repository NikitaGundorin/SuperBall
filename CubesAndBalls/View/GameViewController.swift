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
    @IBOutlet weak var timerLabel: UILabel!
    private var popup: PopupView!
    private var pauseMenu: PauseMenu!
    private var endGameMenu: EndGameMenu!
    
    private let viewModel = GameViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        viewModel.vc = self
        setupBallButton()
        setupScene()
        setupPopup()
        
        viewModel.startGame()
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
    
    @IBAction func pauseGame(_ sender: Any) {
        viewModel.stopTimer()
        popup.show(withContent: pauseMenu)
    }
    
    private func setupBallButton() {
        ballButton.layer.cornerRadius = ballButton.frame.width / 2
        ballButton.isEnabled = false
    }
    
    private func setupScene() {
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = viewModel
        
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        sceneView.pointOfView?.addChildNode(lightNode)
    }
    
    private func setupPopup() {
        popup = Bundle.main.loadNibNamed("PopupView", owner: self, options: nil)?.first as? PopupView
        popup.frame = view.frame
        view.addSubview(popup)
        
        pauseMenu = Bundle.main.loadNibNamed("PauseMenu", owner: self, options: nil)?.first as? PauseMenu
        pauseMenu.delegate = self
        
        endGameMenu = Bundle.main.loadNibNamed("EndGameMenu", owner: self, options: nil)?.first as? EndGameMenu
        endGameMenu.delegete = self
    }
    
    func endGame(message: String) {
        endGameMenu.messageLabel.text = message
        endGameMenu.score = viewModel.score
        popup.show(withContent: endGameMenu)
    }
}

extension GameViewController: PauseMenuDelegate, EndGameMenuDelegate {
    func resumeGame() {
        popup.hide()
        viewModel.runTimer()
    }
    
    func restartGame() {
        viewModel.startGame()
        popup.hide()
    }
    
    func quitGame() {
        dismiss(animated: true, completion: nil)
    }
}
