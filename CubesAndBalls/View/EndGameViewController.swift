//
//  EndGameViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 23.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class EndGameViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var score = 0
    var statusText = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.text = "Score: \(score)"
        statusLabel.text = statusText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? GameViewController else { return }
        
        vc.viewModel.startGame()
    }
    
}
