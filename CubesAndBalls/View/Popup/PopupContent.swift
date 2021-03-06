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
}

protocol PopupContentDelegate: class {
    func startGame()
    func resumeGame()
    func restartGame()
    func quitGame()
}
