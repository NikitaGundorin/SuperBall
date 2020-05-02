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
    
    func endGame(status: GameStatus) {
        if popup.isShown { return }
        endGameMenu.messageLabel.text = status.message
        endGameMenu.score = viewModel.score
        let playAgainText = status == .win ? "Next level" : "Play again"
        endGameMenu.playAgainButton.setTitle(playAgainText, for: .normal)
        popup.show(withContent: endGameMenu)
    }
    
    func showLevelGoalDescription() {
        let popup = UIView()
        
        let numberLabel = UILabel()
        numberLabel.text = "Level \(viewModel.currentLevel.number)"
        numberLabel.textColor = UIColor.systemRed
        numberLabel.font = UIFont(name: "MarkerFelt-Thin", size: 35)
        numberLabel.textAlignment = .center
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = viewModel.currentLevel.goalDescription
        descriptionLabel.textColor = UIColor.systemRed
        descriptionLabel.font = UIFont(name: "MarkerFelt-Thin", size: 25)
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.numberOfLines = 4
        descriptionLabel.textAlignment = .center
        
        let okButton = UIButton()
        okButton.setTitle("Go", for: .normal)
        okButton.setTitleColor(UIColor.systemRed, for: .normal)
        okButton.titleLabel?.font = UIFont(name: "MarkerFelt-Thin", size: 35)
        okButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        
        popup.addSubview(numberLabel)
        popup.addSubview(descriptionLabel)
        popup.addSubview(okButton)
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.topAnchor.constraint(equalTo: popup.topAnchor, constant: 20).isActive = true
        numberLabel.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 10).isActive = true
        numberLabel.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -10).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(greaterThanOrEqualTo: numberLabel.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 10).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -10).isActive = true
        descriptionLabel.centerYAnchor.constraint(equalTo: popup.centerYAnchor).isActive = true

        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.centerXAnchor.constraint(equalTo: popup.centerXAnchor).isActive = true
        okButton.topAnchor.constraint(greaterThanOrEqualTo: descriptionLabel.bottomAnchor, constant: 20).isActive = true
        okButton.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -20).isActive = true
        
        if self.popup.isShown {
            self.popup.hide(withCompletion: { self.popup.show(withContent: popup) })
        } else {
            self.popup.show(withContent: popup)
        }
    }
    
    @objc private func startGame() {
        viewModel.startGame()
        popup.hide()
    }
}

extension GameViewController: PauseMenuDelegate, EndGameMenuDelegate {
    func resumeGame() {
        popup.hide()
        viewModel.runTimer()
    }
    
    func restartGame() {
        if viewModel.status == .win {
            showLevelGoalDescription()
            return
        }
        viewModel.startGame()
        popup.hide()
    }
    
    func quitGame() {
        dismiss(animated: true, completion: nil)
    }
}
