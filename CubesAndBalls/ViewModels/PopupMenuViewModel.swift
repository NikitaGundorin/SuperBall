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
    var resumeButtonAdditionalTitle: String?
    
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
            if let resumeAdditionalText = resumeButtonAdditionalTitle {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                let line1 = NSMutableAttributedString(string: resumeAdditionalText,
                                                      attributes: [.font: Appearance.fontBold25 ?? UIFont.systemFont(ofSize: 25),
                                                                   .foregroundColor: Appearance.blue,
                                                                   .paragraphStyle: paragraphStyle])
                let line2 = NSAttributedString(string: resumeText,
                                               attributes: [.font: Appearance.fontBold50 ?? UIFont.systemFont(ofSize: 50),
                                                            .foregroundColor: Appearance.blue,
                                                            .paragraphStyle: paragraphStyle])
                line1.append(line2)
                resumeButton.setAttributedTitle(line1, for: .normal)
            } else {
                resumeButton.setTitle(resumeText, for: .normal)
            }
            items.append(resumeButton)
        }
        
        return items
    }
}
