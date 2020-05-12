//
//  PauseMenu.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 28.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class PauseMenu: UIView, PopupMenu {
    weak var delegate: PopupMenuDelegate?
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PAUSE"
        label.textColor = Appearance.red
        label.font = Appearance.fontBold50
        return label
    }()
    
    var restartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RESTART", for: .normal)
        button.setTitleColor(Appearance.red, for: .normal)
        button.titleLabel?.font = Appearance.font40
        button.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        return button
    }()
    
    var quitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("QUIT", for: .normal)
        button.setTitleColor(Appearance.red, for: .normal)
        button.titleLabel?.font = Appearance.font40
        button.addTarget(self, action: #selector(quitGame), for: .touchUpInside)
        return button
    }()
    
    var resumeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RESUME", for: .normal)
        button.setTitleColor(Appearance.blue, for: .normal)
        button.titleLabel?.font = Appearance.fontBold50
        button.addTarget(self, action: #selector(resumeGame), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(restartButton)
        addSubview(quitButton)
        addSubview(resumeButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        resumeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            restartButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            restartButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            quitButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            quitButton.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: 20),
            resumeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            resumeButton.topAnchor.constraint(equalTo: quitButton.bottomAnchor, constant: 40),
            resumeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25),
        ])
    }
    
    @objc func resumeGame() {
        delegate?.resumeGame()
    }
    
    @objc func restartGame() {
        delegate?.restartGame()
    }
    
    @objc func quitGame() {
        delegate?.quitGame()
    }
}
