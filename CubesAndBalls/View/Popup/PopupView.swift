//
//  PopupView.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 28.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class PopupView: UIView {
    @IBOutlet weak var background: UIVisualEffectView!
    @IBOutlet weak var popup: UIView!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    var content: UIView?
    var isShown = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        alpha = 0
        constraint.constant = 1000
        popup.layer.cornerRadius = 20
    }
    
    func show(withContent view: UIView) {
        if isShown { return }
        self.isShown = true
        self.popup.addSubview(view)
        view.frame = popup.bounds
        self.content = view
        
        alpha = 1
        constraint.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.background.alpha = 1
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hide() {
        if !isShown { return }
        self.isShown = false
        constraint.constant = 1000
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.background.alpha = 0
            self.layoutIfNeeded()
        }, completion: { _ in
            self.alpha = 0
            self.content?.removeFromSuperview()
        })
    }
}
