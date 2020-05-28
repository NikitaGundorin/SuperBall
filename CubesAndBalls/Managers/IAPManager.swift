//
//  IAPManager.swift
//  CubesAndBalls
//
//  Created by Никита Гундорин on 27.05.2020.
//  Copyright © 2020 Nikita Gundorin. All rights reserved.
//

import StoreKit

class IAPManager: NSObject {
    static let shared = IAPManager()
    static let productNotificationIdentifier = "IAPManagerProductIdentifier"
    static let removeAdProductIdentifier = "superball.removeAds"
    let paymentQueue = SKPaymentQueue.default()
    var products: [SKProduct] = []
    
    private override init() {}
    
    func setupPurchases(completion: (Bool) -> ()) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(false)
            return
        }
        paymentQueue.add(self)
        completion(true)
    }
    
    func getProducts() {
        let identifiers: Set = [IAPManager.removeAdProductIdentifier]
        
        let productRequest = SKProductsRequest(productIdentifiers: identifiers)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func purchase(productWith identifier: String) {
        guard let product = products.filter({ $0.productIdentifier == identifier }).first else { return }
        let payment = SKPayment(product: product)
        paymentQueue.add(payment)
    }
    
    func restoreCompletedTransactions() {
        paymentQueue.restoreCompletedTransactions()
    }
    
    func priceStringFor(productWith identifier: String) -> String {
        guard let product = products.filter({ $0.productIdentifier == identifier }).first else { return "" }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        
        return numberFormatter.string(from: product.price)!
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .deferred:
                break
            case .purchasing:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionPurchasing"), object: nil)
                break
            case .failed:
                failed(transaction: transaction)
            case .purchased:
                completed(transaction: transaction)
            case .restored:
                restored(transaction: transaction)
            @unknown default:
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as NSError? {
            if error.code != SKError.paymentCancelled.rawValue {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionError"), object: nil)
                print("Restore completed transactions failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func failed(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "transactionError"), object: nil)
                print("Transaction error: \(transaction.error!.localizedDescription)")
            }
        }
        paymentQueue.finishTransaction(transaction)
    }
    
    private func completed(transaction: SKPaymentTransaction) {
        NotificationCenter.default.post(name: NSNotification.Name(transaction.payment.productIdentifier), object: nil)
        paymentQueue.finishTransaction(transaction)
    }
    
    private func restored(transaction: SKPaymentTransaction) {
        NotificationCenter.default.post(name: NSNotification.Name(transaction.payment.productIdentifier), object: nil)
        paymentQueue.finishTransaction(transaction)
    }
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        if products.count > 0 {
            NotificationCenter.default.post(name: NSNotification.Name(IAPManager.productNotificationIdentifier),
                                            object: nil)
        }
    }
}
