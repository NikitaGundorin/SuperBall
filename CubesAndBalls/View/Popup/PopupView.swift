//
//  PopupView.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 28.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class PopupView: UIView {
    var background: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: effect)
        
        return view
    }()
    
    var popup: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.layer.cornerRadius = 20

        return view
    }()
    
    var constraint: NSLayoutConstraint!
    var content: UIView?
    var isShown = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 0
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupSubviews() {
        background.translatesAutoresizingMaskIntoConstraints = false
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(background)
        addSubview(popup)
        
        constraint = popup.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1000)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            popup.centerXAnchor.constraint(equalTo: centerXAnchor),
            popup.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            popup.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            popup.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            constraint
        ])
    }
    
    func show(withContent view: PopupContent) {
        if isShown { return }
        isShown = true
        
        popup.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: popup.topAnchor),
            view.trailingAnchor.constraint(equalTo: popup.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: popup.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: popup.leadingAnchor)
        ])
        Appearance.addDash(toLabel: view.titleLabel)
        content = view
        alpha = 1
        constraint.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.background.alpha = 1
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hide(withCompletion completion: (() -> ())? = nil) {
        if !isShown { return }
        self.isShown = false
        constraint.constant = 1000
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.background.alpha = 0
            self.layoutIfNeeded()
        }, completion: { _ in
            self.alpha = 0
            self.content?.removeFromSuperview()
            guard let completion = completion else { return }
            completion()
        })
    }
}
