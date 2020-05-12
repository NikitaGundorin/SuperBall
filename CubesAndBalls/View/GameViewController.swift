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
    var sceneView: ARSCNView = ARSCNView(frame: UIScreen.main.bounds)
    var ballButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BALL", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .disabled)
        button.titleLabel?.font = Appearance.fontBold25
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.addTarget(self, action: #selector(ballTouched), for: .touchUpInside)
        return button
    }()
    
    let cubesCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.red
        label.font = Appearance.font30
        label.textAlignment = .center
        return label
    }()
    
    let roundLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.red
        label.font = Appearance.font30
        label.textAlignment = .center
        return label
    }()
    
    let pauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "pauseButton"), for: .normal)
        button.addTarget(self, action: #selector(pauseGame), for: .touchUpInside)
        return button
    }()
    
    private var regularConstraints: [NSLayoutConstraint] = []
    private var compactConstraints: [NSLayoutConstraint] = []
    
    private var popup: PopupView!
    private var pauseMenu: PopupMenu!
    private var endGameMenu: PopupMenu!
    
    private let viewModel = GameViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.vc = self
        setupScene()
        setupBallButton()
        setupStatusView()
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layoutTrait(traitCollection: traitCollection)
    }
    
    private func layoutTrait(traitCollection: UITraitCollection) {
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    private func setupBallButton() {
        view.addSubview(ballButton)
        ballButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ballButton.widthAnchor.constraint(equalTo: ballButton.heightAnchor)
        ])
        compactConstraints.append(contentsOf: [
            ballButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            ballButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        regularConstraints.append(contentsOf: [
            ballButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ballButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        layoutTrait(traitCollection: UIScreen.main.traitCollection)
        view.layoutIfNeeded()
        ballButton.layer.cornerRadius = ballButton.frame.width / 2
    }
    
    private func setupScene() {
        view.addSubview(sceneView)
        
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = viewModel
        
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        sceneView.pointOfView?.addChildNode(lightNode)
        
        let aim = UIImageView(image: UIImage(named: "aim"))
        view.addSubview(aim)
        aim.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aim.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            aim.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aim.heightAnchor.constraint(equalTo: aim.widthAnchor),
            aim.heightAnchor.constraint(lessThanOrEqualToConstant: CGFloat(200)),
            aim.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 120),
            aim.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -120)
        ])
    }
    
    private func setupPopup() {
        popup = PopupView(frame: view.bounds)
        view.addSubview(popup)
        
        pauseMenu = PauseMenu(frame: CGRect.zero)
        pauseMenu.delegate = self
        
        endGameMenu = EndGameMenu(frame: CGRect.zero)
        endGameMenu.delegate = self
    }
    
    func endGame(status: GameStatus) {
        if popup.isShown { return }
        if (status != .win) {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        endGameMenu.updateStatus(withStatus: status)
        popup.show(withContent: endGameMenu)
    }
    
    @objc private func ballTouched(_ sender: Any) {
        viewModel.throwBall()
    }
    
    @objc private func pauseGame() {
        viewModel.stopTimer()
        popup.show(withContent: pauseMenu)
    }
    
    private func showLevelGoalDescription() {
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
            self.popup.hide(withCompletion: { self.popup.show(withContent: popup as! PopupMenu) })
        } else {
            self.popup.show(withContent: popup as! PopupMenu)
        }
    }
    
    @objc private func startGame() {
        viewModel.startGame()
        popup.hide()
    }
    
    private func setupStatusView() {
        let statusView = UIView()
        statusView.backgroundColor = UIColor.black
        
        let roundView = UIImageView(image: UIImage(named: "ball50"))
        roundView.addSubview(roundLabel)
        roundLabel.frame = roundView.bounds
        let cubeView = UIImageView(image: UIImage(named: "cube50"))
        cubeView.addSubview(cubesCountLabel)
        cubesCountLabel.frame = cubeView.bounds
        
        let stackView = UIStackView(arrangedSubviews: [pauseButton, roundView, cubeView])
        stackView.distribution = .equalSpacing
        statusView.addSubview(stackView)
        view.addSubview(statusView)
        
        let topSafeAreaBG = UIView()
        topSafeAreaBG.backgroundColor = UIColor.black
        view.addSubview(topSafeAreaBG)
        
        statusView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        topSafeAreaBG.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topSafeAreaBG.topAnchor.constraint(equalTo: view.topAnchor),
            topSafeAreaBG.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSafeAreaBG.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSafeAreaBG.bottomAnchor.constraint(equalTo: statusView.topAnchor),
            statusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statusView.heightAnchor.constraint(equalToConstant: CGFloat(70)),
            statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: statusView.topAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: statusView.bottomAnchor, constant: -10)
        ])
    }
}

extension GameViewController: PopupMenuDelegate {
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
