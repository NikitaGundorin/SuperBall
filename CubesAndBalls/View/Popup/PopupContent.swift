//
//  PopupMenu.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 12.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

protocol PopupContent: UIView {
    var titleLabel: UILabel { get }
    
    func updateStatus(withStatus status: GameStatus, hasExtra: Bool)
}

extension PopupContent {
    func updateStatus(withStatus status: GameStatus, hasExtra: Bool) {}
}

protocol PopupContentDelegate: class {
    func startGame()
    func resumeGame()
    func restartGame()
    func quitGame()
}
