//
//  StartViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 22.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit
import StoreKit

class StartViewController: UIViewController {
    private let superBallLabel: UILabel = {
        let label = UILabel()
        label.text = "SuperBall"
        label.font = Appearance.fontBold50
        label.textColor = Appearance.red
        
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play"), for: .normal)
        button.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor.black
        view.addSubview(superBallLabel)
        view.addSubview(playButton)
        view.addSubview(rateButton)
        
        superBallLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        rateButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            superBallLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            superBallLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 95),
            playButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -95),
            playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor),
            rateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rateButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35)
        ])
        
        Appearance.addDash(toLabel: superBallLabel)
    }
    
    @objc private func startGame() {
        let vc = GameViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func rateApp() {
        SKStoreReviewController.requestReview()
    }
}
