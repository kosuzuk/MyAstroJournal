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
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("restore finished")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                print("Transaction Successful")
                a!.manageSuccessfulPurchase()
                queue.finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                print("Transaction Failed")
                queue.finishTransaction(transaction)
                loadingIcon.stopAnimating()
                endNoInput()
            } else if transaction.transactionState == .restored {
                print("restored an item")
            } else {
                print(transaction.transactionState)
            }
        }
    }
    
    
}
