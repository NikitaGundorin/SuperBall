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
    
    weak var delegate: PopupViewDelegate?
    
    var content: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        alpha = 0
        constraint.constant = 1000
        popup.layer.cornerRadius = 20
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (hide))
        self.background.addGestureRecognizer(gesture)
    }
    
    func show(withContent view: UIView) {
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
    
    @objc func hide() {
        constraint.constant = 1000
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.background.alpha = 0
            self.layoutIfNeeded()
        }, completion: { _ in
            self.delegate?.popupHid()
            self.alpha = 0
            self.content?.removeFromSuperview()
        })
    }
}

protocol PopupViewDelegate: class {
    func popupHid()
}
