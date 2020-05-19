//
//  Appearance.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 11.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class Appearance {
    static let fontName = "Helvetica"
    static let lightFontName = "Helvetica-Light"
    static let boldFontName = "Helvetica-Bold"
    static let blue = UIColor(red: 6/255.0, green: 70/255.0, blue: 255/255.0, alpha: 1)
    static let red = UIColor(red: 251/255.0, green: 87/255.0, blue: 94/255.0, alpha: 1)
    static let yellow = UIColor(red: 255/255.0, green: 239/255.0, blue: 92/255.0, alpha: 1)
    static let green = UIColor(red: 33/255.0, green: 255/255.0, blue: 162/255.0, alpha: 1)
    static let purple = UIColor(red: 172/255.0, green: 121/255.0, blue: 255/255.0, alpha: 1)
    
    static let font100 = UIFont(name: lightFontName, size: 100)
    static let font50 = UIFont(name: fontName, size: 50)
    static let font40 = UIFont(name: fontName, size: 40)
    static let font30 = UIFont(name: fontName, size: 30)
    static let font25 = UIFont(name: fontName, size: 25)
    static let fontBold50 = UIFont(name: boldFontName, size: 50)
    static let fontBold40 = UIFont(name: boldFontName, size: 40)
    static let fontBold30 = UIFont(name: boldFontName, size: 30)
    static let fontBold25 = UIFont(name: boldFontName, size: 25)
    static let fontBold20 = UIFont(name: boldFontName, size: 20)
    
    static func addDash(toLabel label: UILabel, animated: Bool = false, duration: CFTimeInterval = 1) {
        label.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        label.superview?.layoutSubviews()
        
        let topShapeLayer = CAShapeLayer()
        topShapeLayer.strokeColor = blue.cgColor
        topShapeLayer.lineWidth = 3
        topShapeLayer.lineDashPattern = [3, 10]
        topShapeLayer.lineCap = CAShapeLayerLineCap.round
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: -10),
                                CGPoint(x: label.bounds.width, y: -10)])
        topShapeLayer.path = path
        
        let bottomShapeLayer = CAShapeLayer()
        bottomShapeLayer.strokeColor = red.cgColor
        bottomShapeLayer.lineWidth = 3
        bottomShapeLayer.lineDashPattern = [3, 10]
        bottomShapeLayer.lineCap = CAShapeLayerLineCap.round
        
        let bottomPath = CGMutablePath()
        bottomPath.addLines(between: [CGPoint(x: 0, y: label.bounds.height + 10),
                                      CGPoint(x: label.bounds.width, y: label.bounds.height + 10)])
        bottomShapeLayer.path = bottomPath
        
        label.layer.addSublayer(topShapeLayer)
        label.layer.addSublayer(bottomShapeLayer)
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.duration = duration
            topShapeLayer.add(animation, forKey: "MyAnimation")
            bottomShapeLayer.add(animation, forKey: "MyAnimation")
        }
    }
    
    static func addDashedBorder(to view: UIView, oldBorder: CAShapeLayer? = nil) -> CAShapeLayer {
        view.superview?.layoutSubviews()
        oldBorder?.removeFromSuperlayer()
        
        let verticalOffset: CGFloat = 15
        let horizontOffset: CGFloat = 15
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = blue.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.lineDashPattern = [3, 10]
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.fillColor = nil
        
        let rect = CGRect(x: -horizontOffset,
                          y: -verticalOffset,
                          width: view.bounds.width + horizontOffset * 2,
                          height: view.bounds.height + verticalOffset * 2)
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 20)
        
        shapeLayer.path = path.cgPath
        view.layer.addSublayer(shapeLayer)
        
        return shapeLayer
    }
}
