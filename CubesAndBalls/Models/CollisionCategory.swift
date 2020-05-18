//
//  CollisionCategory.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 22.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import Foundation

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let ballCategory = CollisionCategory(rawValue: 1 << 0)
    static let boxCategory = CollisionCategory(rawValue: 1 << 1)
}
