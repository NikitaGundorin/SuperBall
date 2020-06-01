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
            resumeButton.setTitle(resumeText, for: .normal)
            items.append(resumeButton)
        }
        
        return items
    }
    
    func setup(resumeButton: UIButton) {
        if let resumeText = resumeButtonTitle,
            let resumeAdditionalText = resumeButtonAdditionalTitle {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let line1Font = calc(font: Appearance.fontBold25!, for: resumeAdditionalText, button: resumeButton)
            
            let line2Font = calc(font: Appearance.fontBold50!, for: resumeText, button: resumeButton)

            let line1 = NSMutableAttributedString(string: resumeAdditionalText,
                                                  attributes: [.font: line1Font,
                                                               .foregroundColor: Appearance.blue,
                                                               .paragraphStyle: paragraphStyle])
            let line2 = NSAttributedString(string: resumeText,
                                           attributes: [.font: line2Font,
                                                        .foregroundColor: Appearance.blue,
                                                        .paragraphStyle: paragraphStyle])
            line1.append(line2)
            resumeButton.setAttributedTitle(line1, for: .normal)
        } else {
            resumeButton.titleLabel?.adjustFontSizeToWidth(minimumFontSize: 20)
        }
    }
    
    private func calc(font: UIFont, for text: String, button: UIButton) -> UIFont {
        let width = button.bounds.width
        var line1width = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width
        var font = font
        
        while line1width > width {
            font = font.withSize(font.pointSize - 1)
            line1width = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width
        }
        
        return font
    }
}
