//
//  StartViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 22.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var levelDescriptionLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentLevel = try? LevelsDataProvider.shared.getCurrentLevel() else { return }
        levelLabel.text = "Level \(currentLevel.number)"
        levelDescriptionLabel.text = currentLevel.goalDescription
    }
}
