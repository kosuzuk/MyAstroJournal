//
//  AddOnsViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 5/2/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import StoreKit

class AddOnsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var packsCollectionView: UICollectionView!
    @IBOutlet weak var cardBacksCollectionView: UICollectionView!
    @IBOutlet weak var contentViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var packsSubHeadingLeadingC: NSLayoutConstraint!
    @IBOutlet weak var cardBacksSubHeadingLeadingC: NSLayoutConstraint!
    @IBOutlet weak var packsCVWC: NSLayoutConstraint!
    @IBOutlet weak var packsCVWCipad: NSLayoutConstraint!
    @IBOutlet weak var cardBacksCVWC: NSLayoutConstraint!
    @IBOutlet weak var cardBacksCVWCipad: NSLayoutConstraint!
    @IBOutlet weak var cardBacksCVHCipad: NSLayoutConstraint!
    let packImageNames = ["1", "2", "3", "4"]
    var packShortDescriptions = ["Get your camouflage shirt on and jump into your cargo pants, it’s time to hunt some wild space animals!\n[No space animals were harmed in the making of this pack]", "A selection of very small and very large targets. How hungry is your camera tonight?", "Star clusters deserve some love, too! Don’t let them drift away all by themselves!", "It is midnight on October 31st. You are alone, far from home, and decide you want to image a scary looking object. What could go wrong?"]
    var packLongDescriptions = ["The \"Animal Lover\" pack will add the following unlockable cards to your collection:\n\n• NGC 457 - The Owl Cluster\n• NGC 1501 - The Oyster Nebula\n• NGC 4567 and NGC 4568 - The Butterfly Galaxies\n• NGC 4676 - The Mice Galaxies\n• NGC 6334 - The Cat’s Paw Nebula\n• IC 417 - The Spider Nebula\n• IC 1795 - The Fishhead Nebula\n• IC 2177 - The Seagull Nebula\n• IC 2944 - The Running Chicken Nebula\n• IC 4592 - The Blue Horsehead Nebula\n• Sh2-129 - The Flying Bat Nebula\n• Sh2-157 - The Lobster Claw Nebula\n\nSorry, there are no cute little puppies in space.", "The \"David meets Goliath\" pack will add the following unlockable cards to your collection:\n\n• The Milky Way\n• The Sun\n• Rho Ophiuchi\n• NGC 2440 - The Bow Tie Nebula\n• NGC 4656 - The Hockey Stick Galaxy\n• NGC 5474 - A galaxy responsible for M101’s asymmetry\n• NGC 7009 - The Saturn Nebula\n• NGC 7662 - The Blue Snowball Nebula\n• IC 1318 - The Sadr Region\n• Sh2-240 - The Spaghetti Nebula\n• Arp 188 - The Tadpole Galaxy\n• Ju1 - The Soap Bubble Nebula\n\nDon’t try to get all these in one session. The sun isn’t going to help.", "The \"Stars, Stars Everywhere\" pack will add the following unlockable cards to your collection:\n\n• NGC 1502 - Kemble’s Cascade\n• NGC 2360 - Caroline’s Cluster\n• NGC 2362 - The Tau Canis Majoris Cluster\n• NGC 3532 - The Football Cluster\n• NGC 4755 - The Jewel Box Cluster\n• NGC 5466 - Cluster in Boötes\n• NGC 6388 - Cluster in Scorpius\n• NGC 6541 - Cluster in Corona Australis\n• NGC 6723 - Cluster in Sagittarius\n• NGC 6752 - Cluster in Pavo\n• IC 2391 - The Omicron Velorum Cluster\n• IC 2602 - The Southern Pleiades\n\nYou know who else loves star clusters that much? No one.", "The \"Spooky Encounters\" pack will add the following unlockable cards to your collection:\n\n• NGC 246 - The Skull Nebula\n• NGC 1535 - Cleopatra’s Eye Nebula\n• NGC 2080 - The Ghost Head Nebula\n• NGC 3242 - The Ghost of Jupiter Nebula\n• NGC 6369 - The Little Ghost Nebula\n• NGC 5907 - The Knife Edge Galaxy\n• NGC 6741 - The Phantom Streak Nebula\n• NGC 6781 - The Ghost of the Moon Nebula\n• NGC 6826 - The Blink Nebula\n• Sh2-68 - The Death Eater Nebula\n• Sh2-136 - The Ghost Nebula\n• Ou4 - The Giant Squid Nebula\n\nPsst: Try not to look behind you."]
    var packsPurchased: [String] = []
    let cardBackImageNames = ["6", "7", "8", "9", "10", "11", "12", "13"]
    let cardBackNames = ["Foggy Dreams", "Colors of Space", "Canyon Nights", "Digital Space", "Starburst", "Into the Wormhole", "Dusty", "Sparklers"]
    var cardBacksPurchased: [String] = []
    var loaded = false
    let purchasedOpacity: Float = 0.4
    var purchasedItemType = ""
    var purchasedItemInd = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH > 1000 {//ipads
            background.image = UIImage(named: "Info/background-ipad")!
            let cardBacksLayout = cardBacksCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
            cardBacksLayout.minimumLineSpacing = 120
            cardBacksCollectionView.collectionViewLayout = cardBacksLayout
            if screenH > 1300 {//ipad 12.9
                let cvSize = CGFloat(900)
                contentViewHCipad.constant = cvSize * 2
                packsCVWCipad.constant = cvSize
                cardBacksCVWCipad.constant = cvSize
                cardBacksCVHCipad.constant = cvSize
                let packsLayout = packsCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
                packsLayout.itemSize = CGSize(width: 190, height: 420)
                packsCollectionView.collectionViewLayout = packsLayout
                cardBacksLayout.itemSize = CGSize(width: 190, height: 320)
                cardBacksCollectionView.collectionViewLayout = cardBacksLayout
            }
        }
        let userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        db.collection("userData").document(userKey).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                let userData = snapshot!.data()!
                self.packsPurchased = (Array((userData["packsUnlocked"] as! [String: Bool]).keys).map {Int($0)!}.sorted()).map{String($0)}
                self.cardBacksPurchased = (Array((userData["cardBacksUnlocked"] as! [String: Bool]).keys).map {Int($0)!}.sorted()).map{String($0)}
                self.packsCollectionView.reloadData()
                self.cardBacksCollectionView.reloadData()
                self.loaded = true
            }
        })
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !loaded {
            return 0
        } else {
            if collectionView == packsCollectionView {
                return packImageNames.count
            } else {
                return cardBackImageNames.count
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let i = indexPath.row
        if collectionView == packsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PacksCollectionViewCell
            cell.ind = i
            cell.imageView.image = UIImage(named: "AddOns/" + "Packs/" + packImageNames[i])!
            cell.descriptionTextView.text = packShortDescriptions[i]
            if packsPurchased.contains(packImageNames[i]) {
                cell.imageView.layer.opacity = purchasedOpacity
                cell.priceButton.layer.opacity = purchasedOpacity
                cell.priceButton.isUserInteractionEnabled = false
            } else {
                cell.imageView.layer.opacity = 1
                cell.priceButton.layer.opacity = 1
                cell.priceButton.isUserInteractionEnabled = true
            }
            cell.aovc = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardBacksCollectionViewCell
            cell.ind = i
            cell.imageView.image = UIImage(named: "AddOns/" + "CardBacks/" + "Backgrounds/" + cardBackImageNames[i])!
            cell.imageNameLabel.text = cardBackNames[i]
            if cardBacksPurchased.contains(cardBackImageNames[i]) {
                cell.imageView.layer.opacity = purchasedOpacity
                cell.priceButton.layer.opacity = purchasedOpacity
                cell.priceButton.isUserInteractionEnabled = false
            } else {
                cell.imageView.layer.opacity = 1
                cell.priceButton.layer.opacity = 1
                cell.priceButton.isUserInteractionEnabled = true
            }
            cell.aovc = self
            return cell
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if screenH < 600 {
            packsSubHeadingLeadingC.constant = 23
            cardBacksSubHeadingLeadingC.constant = 23
            packsCVWC.constant = 310
            cardBacksCVWC.constant = 310
        }
    }
    func showUnlockAnimation(imageName: String) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardUnlockedViewController") as! CardUnlockedViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.unlockedDateLabel.isHidden = true
        if #available(iOS 13.3, *) {
            popOverVC.closeButton.setTitle("", for: .normal)
            popOverVC.closeButton.setImage(UIImage(systemName: "x.circle")!, for: .normal)
        }
        popOverVC.imageView.image = UIImage(named: imageName)
        popOverVC.didMove(toParent: self)
    }
    func manageSuccessfulPurchase() {
        var path = ""
        let userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        if purchasedItemType == "pack" {
            let packNumber = packImageNames[purchasedItemInd]
            path = "AddOns/" + "Packs/" + packNumber
            let visibleCell = packsCollectionView.cellForItem(at: IndexPath(item: purchasedItemInd, section: 0)) as? PacksCollectionViewCell
            if visibleCell != nil {
                visibleCell!.imageView.layer.opacity = purchasedOpacity
                visibleCell!.priceButton.layer.opacity = purchasedOpacity
                visibleCell!.priceButton.isUserInteractionEnabled = false
            }
            packsPurchased.append(packNumber)
            packsPurchased = (packsPurchased.map{Int($0)!}.sorted()).map{String($0)}
            
            var jeevc: JournalEntryEditViewController? = nil
            var jeevcOpen = false
            if tabBarController!.viewControllers![0].children.count > 1 {
                if tabBarController!.viewControllers![0].children[1] as? JournalEntryEditViewController != nil {
                    jeevc = (tabBarController!.viewControllers![0].children[1] as! JournalEntryEditViewController)
                    jeevcOpen = true
                } else if tabBarController!.viewControllers![0].children.count > 2 && tabBarController!.viewControllers![0].children[2] as? JournalEntryEditViewController != nil {
                    jeevc = (tabBarController!.viewControllers![0].children[2] as! JournalEntryEditViewController)
                    jeevcOpen = true
                }
                if jeevcOpen {
                    var userData = jeevc!.userData
                    var packsUnlockedData = (userData["packsUnlocked"] as! [String: Bool])
                    packsUnlockedData[packNumber] = true
                    userData["packsUnlocked"] = packsUnlockedData
                    jeevc!.userData = userData
                }
            }
            db.collection("userData").document(userKey).setData(["packsUnlocked": [packNumber: true]], merge: true)
        } else {
            let cardBackNumber = cardBackImageNames[purchasedItemInd]
            path = "AddOns/" + "CardBacks/" + "Backgrounds/" +  cardBackNumber
            let visibleCell = cardBacksCollectionView.cellForItem(at: IndexPath(item: purchasedItemInd, section: 0)) as? CardBacksCollectionViewCell
            if visibleCell != nil {
                visibleCell!.imageView.layer.opacity = purchasedOpacity
                visibleCell!.priceButton.layer.opacity = purchasedOpacity
                visibleCell!.priceButton.isUserInteractionEnabled = false
            }
            cardBacksPurchased.append(cardBackNumber)
            cardBacksPurchased = (cardBacksPurchased.map{Int($0)!}.sorted()).map{String($0)}
            db.collection("userData").document(userKey).setData(["cardBacksUnlocked": [cardBackNumber: true]], merge: true)
        }
        purchasedItemType = ""
        purchasedItemInd = 0
        showUnlockAnimation(imageName: path)
        loadingIcon.stopAnimating()
        endNoInput()
    }
