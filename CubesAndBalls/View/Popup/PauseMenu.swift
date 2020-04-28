//
//  PauseMenu.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 28.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class PauseMenu: UIView {
    weak var delegate: PauseMenuDelegate?
    
    @IBAction func resumeGane(_ sender: Any) {
        delegate?.resumeGame()
    }
    
    @IBAction func restartGame(_ sender: Any) {
        delegate?.restartGame()
    }
    
    @IBAction func quitGame(_ sender: Any) {
        delegate?.quitGame()
    }
}

protocol PauseMenuDelegate: class {
    func resumeGame()
    func restartGame()
    func quitGame()
}
