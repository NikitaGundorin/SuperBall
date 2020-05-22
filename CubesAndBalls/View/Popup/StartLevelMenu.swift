//
//  StartLevelMenu.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 12.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class StartLevelMenu: UIView, PopupContent {
    var levelViewModel: LevelViewModel! {
        didSet {
            setupLabels()
        }
    }
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.red
        label.font = Appearance.fontBold50
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var restartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PLAY", for: .normal)
        button.setTitleColor(Appearance.blue, for: .normal)
        button.titleLabel?.font = Appearance.fontBold50
        button.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        return button
    }()
    
    let timeIcon = UIImageView(image: UIImage(named: "timeIcon"))
    let timeLabel = UILabel()
    let cubeIcon = UIImageView(image: UIImage(named: "cubeIcon"))
    let cubesLabel = UILabel()
    let ballIcon = UIImageView(image: UIImage(named: "ballIcon"))
    let ballsLabel = UILabel()
    
    weak var delegate: PopupContentDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func startGame() {
        delegate?.startGame()
    }
    
    private func setupSubviews() {
        let timeStackView = UIStackView(arrangedSubviews: [timeIcon, timeLabel])
        timeStackView.spacing = 50
        let cubeStackView = UIStackView(arrangedSubviews: [cubeIcon, cubesLabel])
        cubeStackView.spacing = 50
        let ballStackView = UIStackView(arrangedSubviews: [ballIcon, ballsLabel])
        ballStackView.spacing = 50
        let mainStackView = UIStackView(arrangedSubviews: [timeStackView, cubeStackView, ballStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        
        for view in [titleLabel, mainStackView, restartButton] {
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        for icon in [timeIcon, ballIcon, cubeIcon] {
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            mainStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 35),
            restartButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            restartButton.topAnchor.constraint(equalTo: ballStackView.bottomAnchor, constant: 30),
            restartButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25)
        ])
    }
    
    private func setupLabels() {
        titleLabel.text = levelViewModel.name
        
        for label in [timeLabel, cubesLabel, ballsLabel] {
            label.textColor = Appearance.red
            label.font = Appearance.font50
            label.textAlignment = .center
        }
        
        if levelViewModel.timeLimit == 0 {
            setInfinity(forLabel: timeLabel)
        } else {
            timeLabel.text = "\(levelViewModel.timeLimit)"
        }
        
        if levelViewModel.cubesCount == 0 {
            setInfinity(forLabel: cubesLabel)
        } else {
            cubesLabel.text = "\(levelViewModel.cubesCount)"
        }
        
        if levelViewModel.ballsCount == 0 {
            setInfinity(forLabel: ballsLabel)
        } else {
            ballsLabel.text = "\(levelViewModel.ballsCount)"
        }
    }
    
    private func setInfinity(forLabel label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 60).isActive = true
        label.text = "∞"
        label.font = Appearance.font100
    }
}
