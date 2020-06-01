//
//  GameStatus.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 02.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation

enum GameStatus {
    case win
    case wrongColor
    case timeUp
    case ballsOver
    case pause
    case newRecord
    case extraAdded
    
    var titles: (title: String, button: String) {
        switch self {
        case .wrongColor:
            let title = NSLocalizedString("WRONG COLOR", comment: "Wrong color itle in popup")
            let button = NSLocalizedString("EXTRA LIFE", comment: "Extra life button in popup")
            return (title, button)
        case .timeUp:
            let title = NSLocalizedString("TIME'S UP", comment: "Time's up title in popup")
            let button = NSLocalizedString("+30 SECS", comment: "Extra secs button in popup")
            return (title, button)
        case .ballsOver:
            let title = NSLocalizedString("BALLS'RE OVER", comment: "Balls're over title in popup")
            let button = NSLocalizedString("+10 BALLS", comment: "Extra balls button in popup")
            return (title, button)
        case .win:
            let title = NSLocalizedString("YOU WON", comment: "Win title in popup")
            let button = NSLocalizedString("NEXT LEVEL", comment: "Next level button in popup")
            return (title, button)
        case .pause:
            let title = NSLocalizedString("PAUSE", comment: "Pause title in popup")
            let button = NSLocalizedString("RESUME", comment: "Resume button in popup")
            return (title, button)
        case .extraAdded:
            let title = NSLocalizedString("READY?", comment: "Ready title in popup")
            let button = NSLocalizedString("RESUME", comment: "Resume button in popup")
            return (title, button)
        case .newRecord:
            let title = NSLocalizedString("NEW RECORD", comment: "New record title in popup")
            let button = NSLocalizedString("EXTRA LIFE", comment: "Extra life button in popup")
            return (title, button)
        }
    }
}
