//
//  SecondViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class CardCatalogViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var unlockedLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var searchLeadingC: NSLayoutConstraint!
    @IBOutlet weak var cvTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var cvLeadingCipad: NSLayoutConstraint!
    var group = ""
    var cardTargetDatesDict: [String: [String]] = [:]
    var photoCardTargetDatesDict: [String: [String]] = [:]
    var availableCards: [String] = []
    var cardsToDisplay: [String] = []
    var numUnlockedCards = 0
    var loaded = false
    var showingCard = false
    var curCardInd = 0
    var cardLastInd = 0
    var swipeDir = "" {
        didSet {
            if swipeDir == "right" {
                curCardInd -= 1
            } else if swipeDir == "left" {
                curCardInd += 1
            }
            let c = cardVC!
            c.imageView.image = (cardCollectionView.cellForItem(at: IndexPath(row: curCardInd, section: 0)) as! CardCell).cardImageView.image
            let target = cardsToDisplay[curCardInd]
            c.target = target
            let photoDateList = photoCardTargetDatesDict[target]
            if photoDateList == nil {
                c.unlockedDateLabel.isHidden = true
            } else {
                c.unlockedDateLabel.isHidden = false
                c.unlockedDate = photoDateList![photoDateList!.count - 1]
            }
            let dateList = cardTargetDatesDict[target]
            if dateList == nil {
                c.entryDatesButton.isHidden = true
            } else {
                c.entryDatesButton.isHidden = false
                c.journalEntryDateList = dateList!
            }
        }
    }
    var cardJustClosed = false {
        didSet {
            if cardJustClosed {
                viewDidAppear(true)
                cardJustClosed = false
            }
        }
    }
    var dictChanged = false {
        didSet {
            if dictChanged {
                if showingCard {
                    cardVC!.removeAnimate()
                }
                cardCollectionView.reloadData()
                numUnlockedCards = 0
                for card in availableCards {
                    if photoCardTargetDatesDict[card] != nil {
                        numUnlockedCards += 1
                    }
                }
                self.unlockedLabel.text = "Cards Unlocked: " + String(numUnlockedCards) + "/" + String(availableCards.count)
                dictChanged = false
            }
        }
    }
    var cgvc: CardGroupsViewController? = nil
    var cardVC: CardViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = UIColor.white.cgColor
        searchField.delegate = (self as UITextFieldDelegate)
        searchField.autocorrectionType = .no
        switch group {
        case "Messier":
            bannerImage.image = UIImage(named: "Catalog/MessierBanner")
            availableCards = MessierTargets
        case "IC":
            bannerImage.image = UIImage(named: "Catalog/ICBanner")
            availableCards = ICTargets
        case "NGC":
            bannerImage.image = UIImage(named: "Catalog/NGCBanner")
            availableCards = NGCTargets
        case "Galaxies":
            bannerImage.image = UIImage(named: "Catalog/GalaxiesBanner")
            availableCards = GalaxyTargets
        case "Nebulae":
            bannerImage.image = UIImage(named: "Catalog/NebulaeBanner")
            availableCards = NebulaTargets
        case "Clusters":
            bannerImage.image = UIImage(named: "Catalog/ClustersBanner")
            availableCards = ClusterTargets
        case "Planets":
            bannerImage.image = UIImage(named: "Catalog/PlanetsBanner")
            availableCards = PlanetTargets
        default:
            availableCards = []
        }
        cardsToDisplay = availableCards
        cardLastInd = availableCards.count - 1
        cardCollectionView.reloadData()
        numUnlockedCards = 0
        for card in availableCards {
            if photoCardTargetDatesDict[card] != nil {
                numUnlockedCards += 1
            }
        }
        unlockedLabel.text = "Cards Unlocked: " + String(numUnlockedCards) + "/" + String(availableCards.count)
        searchField.isHidden = true
        resetButton.isHidden = true
        searchIcon.isHidden = true
        cardCollectionView.isHidden = true
        if firstTime {
            let alertController = UIAlertController(title: "Tutorial", message: "This is where you will find your collection of cards. Cards unlock after entering new entries with images you are proud of. In the future,  each unlocked card will have their own page full of information!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !loaded {
            searchField.isHidden = false
            resetButton.isHidden = false
            searchIcon.isHidden = false
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            if screenH < 600 {//iphone SE, 5s
                searchLeadingC.constant = 0
                layout.itemSize = CGSize(width: 80, height: 119)
                layout.minimumInteritemSpacing = 0
                cardCollectionView.collectionViewLayout = layout
            }
            else if screenW > 400 && screenW < 500 {//iphone 8 plus and 11 pro max
                layout.itemSize = CGSize(width: 114, height: 170)
                layout.minimumLineSpacing = 19
                cardCollectionView.collectionViewLayout = layout
            }
            if screenH > 1000 {//ipads
                background.image = UIImage(named: "Catalog/background-ipad")
                unlockedLabel.font = unlockedLabel.font.withSize(22)
                layout.itemSize = CGSize(width: cardCollectionView.bounds.width / 4 - 20, height: (cardCollectionView.bounds.width / 4 - 20) * 1.49)
                layout.minimumLineSpacing = 50
                cardCollectionView.collectionViewLayout = layout
            }
            cardCollectionView.isHidden = false
            loaded = true
        }
        searchField.resignFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        if screenH > 1300 {//ipad 12.9
            cvLeadingCipad.constant = 70
            cvTrailingCipad.constant = 70
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardsToDisplay.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        let i = indexPath.row
        let cardName = cardsToDisplay[i]
        var imageName = ""
        if Array(cardName)[1].isNumber {
            imageName = "Messier/" + cardName.dropFirst()
        } else if cardName.prefix(3) == "NGC" {
            imageName = "NGC/" + cardName.suffix(cardName.count - 3)
        } else if cardName.prefix(2) == "IC" {
            imageName = "IC/" + cardName.suffix(cardName.count - 2)
        } else {
            imageName = "Planets/" + cardName
        }
        if photoCardTargetDatesDict[cardName] == nil {
            imageName = "LockedCards/" + imageName
        } else {
            imageName = "UnlockedCards/" + imageName
        }
        cell.cardImageView.image = UIImage(named: imageName)
        return cell
    }
    func search() {
        searchField.resignFirstResponder()
        cardsToDisplay = []
        let formattedTarget = formatTarget(inputTarget: searchField.text!)
        for card in availableCards {
            if card == formattedTarget {
                cardsToDisplay.append(card)
                break
            }
        }
        cardCollectionView.reloadData()
        cardLastInd = cardsToDisplay.count - 1
    }
    @IBAction func resetTapped(_ sender: Any) {
        searchField.text = ""
        searchField.resignFirstResponder()
        cardsToDisplay = availableCards
        cardCollectionView.reloadData()
        cardLastInd = availableCards.count - 1
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            cardsToDisplay = availableCards
            cardCollectionView.reloadData()
        } else {
            search()
        }
    }
    @IBAction func cardTapped(_ sender: UITapGestureRecognizer) {
        searchField.resignFirstResponder()
        let touch = sender.location(in: cardCollectionView)
        let indexPath = cardCollectionView.indexPathForItem(at: touch)
        if indexPath == nil {
            return
        }
        cardVC = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardViewController") as! CardViewController)
        let c = cardVC!
        self.addChild(c)
        let f = self.view.frame
        c.view.frame = CGRect(x: 0, y: 0, width: f.width, height: f.height)
        self.view.addSubview(c.view)
        c.imageView.image = (cardCollectionView.cellForItem(at: indexPath!) as! CardCell).cardImageView.image
        let target = cardsToDisplay[indexPath!.row]
        c.target = target
        let photoDateList = photoCardTargetDatesDict[target]
        if photoDateList != nil {
            c.unlockedDate = photoDateList![photoDateList!.count - 1]
        }
        let dateList = cardTargetDatesDict[target]
        if dateList != nil {
            c.journalEntryDateList = dateList!
        }
        let userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        c.userKey = userKey
        c.catalogVC = self
        c.didMove(toParent: self)
        curCardInd = indexPath!.row
        showingCard = true
    }
}

