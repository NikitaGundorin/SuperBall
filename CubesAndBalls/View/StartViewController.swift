//
//  StartViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 22.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let record = UserDefaults.standard.value(forKey: "record") as? Int {
            scoreLabel.text = "Your record: \(record)"
        }
    }
}
