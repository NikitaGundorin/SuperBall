//
//  UILabel+adjustFontSizeToWidth.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 01.06.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

extension UILabel {
    func adjustFontSizeToWidth(minimumFontSize: CGFloat) {
        guard let text = self.text else { return }
        superview?.layoutIfNeeded()
        
        let fontDecrement: CGFloat = 1.0

        var largestWord = ""
        var largestWordWidth: CGFloat = 0

        if text.count > 10 {
            var characterSet = CharacterSet.whitespacesAndNewlines
            characterSet.insert(charactersIn: "-")
            let words = text.components(separatedBy: characterSet)
            words.forEach { word in
                let wordSize = (word as NSString).size(withAttributes: [NSAttributedString.Key.font: font!])
                let wordWidth = wordSize.width

                if wordWidth > largestWordWidth {
                    largestWordWidth = wordWidth
                    largestWord = word
                }
            }
        } else {
            largestWord = text
            let textSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font!])
            largestWordWidth = textSize.width
        }

        while largestWordWidth > bounds.width && font.pointSize > minimumFontSize {
            font = font.withSize(font.pointSize - fontDecrement)
            let largestWordSize = (largestWord as NSString).size(withAttributes: [NSAttributedString.Key.font: font!])
            largestWordWidth = largestWordSize.width
        }
    }
}
