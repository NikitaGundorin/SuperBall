//
//  RemoveAdsViewController.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 26.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import UIKit

class RemoveAdsViewController: UIViewController {
    weak var delegate: RemoveAdsDelegate?
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "REMOVE ADS"
        label.font = Appearance.fontBold40
        label.numberOfLines = 2
        label.textColor = Appearance.red
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "GET EXTRA LIVES WITHOUT WATCHING ADS"
        label.font = Appearance.font20
        label.textColor = Appearance.red
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 4
        
        return label
    }()
    
    private let purchaseButton: UIButton = {
        let button = UIButton(type: .system)
        let price = IAPManager.shared.priceStringFor(productWith: IAPManager.removeAdProductIdentifier)
        let buttonTitle = "REMOVE ADS FOR \(price)"
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(Appearance.blue, for: .normal)
        button.titleLabel?.font = Appearance.fontBold25
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(purchase), for: .touchUpInside)
        
        return button
    }()
    
    private let restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RESTORE PURCHASE", for: .normal)
        button.setTitleColor(Appearance.red, for: .normal)
        button.titleLabel?.font = Appearance.font20
        button.addTarget(self, action: #selector(restorePurchase), for: .touchUpInside)
        
        return button
    }()
    
    private let laterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("MAYBE LATER", for: .normal)
        button.setTitleColor(Appearance.red, for: .normal)
        button.titleLabel?.font = Appearance.font20
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        return button
    }()
    
    private let activityIndicator = ActivityIndicator()
    
    private let popup = PopupView(frame: CGRect.zero)
    
    private let iapManager = IAPManager.shared
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        notificationCenter.addObserver(self,
                                       selector: #selector(completeTransaction),
                                       name: NSNotification.Name(rawValue: IAPManager.removeAdProductIdentifier),
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(error),
                                       name: NSNotification.Name(rawValue: "transactionError"),
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(hideActivityIndicator),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(showActivityIndicator),
                                       name: NSNotification.Name(rawValue: "transactionPurchasing"),
                                       object: nil)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideActivityIndicator)))
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    private func setupLayout() {
        view.backgroundColor = .black
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, purchaseButton])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        
        for view in [stackView, restoreButton, laterButton, activityIndicator, popup] {
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restoreButton.bottomAnchor.constraint(equalTo: laterButton.topAnchor, constant: -20),
            laterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            laterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            popup.topAnchor.constraint(equalTo: view.topAnchor),
            popup.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            popup.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.layoutIfNeeded()
        Appearance.addDash(toLabel: titleLabel)
        
        let borderLayer = CAShapeLayer()
        borderLayer.fillColor = nil
        borderLayer.lineWidth = 1
        borderLayer.strokeColor = Appearance.blue.cgColor
        borderLayer.path = CGPath(rect: CGRect(x: -15,
                                               y: -15,
                                               width: purchaseButton.titleLabel!.bounds.width + 30,
                                               height: purchaseButton.titleLabel!.bounds.height + 30),
                                  transform: nil)
        purchaseButton.titleLabel?.layer.addSublayer(borderLayer)
    }
    
    @objc private func purchase() {
        activityIndicator.show()
        iapManager.purchase(productWith: IAPManager.removeAdProductIdentifier)
    }
    
    @objc private func restorePurchase() {
        activityIndicator.show()
        iapManager.restoreCompletedTransactions()
    }
    
    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func completeTransaction() {
        activityIndicator.hide()
        UserDefaults.standard.set(true, forKey: IAPManager.removeAdProductIdentifier)
        delegate?.adRemoved()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func error() {
        activityIndicator.hide()
        let errorPopup = ErrorPopup(title: "PURCHASE FAILED", message: "Please try again later")
        errorPopup.delegate = self
        
        popup.show(withContent: errorPopup)
    }
    
    @objc private func showActivityIndicator() {
        activityIndicator.show()
    }
    
    @objc private func hideActivityIndicator() {
        activityIndicator.hide()
    }
}

extension RemoveAdsViewController: ErrorPopupDelegate {
    func confirm() {
        popup.hide()
    }
}

protocol RemoveAdsDelegate: class {
    func adRemoved()
}