//    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        print("restore finished")
//        for transaction in queue.transactions {
//            let productID = transaction.payment.productIdentifier
//            if packProductIDs.contains(productID) {
//                let packNumberToRestore = packImageNames[packProductIDs.index(of: productID)!]
//                if !packsPurchased.contains(packNumberToRestore) {
//                    purchasedItemType = "pack"
//                    purchasedItemInd = packProductIDs.index(of: productID)!
//                    manageSuccessfulPurchase()
//                }
//            } else {
//                let cardBackNumberToRestore = cardBackImageNames[cardBackProductIDs.index(of: productID)!]
//                if !cardBacksPurchased.contains(cardBackNumberToRestore) {
//                    purchasedItemType = "card back"
//                    purchasedItemInd = cardBackProductIDs.index(of: productID)!
//                    manageSuccessfulPurchase()
//                }
//            }
//            queue.finishTransaction(transaction)
//        }
//        loadingIcon.stopAnimating()
//        endNoInput()
//    }
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            if transaction.transactionState == .purchased {
//                print("Transaction Successful")
//                manageSuccessfulPurchase()
//                queue.finishTransaction(transaction)
//            } else if transaction.transactionState == .failed {
//                print("Transaction Failed")
//                queue.finishTransaction(transaction)
//                loadingIcon.stopAnimating()
//                endNoInput()
//            } else if transaction.transactionState == .restored {
//                print("restored an item")
//            } else {
//                print(transaction.transactionState)
//            }
//        }
//    }
    func purchase(productID: String) {
        startNoInput()
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
        loadingIcon.startAnimating()
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("User unable to make payments")
        }
    }
    func packPurchase(_ ind: Int) {
        purchasedItemType = "pack"
        purchasedItemInd = ind
        purchase(productID: packProductIDs[ind])
    }
    func packShowMoreInfo(_ ind: Int) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PackDescriptionPopOverViewController") as! PackDescriptionPopOverViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.textView.text = packLongDescriptions[ind]
        popOverVC.didMove(toParent: self)
    }
    func cardBackPurchase(_ ind: Int) {
        purchasedItemType = "cardBack"
        purchasedItemInd = ind
        purchase(productID: cardBackProductIDs[ind])
    }
    func cardBackShowMoreInfo(_ ind: Int) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardBackDescriptionPopOverViewController") as! CardBackDescriptionPopOverViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.imageView.image = UIImage(named: "AddOns/" + "CardBacks/" + "Previews/" +  cardBackImageNames[ind])!
        popOverVC.textView.text = "This add-on will add the \"" +  cardBackNames[ind] + "\" card back to your collection."
        popOverVC.didMove(toParent: self)
    }
    @IBAction func restoreButtonTapped(_ sender: Any) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

