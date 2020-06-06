//
//  SecondViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class CardGroupsViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var catalogsLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var cardBacksButton: UIButton!
    @IBOutlet weak var sharplessButton: UIButton!
    @IBOutlet weak var othersButton: UIButton!
    @IBOutlet weak var bannerHC: NSLayoutConstraint!
    @IBOutlet weak var catalogsLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var catalogsTopCipad: NSLayoutConstraint!
    @IBOutlet weak var categoriesLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var categoriesTopCipad: NSLayoutConstraint!
    @IBOutlet weak var messierWC: NSLayoutConstraint!
    @IBOutlet weak var messierWCipad: NSLayoutConstraint!
    @IBOutlet weak var sharplessTrailingC: NSLayoutConstraint!
    @IBOutlet weak var othersLeadingCipad: NSLayoutConstraint!
    @IBOutlet weak var sharplessTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var othersLeadingC: NSLayoutConstraint!
    @IBOutlet weak var galaxiesWC: NSLayoutConstraint!
    @IBOutlet weak var galaxiesWCipad: NSLayoutConstraint!
    var userKey = ""
    var doneLoading = false
    var photoCardTargetDatesDict: [String: [String]]? = nil
    var cardTargetDatesDict: [String: [String]]? = nil
    var numFeaturedDates = 0
    var numFeaturedDatesLoaded = 0 {
        didSet {
            if numFeaturedDatesLoaded == numFeaturedDates {
                for item in view.subviews {
                    if item is UIButton {
                        item.isHidden = false
                    }
                }
                loadingIcon.stopAnimating()
                endNoInput()
                self.doneLoading = true
            }
        }
    }
    var featuredTargets: [String: String] = [:]
    var packsUnlocked: [String] = []
    var sharplessUnlocked = false
    var othersUnlocked = false
    var cardBacksUnlocked: [String] = []
    var cardBackPopOverController: CardBackBackgroundsPopOverViewController? = nil
    var cardBackSelected = ""
    var groupChosen = ""
    var catalogVC: CardCatalogViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        startNoInput()
        view.addSubview(formatLoadingIcon(loadingIcon))
        loadingIcon.startAnimating()
        if screenH < 600 {//iphone SE, 5s
            bannerHC.constant = 35
            catalogsLabelTopC.constant = 5
            categoriesLabelTopC.constant = 5
            messierWC.constant = 62
            galaxiesWC.constant = 90
            catalogsLabel.font = UIFont(name: catalogsLabel.font.fontName, size: 20)
            categoriesLabel.font = UIFont(name: categoriesLabel.font.fontName, size: 20)
        } else if (screenH == 667) {//iphone 8
            catalogsLabelTopC.constant = 10
            categoriesLabelTopC.constant = 10
            messierWC.constant = 78
            galaxiesWC.constant = 110
            catalogsLabel.font = UIFont(name: catalogsLabel.font.fontName, size: 23)
            categoriesLabel.font = UIFont(name: categoriesLabel.font.fontName, size: 23)
        } else if (screenH == 896) {//iphone 11 pro max
            messierWC.constant = 102
            galaxiesWC.constant = 149
        } else if screenH > 1000 {//ipads
            background.image = UIImage(named: "CardGroups/background-ipad")
            border.image = UIImage(named: "border-ipad")
            catalogsLabel.font = UIFont(name: catalogsLabel.font.fontName, size: 30)
            categoriesLabel.font = UIFont(name: categoriesLabel.font.fontName, size: 30)
            if screenH > 1150 {//ipads 11 and 12.9
                catalogsLabel.font = UIFont(name: catalogsLabel.font.fontName, size: 38)
                categoriesLabel.font = UIFont(name: categoriesLabel.font.fontName, size: 38)
                if screenH == 1194 {//ipad 11
                    messierWCipad.constant *= 1.14
                    galaxiesWCipad.constant *= 1.17
                } else {
                    messierWCipad.constant *= 1.3
                    galaxiesWCipad.constant *= 1.3
                }
            }
        }
        for item in view.subviews {
            if item is UIButton {
                item.isHidden = true
            }
        }
        func checkCardGroupsUnlocked() {
            if packsUnlocked.contains("1") {
                sharplessButton.setImage(UIImage(named: "CardGroups/sharpless"), for: .normal)
                sharplessUnlocked = true
            }
            if packsUnlocked.contains("2") || packsUnlocked.contains("4") {
                sharplessButton.setImage(UIImage(named: "CardGroups/sharpless"), for: .normal)
                othersButton.setImage(UIImage(named: "CardGroups/others"), for: .normal)
                sharplessUnlocked = true
                othersUnlocked = true
            }
        }
        userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        db.collection("userData").document(userKey).addSnapshotListener (includeMetadataChanges: true, listener: {(snapshot, Error) in
            if Error != nil {
                return
            }
            if (snapshot?.metadata.isFromCache)! && isConnected {
                return
            }
            let data = snapshot!.data()!
            //initial pull
            if self.cardTargetDatesDict == nil {
                self.photoCardTargetDatesDict = (data["photoCardTargetDates"]! as! [String: [String]])
                self.cardTargetDatesDict = (data["cardTargetDates"]! as! [String: [String]])
                let featureDates = (data["userDataCopyKeys"]! as! [String: String]).keys
                if featureDates.count == 0 {
                    for item in self.view.subviews {
                        if item is UIButton {
                            item.isHidden = false
                        }
                    }
                    loadingIcon.stopAnimating()
                    endNoInput()
                    self.doneLoading = true
                }
                for date in featureDates {
                    if isEarlierDate(date, dateToday) {
                        self.numFeaturedDates += 1
                        db.collection("imageOfDayKeys").document(date).getDocument(completion: {(snapshot, Error) in
                            if Error != nil {
                                print(Error!)
                            } else {
                                self.featuredTargets[snapshot!.data()!["formattedTarget"] as! String] = date
                                self.numFeaturedDatesLoaded += 1
                            }
                        })
                    }
                }
                self.cardBackSelected = (data["cardBackSelected"] as! String)
                self.packsUnlocked = (Array((data["packsUnlocked"] as! [String: Bool]).keys).map {Int($0)!}.sorted()).map{String($0)}
                checkCardGroupsUnlocked()
                self.cardBacksUnlocked = (Array((data["cardBacksUnlocked"] as! [String: Bool]).keys).map {Int($0)!}.sorted()).map{String($0)}
            } else {
                //check if user entered or deleted entries
                let newPhotoCardTargetDates = data["photoCardTargetDates"]! as! [String: [String]]
                let newCardTargetDates = data["cardTargetDates"]! as! [String: [String]]
                if self.photoCardTargetDatesDict != newPhotoCardTargetDates || self.cardTargetDatesDict != newCardTargetDates {
                    self.photoCardTargetDatesDict = newPhotoCardTargetDates
                    self.cardTargetDatesDict = newCardTargetDates
                    self.catalogVC?.photoCardTargetDatesDict = newPhotoCardTargetDates
                    self.catalogVC?.cardTargetDatesDict = newCardTargetDates
                    self.catalogVC?.dictChanged = true
                }
                let packsUnlockedData = (Array((data["packsUnlocked"] as! [String: Bool]).keys).map {Int($0)!}.sorted()).map{String($0)}
                if packsUnlockedData != self.packsUnlocked {
                    self.catalogVC?.navigationController?.popToRootViewController(animated: true)
                    self.packsUnlocked = packsUnlockedData
                    checkCardGroupsUnlocked()
                }
                let cardBacksUnlockedData = (Array((data["cardBacksUnlocked"] as! [String: Bool]).keys).map {Int($0)!}.sorted()).map{String($0)}
                if cardBacksUnlockedData != self.cardBacksUnlocked {
                    self.cardBackPopOverController?.dismiss(animated: true)
                    self.cardBacksUnlocked = cardBacksUnlockedData
                }
            }
        })
        if firstTime {
            let alertController = UIAlertController(title: "Tutorial", message: "This is where you will find a collection of cards. Cards unlock after adding new entries with images you are proud of. It’s your mission to unlock all the cards - good luck!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if screenH < 600 {//iphone SE, 5s
            catalogsLabelTopC.constant = 5
            categoriesLabelTopC.constant = 5
            sharplessTrailingC.constant = -17
            othersLeadingC.constant = -17
        } else if screenH == 667 {//iphone 8
            catalogsLabelTopC.constant = 10
            categoriesLabelTopC.constant = 10
            sharplessTrailingC.constant = -24
            othersLeadingC.constant = -24
        } else if screenH == 896 {//iphone 11 pro max
            sharplessTrailingC.constant = -35
            othersLeadingC.constant = -35
        } else if screenH == 1112 {//ipad 10.5
            catalogsTopCipad.constant = 40
        } else if screenH == 1194 {//ipad 11
            sharplessTrailingCipad.constant = -48
            othersLeadingCipad.constant = -48
        } else if screenH == 1366 {//ipad 12.9
            catalogsTopCipad.constant = 50
            categoriesTopCipad.constant = 30
            sharplessTrailingCipad.constant = -59
            othersLeadingCipad.constant = -59
        }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    @IBAction func cardBacksButtonTapped(_ sender: Any) {
        cardBackPopOverController = (self.storyboard!.instantiateViewController(withIdentifier: "CardBackBackgroundsPopOverViewController") as! CardBackBackgroundsPopOverViewController)
        cardBackPopOverController!.modalPresentationStyle = .popover
        var viewW = 290
        var viewH = 280
        if screenH > 1000 {//ipads
            viewW = 370
            viewH = 340
            if screenH > 1300 {//ipads
                viewW = 440
                viewH = 420
            }
        }
        cardBackPopOverController!.preferredContentSize = CGSize(width: viewW, height: viewH)
        cardBackPopOverController!.cardBacksUnlocked = cardBacksUnlocked
        cardBackPopOverController!.cgvc = self
        let popOverPresentationController = cardBackPopOverController!.popoverPresentationController!
        popOverPresentationController.permittedArrowDirections = .up
        popOverPresentationController.sourceView = self.view
        let popOverPos = CGRect(x: cardBacksButton.frame.origin.x, y: cardBacksButton.frame.origin.y, width: cardBacksButton.bounds.width, height: cardBacksButton.bounds.height)
        popOverPresentationController.sourceRect = popOverPos
        popOverPresentationController.delegate = self as UIPopoverPresentationControllerDelegate
        present(cardBackPopOverController!, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? CardCatalogViewController
        if vc != nil {
            vc?.group = groupChosen
            vc?.photoCardTargetDatesDict = photoCardTargetDatesDict!
            vc?.cardTargetDatesDict = cardTargetDatesDict!
            vc?.packsUnlocked = packsUnlocked
            vc?.featuredTargets = featuredTargets
            vc?.cardBackSelected = cardBackSelected
            vc?.cgvc = self
            catalogVC = vc
        }
    }
    func callPerformSegue(groupName: String) {
        if doneLoading {
            groupChosen = groupName
            performSegue(withIdentifier: "cardGroupsToCollection", sender: self)
        }
    }
    @IBAction func messierPressed(_ sender: Any) {
        callPerformSegue(groupName: "Messier")
    }
    @IBAction func ICPressed(_ sender: Any) {
        callPerformSegue(groupName: "IC")
    }
    @IBAction func NGCPressed(_ sender: Any) {
        callPerformSegue(groupName: "NGC")
    }
    @IBAction func sharplessPressed(_ sender: Any) {
        if sharplessUnlocked {
            callPerformSegue(groupName: "Sharpless")
        } else {
            performSegue(withIdentifier: "cardGroupsToAddOns", sender: self)
        }
    }
    @IBAction func othersPressed(_ sender: Any) {
        if othersUnlocked {
            callPerformSegue(groupName: "Others")
        } else {
            performSegue(withIdentifier: "cardGroupsToAddOns", sender: self)
        }
    }
    @IBAction func galaxiesPressed(_ sender: Any) {
        callPerformSegue(groupName: "Galaxies")
    }
    @IBAction func nebulaePressed(_ sender: Any) {
        callPerformSegue(groupName: "Nebulae")
    }
    @IBAction func clustersPressed(_ sender: Any) {
        callPerformSegue(groupName: "Clusters")
    }
    @IBAction func planetsPressed(_ sender: Any) {
        callPerformSegue(groupName: "Planets")
    }
}

