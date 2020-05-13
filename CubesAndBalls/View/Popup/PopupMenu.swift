//
//  PopupMenu.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 28.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class PopupMenu: UIView, PopupContent {
    weak var delegate: PopupContentDelegate?
    var status: GameStatus!
    var hasExtra = false
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PAUSE"
        label.textColor = Appearance.red
        label.font = Appearance.fontBold40
        return label
    }()
    
    var restartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PLAY AGAIN", for: .normal)
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
        button.setTitleColor(Appearance.blue, for: .normal)
        button.titleLabel?.font = Appearance.fontBold50
        button.addTarget(self, action: #selector(resumeGame), for: .touchUpInside)
        return button
    }()
    
    var buttonsStackView: UIStackView  = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateStatus(withStatus status: GameStatus, hasExtra: Bool) {
        self.status = status
        self.hasExtra = hasExtra
        titleLabel.text = status.titles.title
        resumeButton.setTitle(status.titles.button, for: .normal)
        
        if status == .pause {
            addButtons(buttons: [restartButton, quitButton, resumeButton])
            restartButton.setTitle("RESTART", for: .normal)
            return
        }
        
        restartButton.setTitle("PLAY AGAIN", for: .normal)
        
        if status == .win {
            addButtons(buttons: [resumeButton])
            return
        }
        
        if hasExtra {
            addButtons(buttons: [restartButton, quitButton])
        } else {
            addButtons(buttons: [restartButton, quitButton, resumeButton])
        }
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(buttonsStackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            buttonsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25)
        ])
    }
    
    private func addButtons(buttons: [UIButton]) {
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons.forEach { buttonsStackView.addArrangedSubview($0) }
    }
    
    @objc func restartGame() {
        delegate?.restartGame()
    }
    
    @objc func quitGame() {
        delegate?.quitGame()
    }
    
    @objc func resumeGame() {
        delegate?.resumeGame()
    }
}
