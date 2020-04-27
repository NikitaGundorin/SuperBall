//
//  GameViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 21.04.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var ballButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupConstraint: NSLayoutConstraint!
    @IBOutlet weak var popupBackground: UIVisualEffectView!
    @IBOutlet weak var timerLabel: UILabel!
    
    let viewModel = GameViewModel()
    var statusText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ballButton.layer.cornerRadius = ballButton.layer.frame.width / 2
        ballButton.isEnabled = false
        
        popupView.layer.cornerRadius = 20
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.popupBackgroundTouched (_:)))
        self.popupBackground.addGestureRecognizer(gesture)
        
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = viewModel
        viewModel.vc = self
        
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        sceneView.pointOfView?.addChildNode(lightNode)
        
        viewModel.startGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
        hidePopup()
    }
    
    @IBAction func ballTouched(_ sender: Any) {
        viewModel.throwBall()
    }
    
    @IBAction func restartGame(_ sender: Any) {
        viewModel.startGame()
        hidePopup()
    }
    
    @IBAction func resumeGame(_ sender: Any) {
        hidePopup()
        viewModel.runTimer()
    }
    
    @IBAction func pauseGame(_ sender: Any) {
        viewModel.stopTimer()
        showPopup()
    }
    
    @objc private func popupBackgroundTouched(_ sender:UITapGestureRecognizer){
       resumeGame(self)
    }
    
    private func showPopup() {
        popupConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.popupBackground.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func hidePopup() {
        popupConstraint.constant = 1000
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.popupBackground.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? EndGameViewController else { return }
        
        vc.score = viewModel.score
        vc.statusText = self.statusText
    }
}
