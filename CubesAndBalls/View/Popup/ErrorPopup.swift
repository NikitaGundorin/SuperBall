//
//  ErrorPopup.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 27.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class ErrorPopup: UIView, PopupContent {
    weak var delegate: ErrorPopupDelegate?
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Appearance.red
        label.font = Appearance.fontBold30
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Appearance.red
        label.font = Appearance.font20
        
        return label
    }()
    
    private let okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        button.setTitleColor(Appearance.red, for: .normal)
        button.titleLabel?.font = Appearance.fontBold25
        button.addTarget(self, action: #selector(okButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    convenience init(title: String, message: String) {
        self.init()
        
        titleLabel.text = title
        messageLabel.text = message
        setupLayout()
    }
    
    private func setupLayout() {
        for view in [titleLabel, messageLabel, okButton] {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 10),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 10),
            okButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            okButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            okButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
            okButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 10),
            okButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func okButtonPressed() {
        delegate?.confirm()
    }
}

protocol ErrorPopupDelegate: class {
    func confirm()
}
