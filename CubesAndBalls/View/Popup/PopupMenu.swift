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
    var viewModel: PopupMenuViewModel?
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = Appearance.red
        label.font = Appearance.fontBold40
        return label
    }()
    
    var scoreLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = Appearance.red
        label.font = Appearance.font40
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    var restartButton: UIButton = {
        let button = UIButton(type: .system)
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
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    var itemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    convenience init(viewModel: PopupMenuViewModel, delegate: PopupContentDelegate) {
        self.init(frame: .zero)
        self.delegate = delegate
        self.viewModel = viewModel
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(itemsStackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            itemsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            itemsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            itemsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25)
        ])
        
        let items = viewModel?.setTitlesForItems(title: titleLabel,
                                                scoreLabel: scoreLabel,
                                                restartButton: restartButton,
                                                quitButton: quitButton,
                                                resumeButton: resumeButton)
        
        items?.forEach { itemsStackView.addArrangedSubview($0) }
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
