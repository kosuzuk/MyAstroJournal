//
//  TransactionObserver.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 5/20/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit
import StoreKit

class TransactionObserver: NSObject, SKPaymentTransactionObserver {
    var addOnsVC: AddOnsViewController? = nil
    var incompletePurchaseProductIDs: [String] = []
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                print("Transaction Successful")
                if addOnsVC != nil {
                    //add ons vc is open
                    addOnsVC!.manageSuccessfulPurchase()
                } else {
                    //there was an incomplete purchase and app just opened
                    incompletePurchaseProductIDs.append(transaction.payment.productIdentifier)
                }
                queue.finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                print("Transaction Failed")
                if addOnsVC != nil {
                    addOnsVC!.manageFailedPurchase()
                }
                queue.finishTransaction(transaction)
            } else if transaction.transactionState == .restored {
                print("restored an item")
            } else {
                print(transaction.transactionState)
            }
        }
    }
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("restore finished")
        for transaction in queue.transactions {
            let productID = transaction.payment.productIdentifier
            if addOnsVC != nil {
                addOnsVC!.manageRestore(productID)
            }
            queue.finishTransaction(transaction)
        }
    }
}
