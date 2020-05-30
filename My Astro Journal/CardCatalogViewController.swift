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
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var unlockedLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var searchLeadingC: NSLayoutConstraint!
    @IBOutlet weak var cvTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var cvLeadingCipad: NSLayoutConstraint!
    var group = ""
    var packsUnlocked: [String] = []
    var cardTargetDatesDict: [String: [String]] = [:]
    var photoCardTargetDatesDict: [String: [String]] = [:]
    var availableCards: [String] = []
    var cardsToDisplay: [String] = []
    var numUnlockedCards = 0
    var loaded = false
    var featuredTargets: [String: String] = [:]
    var cardBackSelected = ""
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
            var cell = (cardCollectionView.cellForItem(at: IndexPath(row: curCardInd, section: 0)) as? CardCell)
            if cell == nil {
                cell = (collectionView(cardCollectionView, cellForItemAt: IndexPath(row: curCardInd, section: 0)) as! CardCell)
            }
            let c = cardVC!
            c.cardImage = cell!.cardImageView.image
            c.imageView.image = c.cardImage
            let target = cardsToDisplay[curCardInd]
            c.target = target
            let photoDateList = photoCardTargetDatesDict[target]
            if photoDateList == nil {
                c.unlockedDateLabel.isHidden = true
                c.unlockedDate = ""
            } else {
                c.unlockedDateLabel.isHidden = false
                c.unlockedDate = photoDateList![photoDateList!.count - 1]
            }
            let dateList = cardTargetDatesDict[target]
            if dateList == nil {
                c.entryDatesButton.isHidden = true
                c.journalEntryDateList = []
            } else {
                c.entryDatesButton.isHidden = false
                c.journalEntryDateList = dateList!
            }
            if featuredTargets[target] == nil {
                c.featuredIcon.isHidden = true
                c.featuredDate = ""
            } else {
                c.featuredIcon.isHidden = false
                c.featuredDate = featuredTargets[target]!
            }
            let imageName = "Catalog/CardBacks/Info/" + formattedTargetToImageName(target: cardsToDisplay[curCardInd])
            c.cardInfoImage = UIImage(named: imageName)
            c.backgroundImageView.image = nil
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
            case "Sharpless":
                bannerImage.image = UIImage(named: "Catalog/SharplessBanner")
                availableCards = SharplessTargets
            case "Others":
                bannerImage.image = UIImage(named: "Catalog/OthersBanner")
                availableCards = OthersTargets
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
        if group != "Messier" {
            //remove locked cards
            var lockedCards = Set<String>()
            if !packsUnlocked.contains("1") {
                lockedCards = lockedCards.union(Pack1Targets)
            }
            if !packsUnlocked.contains("2") {
                lockedCards = lockedCards.union(Pack2Targets)
            }
            if !packsUnlocked.contains("3") {
                lockedCards = lockedCards.union(Pack3Targets)
            }
            if !packsUnlocked.contains("4") {
                lockedCards = lockedCards.union(Pack4Targets)
            }
            let tempCards = availableCards
            var ind = 0
            for card in tempCards {
                if lockedCards.contains(card) {
                    availableCards.remove(at: ind)
                } else {
                    ind += 1
                }
            }
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
                border.image = UIImage(named: "border-ipad")
                unlockedLabel.font = unlockedLabel.font.withSize(22)
                layout.itemSize = CGSize(width: cardCollectionView.bounds.width / 4 - 20, height: (cardCollectionView.bounds.width / 4 - 20) * 1.49)
                layout.minimumLineSpacing = 50
                cardCollectionView.collectionViewLayout = layout
            }
            cardCollectionView.contentOffset.y = 0.0
            cardCollectionView.isHidden = false
            let dropDown = VPAutoComplete()
            dropDown.dataSource = ["Messier", "Sharpless", "Milky Way", "Rho Ophiuchi"]
            dropDown.onTextField = searchField
            dropDown.onView = self.view
            dropDown.cellHeight = 34
            dropDown.frame.origin.y = searchField.frame.origin.y + 39
            dropDown.show {(str, index) in
                self.searchField.text = str
            }
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
        let target = cardsToDisplay[indexPath.row]
        var imageName = formattedTargetToImageName(target: target)
        if photoCardTargetDatesDict[target] == nil {
            imageName = "LockedCards/" + imageName
        } else {
            imageName = "UnlockedCards/" + imageName
        }
        cell.cardImageView.image = UIImage(named: imageName)
        if featuredTargets[target] == nil {
            cell.featuredIcon.isHidden = true
        } else {
            cell.featuredIcon.isHidden = false
        }
        return cell
    }
    func search() {
        searchField.resignFirstResponder()
        cardsToDisplay = []
        let formattedTarget = formatTarget(searchField.text!)
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
        c.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(c.view)
        c.cardImage = (cardCollectionView.cellForItem(at: indexPath!) as! CardCell).cardImageView.image
        c.imageView.image = c.cardImage
        let target = cardsToDisplay[indexPath!.row]
        c.target = target
        let dateList = cardTargetDatesDict[target]
        if dateList != nil {
            c.journalEntryDateList = dateList!
        }
        let photoDateList = photoCardTargetDatesDict[target]
        if photoDateList != nil {
            c.unlockedDate = photoDateList![photoDateList!.count - 1]
        }
        if featuredTargets[target] != nil {
            c.featuredDate = featuredTargets[target]!
        }
        c.userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        let imageName = "Catalog/CardBacks/Info/" + formattedTargetToImageName(target: cardsToDisplay[indexPath!.row])
        c.cardInfoImage = UIImage(named: imageName)
        if Int(cardBackSelected)! < 6 {
            c.backgroundImage = UIImage(named: "Catalog/CardBacks/Backgrounds/" + cardBackSelected)
        } else {
            c.backgroundImage = UIImage(named: "AddOns/CardBacks/Backgrounds/" + cardBackSelected)
        }
        c.catalogVC = self
        c.didMove(toParent: self)
        curCardInd = indexPath!.row
        showingCard = true
    }
}

