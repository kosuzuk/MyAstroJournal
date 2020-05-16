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

class AddOnsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SKPaymentTransactionObserver {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var packsCollectionView: UICollectionView!
    @IBOutlet weak var cardBacksCollectionView: UICollectionView!
    @IBOutlet weak var contentViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var packsCVWC: NSLayoutConstraint!
    @IBOutlet weak var packsCVWCipad: NSLayoutConstraint!
    @IBOutlet weak var cardBacksCVWC: NSLayoutConstraint!
    @IBOutlet weak var cardBacksCVWCipad: NSLayoutConstraint!
    @IBOutlet weak var cardBacksCVHCipad: NSLayoutConstraint!
    var packImageNumbers = ["1", "2", "3", "4"]
    var packShortDescriptions = ["Get your camouflage shirt on and jump into your cargo pants, it’s time to hunt some wild space animals!\n[No space animals were harmed in the making of this pack]", "A selection of very small and very large targets. How hungry is your camera tonight?", "Star clusters deserve some love, too! Don’t let them drift away all by themselves!", "It is midnight on October 31st. You are alone, far from home, and decide you want to image a scary looking object. What could go wrong?"]
    var packLongDescriptions = ["The \"Animal Lover\" pack will add the following unlockable cards to your collection:\n\nNGC 457 - The Owl Cluster\nNGC 1501 - The Oyster Nebula\nNGC 4567 and NGC 4568 - The Butterfly Galaxies\nNGC 4676 - The Mice Galaxies\nNGC 6334 - The Cat’s Paw Nebula\nIC 417 - The Spider Nebula\nIC 1795 - The Fishhead Nebula\nIC 2177 - The Seagull Nebula\nIC 2944 - The Running Chicken Nebula\nIC 4592 - The Blue Horsehead Nebula\nSh2-129 - The Flying Bat Nebula\nSh2-157 - The Lobster Claw Nebula\n\nSorry, there are no cute little puppies in space.", "The \"David meets Goliath\" pack will add the following unlockable cards to your collection:\n\nThe Milky Way\nThe Sun\nRho Ophiuchi\nNGC 2440 - The Bow Tie Nebula\nNGC 4656 - The Hockey Stick Galaxy\nNGC 5474 - A galaxy responsible for M101’s asymmetry\nNGC 7009 - The Saturn Nebula\nNGC 7662 - The Blue Snowball Nebula\nIC 1318 - The Sadr Region\nSh2-240 - The Spaghetti Nebula\nArp 188 - The Tadpole Galaxy\nJu1 - The Soap Bubble Nebula\n\nDon’t try to get all these in one session. The sun isn’t going to help.", "The \"Stars, Stars Everywhere\" pack will add the following unlockable cards to your collection:\n\nNGC 1502 - Kemble’s Cascade\nNGC 2360 - Caroline’s Cluster\nNGC 2362 - The Tau Canis Majoris Cluster\nNGC 3532 - The Football Cluster\nNGC 4755 - The Jewel Box Cluster\nNGC 5466 - Cluster in Boötes\nNGC 6388 - Cluster in Scorpius\nNGC 6541 - Cluster in Corona Australis\nNGC 6723 - Cluster in Sagittarius\nNGC 6752 - Cluster in Pavo\nIC 2391 - The Omicron Velorum Cluster\nIC 2602 - The Southern Pleiades\n\nYou know who else loves star clusters that much? No one.", "The \"Spooky Encounters\" pack will add the following unlockable cards to your collection:\n\nNGC 246 - The Skull Nebula\nNGC 1535 - Cleopatra’s Eye Nebula\nNGC 2080 - The Ghost Head Nebula\nNGC 3242 - The Ghost of Jupiter Nebula\nNGC 6369 - The Little Ghost Nebula\nNGC 5907 - The Knife Edge Galaxy\nNGC 6741 - The Phantom Streak Nebula\nNGC 6781 - The Ghost of the Moon Nebula\nNGC 6826 - The Blink Nebula\nSh2-68 - The Death Eater Nebula\nSh2-136 - The Ghost Nebula\nOu4 - The Giant Squid Nebula\n\nPsst: Try not to look behind you."]
    var packsPurchased: [String] = []
    var cardBackImageNumbers = ["6", "7", "8", "9", "10", "11", "12", "13"]
    var cardBackImageNames = ["Foggy Dreams", "Colors of Space", "Canyon Nights", "Digital Space", "Starburst", "Into the Wormhole", "Dusty", "Sparklers"]
    var cardBacksPurchased: [String] = []
    let purchasedOpacity: Float = 0.4
    var purchasedItemType = ""
    var purchasedItemInd = 0
    let packProductIDs = ["100", "101", "102", "103"]
    let cardBackProductIDs = ["201", "202", "203", "204", "205", "206", "207", "208"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH < 600 {//iphpone SE, 5s
            packsCVWC.constant = 310
            cardBacksCVWC.constant = 310
        }
        else if screenH > 1000 {//ipads
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
                self.packsPurchased = Array((userData["packsUnlocked"] as! [String: Bool]).keys).sorted()
                self.cardBacksPurchased = Array((userData["cardBacksUnlocked"] as! [String: Bool]).keys).sorted()
                self.packsCollectionView.reloadData()
                self.cardBacksCollectionView.reloadData()
            }
        })
        SKPaymentQueue.default().add(self)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == packsCollectionView {
            return packImageNumbers.count
        } else {
            return cardBackImageNumbers.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let i = indexPath.row
        if collectionView == packsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PacksCollectionViewCell
            cell.ind = i
            cell.imageView.image = UIImage(named: "AddOns/" + "Packs/" + packImageNumbers[i])!
            cell.descriptionTextView.text = packShortDescriptions[i]
            if packsPurchased.contains(packImageNumbers[i]) {
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
            cell.imageView.image = UIImage(named: "AddOns/" + "CardBacks/" + "Backgrounds/" + cardBackImageNumbers[i])!
            cell.imageNameLabel.text = cardBackImageNames[i]
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
    func showUnlockAnimation(imageName: String) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardUnlockedViewController") as! CardUnlockedViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.unlockedDateLabel.isHidden = true
        popOverVC.imageView.image = UIImage(named: imageName)
        popOverVC.didMove(toParent: self)
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                print("Transaction Successful")
                var path = ""
                let userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
                if purchasedItemType == "pack" {
                    let packNumber = packImageNumbers[purchasedItemInd]
                    path = "AddOns/" + "Packs/" + packNumber
                    let visibleCell = packsCollectionView.cellForItem(at: IndexPath(item: purchasedItemInd, section: 0)) as? PacksCollectionViewCell
                    if visibleCell != nil {
                        visibleCell!.imageView.layer.opacity = purchasedOpacity
                        visibleCell!.priceButton.layer.opacity = purchasedOpacity
                        visibleCell!.priceButton.isUserInteractionEnabled = false
                    }
                    packsPurchased.append(packNumber)
                    packsPurchased.sort()
                    db.collection("userData").document(userKey).setData(["packsUnlocked": [packNumber: true]], merge: true)
                } else {
                    let cardBackNumber = cardBackImageNumbers[purchasedItemInd]
                    path = "AddOns/" + "CardBacks/" + "Backgrounds/" +  cardBackNumber
                    let visibleCell = cardBacksCollectionView.cellForItem(at: IndexPath(item: purchasedItemInd, section: 0)) as? CardBacksCollectionViewCell
                    if visibleCell != nil {
                        visibleCell!.imageView.layer.opacity = purchasedOpacity
                        visibleCell!.priceButton.layer.opacity = purchasedOpacity
                        visibleCell!.priceButton.isUserInteractionEnabled = false
                    }
                    cardBacksPurchased.append(cardBackNumber)
                    cardBacksPurchased.sort()
                    db.collection("userData").document(userKey).setData(["cardBacksUnlocked": [cardBackNumber: true]], merge: true)
                }
                showUnlockAnimation(imageName: path)
            } else if transaction.transactionState == .failed {
                print("Transaction Failed")
            } else if transaction.transactionState == .restored {
                print("restored")
            }
        }
    }
    func purchase(productID: String) {
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
        popOverVC.imageView.image = UIImage(named: "AddOns/" + "CardBacks/" + "Previews/" +  cardBackImageNumbers[ind])!
        popOverVC.textView.text = "This add-on will add the \"" +  cardBackImageNames[ind] + "\" card back to your collection."
        popOverVC.didMove(toParent: self)
    }
}

