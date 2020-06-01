//
//  WalkthroughViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 18.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit
import ARKit

class WalkthroughViewController: UIViewController {
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("WELCOME TO", comment: "Welcome label title")
        label.textAlignment = .center
        label.font = Appearance.fontBold20
        label.textColor = Appearance.red
        
        return label
    }()
    
    private let superBallLabel: UILabel = {
        let label = UILabel()
        label.text = "SuperBall"
        label.textAlignment = .center
        label.font = Appearance.fontBold40
        label.textColor = Appearance.red
        
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Allow access to the camera to start the game!",
                                       comment: "Allow camera access message")
        label.textAlignment = .center
        label.numberOfLines = 5
        label.font = Appearance.font20
        label.textColor = Appearance.red
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }()
    
    private let okButton: UIButton = {
        let btn = UIButton(type: .system)
        let title = NSLocalizedString("OK", comment: "Ok button title")
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.textAlignment = .center
        btn.setTitleColor(Appearance.red, for: .normal)
        btn.titleLabel?.font = Appearance.fontBold25
        btn.addTarget(self, action: #selector(okTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var welcomeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [welcomeLabel, superBallLabel])
        stackView.spacing = 30
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var messageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [messageLabel, okButton])
        stackView.spacing = 20
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var welcomeVerticalConstraint: NSLayoutConstraint = welcomeStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    private lazy var messageVerticalConstraint: NSLayoutConstraint = messageStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    private var welcomeWasShown = false
    private var lightMessageWasShown = false
    private var messageBorderShapeLayer: CAShapeLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            showLightMessage()
            return
        }
        
        if welcomeWasShown {
            checkCameraAccess()
        } else {
            welcomeAnimate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        UserDefaults.standard.setValue(true, forKey: "walkthroughWasShown")
    }
    
    private func setupLayout() {
        view.backgroundColor = .black
        
        for view in [welcomeStackView, messageStackView] {
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            welcomeStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -30),
            messageStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 30),
            messageStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 400),
            welcomeVerticalConstraint,
            messageVerticalConstraint
        ])
        
        welcomeVerticalConstraint.constant = 1000
        messageVerticalConstraint.constant = 1000
    }
    
    @objc private func okTapped() {
        guard lightMessageWasShown == false else {
            dismiss(animated: true)
            return
        }
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
            else {
                checkCameraAccess()
                return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.showLightMessage()
                }
            } else {
                DispatchQueue.main.async {
                    self.dismissMessage { _ in
                        self.cameraMessageError()
                        self.showMessage()
                    }
                }
            }
        }
    }
    
    private func welcomeAnimate() {
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut], animations: {
            self.welcomeVerticalConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1, options: [.curveEaseInOut], animations: {
                Appearance.addDash(toLabel: self.superBallLabel, animated: true)
                self.welcomeVerticalConstraint.isActive = false
                self.welcomeStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.checkCameraAccess()
                self.welcomeWasShown = true
            })
        }
    }
    
    private func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            showMessage()
            return
        case .denied:
            cameraMessageError()
            showMessage()
        case .restricted, .authorized:
            showLightMessage()
            return
        @unknown default:
            showLightMessage()
            return
        }
    }
    
    private func showMessage(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.messageVerticalConstraint.constant = 0
            self.messageBorderShapeLayer = Appearance.addDashedBorder(to: self.messageStackView,
                                                                      oldBorder: self.messageBorderShapeLayer)
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
    
    private func dismissMessage(completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.messageVerticalConstraint.constant = 1000
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
    
    private func cameraMessageError() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        self.messageLabel.text = NSLocalizedString("You didn't allow access to the Camera :(\nGo to Setings -> Privacy -> Camera and tap the toggle next to SuperBall app", comment: "Camera acess denied message")
        self.messageBorderShapeLayer = Appearance.addDashedBorder(to: self.messageStackView,
        oldBorder: messageBorderShapeLayer)
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.03
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: messageLabel.center.x - 10, y: messageLabel.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: messageLabel.center.x + 10, y: messageLabel.center.y))
        
        messageLabel.layer.add(animation, forKey: "position")
    }
    
    private func showLightMessage() {
        if UserDefaults.standard.bool(forKey: "walkthroughWasShown") {
            dismiss(animated: true)
            return
        }
        
        dismissMessage { _ in
            self.messageLabel.text = NSLocalizedString("For better AR performance play in good light!",
                                                       comment: "Good light message")
            self.showMessage { _ in self.lightMessageWasShown = true }
        }
    }
}
