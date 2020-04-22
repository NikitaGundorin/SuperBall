//
//  SCNGeometryExtension.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 21.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import SceneKit.SCNGeometry

extension SCNGeometry {
    static func Box(width: CGFloat, height: CGFloat, length: CGFloat) -> SCNGeometry {
        let w = width / 2
        let h = height / 2
        let l = length / 2
        let src = SCNGeometrySource(vertices: [
            SCNVector3(-w, -h, -l),
            SCNVector3(w, -h, -l),
            SCNVector3(w, -h, l),
            SCNVector3(-w, -h, l),

            SCNVector3(-w, h, -l),
            SCNVector3(w, h, -l),
            SCNVector3(w, h, l),
            SCNVector3(-w, h, l),
        ])
        let indices: [UInt32] = [
            0, 1, 3,
            3, 1, 2,
            0, 3, 4,
            4, 3, 7,
            1, 5, 2,
            2, 5, 6,
            4, 7, 5,
            5, 7, 6,
            3, 2, 7,
            7, 2, 6,
            0, 4, 1,
            1, 4, 5,
        ]
        let inds = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry.init(sources: [src], elements: [inds])
    }
}
