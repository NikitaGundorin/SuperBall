//
//  ActivityIndicator.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 27.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class ActivityIndicator: UIView {
    private let activityIndicator = UIActivityIndicatorView()
    private let background: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 20
        
        return view
    }()
    
    init() {
        super.init(frame: CGRect.zero)

        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func show() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2, delay: 0.2, animations: {
            self.alpha = 1
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        }
    }
    
    private func setupLayout() {
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        alpha = 0
        activityIndicator.color = Appearance.red
        
        for view in [background, activityIndicator] {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            background.heightAnchor.constraint(equalToConstant: 100),
            background.widthAnchor.constraint(equalTo: background.heightAnchor),
            background.centerXAnchor.constraint(equalTo: centerXAnchor),
            background.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: background.centerYAnchor)
        ])
    }
}
