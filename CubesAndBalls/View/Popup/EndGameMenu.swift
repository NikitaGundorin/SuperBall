//
//  EndGameMenu.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 28.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class EndGameMenu: UIView {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    weak var delegete: EndGameMenuDelegate?
    var score: Int = 0 {
        didSet {
            self.scoreLabel.text = "Score: \(score)"
        }
    }
    
    @IBAction func playAgain(_ sender: Any) {
        delegete?.restartGame()
    }
    
    @IBAction func quitGame(_ sender: Any) {
        delegete?.quitGame()
    }
}

protocol EndGameMenuDelegate: class {
    func restartGame()
    func quitGame()
}
