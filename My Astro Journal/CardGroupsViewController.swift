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
    var cardBacksUnlocked: [String] = []
    var cardBackSelected = ""
    var groupChosen = ""
    var catalogVC: CardCatalogViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        startNoInput()
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
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
        sharplessButton.isUserInteractionEnabled = false
        othersButton.isUserInteractionEnabled = false
        for item in view.subviews {
            if item is UIButton {
                item.isHidden = true
            }
        }
        userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        db.collection("userData").document(userKey).addSnapshotListener (includeMetadataChanges: true, listener: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                if (snapshot?.metadata.isFromCache)! {
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
                    self.cardBackSelected = (data["cardBackSelected"]! as! String)
                    for (pack, _) in (data["packsUnlocked"]! as! [String: Bool]) {
                        self.packsUnlocked.append(pack)
                        if pack == "1" {
                            self.sharplessButton.setImage(UIImage(named: "CardGroups/sharpless")!, for: .normal)
                            self.sharplessButton.isUserInteractionEnabled = true
                        } else if pack == "2" || pack == "4" {
                            self.sharplessButton.setImage(UIImage(named: "CardGroups/sharpless")!, for: .normal)
                            self.othersButton.setImage(UIImage(named: "CardGroups/others")!, for: .normal)
                            self.sharplessButton.isUserInteractionEnabled = true
                            self.othersButton.isUserInteractionEnabled = true
                        }
                    }
                    for (cardBack, _) in (data["cardBacksUnlocked"]! as! [String: Bool]) {
                        self.cardBacksUnlocked.append(cardBack)
                    }
                    self.cardBacksUnlocked.sort()
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
                }
            }
        })
        if firstTime {
            let alertController = UIAlertController(title: "Tutorial", message: "This is where you will find your collection of cards. Cards unlock after adding new entries with images you are proud of. In the future, each unlocked card will have their own page full of information!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
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
        let popOverController = self.storyboard!.instantiateViewController(withIdentifier: "CardBackBackgroundsPopOverViewController") as? CardBackBackgroundsPopOverViewController
        popOverController!.modalPresentationStyle = .popover
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
        popOverController!.preferredContentSize = CGSize(width: viewW, height: viewH)
        popOverController!.cardBacksUnlocked = cardBacksUnlocked
        popOverController!.cgvc = self
        let popOverPresentationController = popOverController!.popoverPresentationController!
        popOverPresentationController.permittedArrowDirections = .up
        popOverPresentationController.sourceView = self.view
        let popOverPos = CGRect(x: cardBacksButton.frame.origin.x, y: cardBacksButton.frame.origin.y, width: cardBacksButton.bounds.width, height: cardBacksButton.bounds.height)
        popOverPresentationController.sourceRect = popOverPos
        popOverPresentationController.delegate = self as UIPopoverPresentationControllerDelegate
        present(popOverController!, animated: true, completion: nil)
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
    @IBAction func galaxiesPressed(_ sender: Any) {
        callPerformSegue(groupName: "Galaxies")
    }
    @IBAction func nebulaePressed(_ sender: Any) {
        callPerformSegue(groupName: "Nebulae")
    }
    @IBAction func clustersPressed(_ sender: Any) {
        callPerformSegue(groupName: "Clusters")
    }
    @IBAction func sharplessPressed(_ sender: Any) {
        callPerformSegue(groupName: "Sharpless")
    }
    @IBAction func planetsPressed(_ sender: Any) {
        callPerformSegue(groupName: "Planets")
    }
    @IBAction func othersPressed(_ sender: Any) {
        callPerformSegue(groupName: "Others")
    }
}

