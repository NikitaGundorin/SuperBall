//
//  StartViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 22.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import ARKit
import StoreKit

class StartViewController: UIViewController {
    private let superBallLabel: UILabel = {
        let label = UILabel()
        label.text = "SuperBall"
        label.font = Appearance.fontBold40
        label.textColor = Appearance.red
        
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play"), for: .normal)
        button.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        
        return button
    }()
    
    private let infinityModeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "infinityMode"), for: .normal)
        button.addTarget(self, action: #selector(startInfinityMode), for: .touchUpInside)
        
        return button
    }()
    
    private let rateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RATE APP", for: .normal)
        button.titleLabel?.font = Appearance.fontBold20
        button.setTitleColor(Appearance.red, for: .normal)
        button.addTarget(self, action: #selector(rateApp), for: .touchUpInside)
        
        return button
    }()
    
    private let removeAdsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("REMOVE ADS", for: .normal)
        button.titleLabel?.font = Appearance.fontBold20
        button.setTitleColor(Appearance.red, for: .normal)
        button.addTarget(self, action: #selector(removeAds), for: .touchUpInside)
        
        return button
    }()
    
    private let activityIndicator = ActivityIndicator()
    private let iapManager = IAPManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.bool(forKey: "walkthroughWasShown")
            || AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            let vc = WalkthroughViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: IAPManager.removeAdProductIdentifier) {
            removeAdsButton.removeFromSuperview()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor.black
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideActivityIndicator)))
        
        for subview in [superBallLabel, playButton, infinityModeButton, removeAdsButton, rateButton, activityIndicator] {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            superBallLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            superBallLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -50),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 70),
            playButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -70),
            playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor),
            infinityModeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infinityModeButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 30),
            infinityModeButton.heightAnchor.constraint(equalTo: playButton.heightAnchor, multiplier: 0.65),
            infinityModeButton.widthAnchor.constraint(equalTo: infinityModeButton.heightAnchor),
            removeAdsButton.topAnchor.constraint(greaterThanOrEqualTo: infinityModeButton.bottomAnchor, constant: 20),
            removeAdsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeAdsButton.bottomAnchor.constraint(equalTo: rateButton.topAnchor, constant: -6),
            rateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        Appearance.addDash(toLabel: superBallLabel)
    }
    
    @objc private func startGame() {
        let vc = GameViewController()
        vc.levelViewModel = LevelViewModel(level: try! LevelsDataProvider.shared.getCurrentLevel())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func startInfinityMode() {
        let vc = GameViewController()
        vc.levelViewModel = LevelViewModel(level: try! LevelsDataProvider.shared.getLevel(withNumber: 0))
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func rateApp() {
        SKStoreReviewController.requestReview()
    }
    
    @objc private func removeAds() {
        activityIndicator.show()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(presentRemoveAds),
                                               name: NSNotification.Name(IAPManager.productNotificationIdentifier),
                                               object: nil)
        iapManager.setupPurchases { success in
            if success {
                IAPManager.shared.getProducts()
            } else {
                self.activityIndicator.hide()
            }
        }
    }
    
    @objc private func hideActivityIndicator() {
        activityIndicator.hide()
    }
    
    @objc private func presentRemoveAds() {
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.main.async {
            let vc = RemoveAdsViewController()
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true) {
                self.activityIndicator.hide()
            }
        }
    }
}

extension StartViewController: RemoveAdsDelegate {
    func adRemoved() {
        removeAdsButton.removeFromSuperview()
    }
}
