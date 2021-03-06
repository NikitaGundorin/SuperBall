//
//  GameViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 21.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import SceneKit
import ARKit
import GoogleMobileAds
import Keys

class GameViewController: UIViewController {
    var engine: GameEngine!
    var levelViewModel: LevelViewModel! {
        didSet {
            engine = levelViewModel.engine
            engine.vc = self
            sceneView.scene.physicsWorld.contactDelegate = engine
        }
    }
    var sceneView: ARSCNView = ARSCNView(frame: UIScreen.main.bounds)
    var ballButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("BALL", comment: "Ball button title"), for: .normal)
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
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    let roundLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.red
        label.font = Appearance.font30
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    let pauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "pauseButton"), for: .normal)
        button.addTarget(self, action: #selector(pauseGame), for: .touchUpInside)
        return button
    }()
    
    let aimView = UIView()
    
    lazy var aimLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = Appearance.red.cgColor
        layer.lineWidth = 8
        
        let width = aimView.bounds.width
        let height = aimView.bounds.height
        let lenght = height / 4
        
        let path = CGMutablePath()
        path.addEllipse(in: aimView.bounds)
        path.addLines(between: [CGPoint(x: width / 2, y: 0), CGPoint(x: width / 2, y: -lenght)])
        path.addLines(between: [CGPoint(x: width / 2, y: height), CGPoint(x: width / 2, y: height + lenght)])
        path.addLines(between: [CGPoint(x: 0, y: height / 2), CGPoint(x: -lenght, y: height / 2)])
        path.addLines(between: [CGPoint(x: width, y: height / 2), CGPoint(x: width + lenght, y: height / 2)])
        
        layer.path = path
        
        return layer
    }()
    
    private var regularConstraints: [NSLayoutConstraint] = []
    private var compactConstraints: [NSLayoutConstraint] = []
    
    private var popup: PopupView!
    
    private lazy var startLevelMenu: PopupContent = {
        let startLevelMenu = StartLevelMenu(frame: CGRect.zero)
        startLevelMenu.delegate = self
        startLevelMenu.levelViewModel = levelViewModel
        return startLevelMenu
    }()
    
    private var rewardedAd: GADRewardedAd?
    private var reward: GADAdReward?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupBallButton()
        setupStatusView()
        setupPopup()
        showStartLevelPopup()
        setupAd()
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
        sceneView.session.delegate = self
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        sceneView.scene.physicsWorld.contactDelegate = engine
        
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        sceneView.pointOfView?.addChildNode(lightNode)
        
        view.addSubview(aimView)
        aimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aimView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            aimView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aimView.heightAnchor.constraint(equalTo: aimView.widthAnchor),
            aimView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            aimView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            aimView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 120),
            aimView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -120)
        ])
        
        view.layoutIfNeeded()
        aimView.layer.addSublayer(aimLayer)
        
        let notificationCenter = NotificationCenter.default
           notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func setupPopup() {
        popup = PopupView(frame: CGRect.zero)
        view.addSubview(popup)
        popup.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: view.topAnchor),
            popup.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            popup.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupAd() {
        if UserDefaults.standard.bool(forKey: IAPManager.productNotificationIdentifier) {
            return
        }
        var adUnitID: String
        #if DEBUG
        adUnitID = CubesAndBallsKeys().gADRewardedAdUnitIDTest
        #else
        adUnitID = CubesAndBallsKeys().gADRewardedAdUnitID
        #endif
        
        rewardedAd = GADRewardedAd(adUnitID: adUnitID)
        
        rewardedAd?.load(GADRequest())
        reward = nil
    }
    
    func endGame(status: GameStatus) {
        if popup.isShown { return }
        if (status != .win) {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        showPopupMenu()
    }
    
    @objc private func ballTouched(_ sender: Any) {
        engine.throwBall()
    }
    
    @objc private func pauseGame() {
        engine.pauseGame()
        showPopupMenu()
    }
    
    @objc private func appMovedToBackground() {
        if !popup.isShown {
            pauseGame()
        }
    }
    
    private func showStartLevelPopup() {
        let startLevelMenu = self.startLevelMenu as! StartLevelMenu
        startLevelMenu.levelViewModel = levelViewModel
        
        if popup.isShown {
            popup.hide(withCompletion: { self.popup.show(withContent: startLevelMenu) })
        } else {
            popup.show(withContent: startLevelMenu)
        }
    }
    
    func startGame() {
        engine.startGame()
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
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        cubesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            roundLabel.topAnchor.constraint(equalTo: roundView.topAnchor),
            roundLabel.trailingAnchor.constraint(equalTo: roundView.trailingAnchor, constant: -5),
            roundLabel.bottomAnchor.constraint(equalTo: roundView.bottomAnchor),
            roundLabel.leadingAnchor.constraint(equalTo: roundView.leadingAnchor, constant: 5),
            roundLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 40),
            cubesCountLabel.topAnchor.constraint(equalTo: cubeView.topAnchor),
            cubesCountLabel.trailingAnchor.constraint(equalTo: cubeView.trailingAnchor, constant: -5),
            cubesCountLabel.bottomAnchor.constraint(equalTo: cubeView.bottomAnchor),
            cubesCountLabel.leadingAnchor.constraint(equalTo: cubeView.leadingAnchor, constant: 5),
            cubesCountLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 40),
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
    
    private func showPopupMenu() {
        let popupMenu = PopupMenu(viewModel: engine.popupMenuViewModel, delegate: self)
        popup.show(withContent: popupMenu)
    }
    
    private func addExtra() {
        switch engine.status {
        case .ballsOver, .timeUp:
            engine.addExtra()
            showPopupMenu()
        case .wrongColor, .newRecord:
            engine.addExtraLife()
            showPopupMenu()
        default:
            return
        }
    }
}

extension GameViewController: PopupContentDelegate {
    func resumeGame() {
        switch engine.status {
        case .ballsOver, .timeUp, .wrongColor, .newRecord:
            if UserDefaults.standard.bool(forKey: IAPManager.removeAdProductIdentifier) {
                addExtra()
                return
            }
            if rewardedAd?.isReady == true {
                rewardedAd?.present(fromRootViewController: self, delegate: self)
            }
        case .win:
            levelViewModel = LevelViewModel(level: try! LevelsDataProvider.shared.getCurrentLevel())
            showStartLevelPopup()
        default:
            popup.hide()
            engine.resumeGame()
        }
    }
    
    func restartGame() {
        engine.startGame()
        popup.hide()
    }
    
    func quitGame() {
        dismiss(animated: true, completion: nil)
    }
}

extension GameViewController: GADRewardedAdDelegate {
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        self.reward = reward
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        if reward != nil {
            addExtra()
        }
        setupAd()
    }
}

extension GameViewController: ARSessionDelegate {
    func sessionWasInterrupted(_ session: ARSession) {
        if !popup.isShown {
            pauseGame()
        }
    }
}
