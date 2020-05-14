//
//  PopupMenuViewModel.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 13.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

struct PopupMenuViewModel {
    var titleLabelText: String?
    var scoreLabelText: String?
    var quitButtonTitle: String?
    var restartButtonTitle: String?
    var resumeButtonTitle: String?
    
    func setTitlesForItems(title: UILabel,
                           scoreLabel: UILabel,
                           restartButton: UIButton,
                           quitButton: UIButton,
                           resumeButton: UIButton) -> [UIView] {
        var items: [UIView] = []

        if let titleText = titleLabelText {
            title.text = titleText
        }

        if let scoreText = scoreLabelText {
            scoreLabel.text = scoreText
            items.append(scoreLabel)
        }

        if let restartText = restartButtonTitle {
            restartButton.setTitle(restartText, for: .normal)
            items.append(restartButton)
        }

        if let quitText = quitButtonTitle {
            quitButton.setTitle(quitText, for: .normal)
            items.append(quitButton)
        }

        if let resumeText = resumeButtonTitle {
            resumeButton.setTitle(resumeText, for: .normal)
            items.append(resumeButton)
        }

        return items
    }
}
