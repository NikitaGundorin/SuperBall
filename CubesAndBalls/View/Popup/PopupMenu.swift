//
//  PopupMenu.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 12.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

protocol PopupMenu: UIView {
    var titleLabel: UILabel { get }
    var restartButton: UIButton { get }
    var delegate: PopupMenuDelegate? { get set }
    
    func updateStatus(withStatus status: GameStatus)
}

extension PopupMenu {
    func updateStatus(withStatus status: GameStatus) {}
}

protocol PopupMenuDelegate: class {
    func startGame()
    func resumeGame()
    func restartGame()
    func quitGame()
}
