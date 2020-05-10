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
    @IBOutlet weak var cardBacksButton: UIButton!
    @IBOutlet weak var catalogsLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var categoriesLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var galaxiesLeadingC: NSLayoutConstraint!
    @IBOutlet weak var messierWC: NSLayoutConstraint!
    @IBOutlet weak var galaxiesWC: NSLayoutConstraint!
    @IBOutlet weak var messierWCipad: NSLayoutConstraint!
    @IBOutlet weak var galaxiesWCipad: NSLayoutConstraint!
    var userKey = ""
    var doneLoading = false
    var photoCardTargetDatesDict: [String: [String]]? = nil
    var cardTargetDatesDict: [String: [String]]? = nil
    var numFeaturedDates = 0
    var numFeaturedDatesLoaded = 0 {
        didSet {
            if numFeaturedDatesLoaded == numFeaturedDates {
                loadingIcon.stopAnimating()
                endNoInput()
                self.doneLoading = true
            }
        }
    }
    var featuredTargets: [String: String] = [:]
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
            catalogsLabelTopC.constant = 5
            categoriesLabelTopC.constant = 10
            messierWC.constant = 80
            galaxiesWC.constant = 120
        }
        else if (screenH > 800 && screenH < 820) {//iphone 11 pro
            categoriesLabelTopC.constant = 60
        }
        else if (screenH > 820 && screenH < 900) {//iphone 11 pro max
            catalogsLabelTopC.constant = 60
            categoriesLabelTopC.constant = 90
        }
        if (screenW > 400 && screenW < 440) {//8 plus and 11 pro max
            galaxiesLeadingC.constant = 50
        }
        else if screenH > 1150 {//ipads 11 and 12.9
            background.image = UIImage(named: "CardGroups/background-ipad")
            if screenH < 1300 {//ipad 11
                messierWCipad.constant *= 1.25
                galaxiesWCipad.constant *= 1.25
            } else {
                messierWCipad.constant *= 1.45
                galaxiesWCipad.constant *= 1.45
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
                        loadingIcon.stopAnimating()
                        endNoInput()
                        self.doneLoading = true
                    }
                    for date in featureDates {
                        if isEarlierDate(date1: date, date2: dateToday) {
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
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    @IBAction func cardBacksButtonTapped(_ sender: Any) {
        let popOverController = self.storyboard!.instantiateViewController(withIdentifier: "CardBackBackgroundsPopOverViewController") as? CardBackBackgroundsPopOverViewController
        popOverController!.modalPresentationStyle = .popover
        var viewW = 295
        var viewH = 395
        if screenH < 600 {//iphone SE, 5s
            viewH = 300
        } else if screenH > 1000 {//ipads
            viewW = 420
            viewH = 650
        }
        popOverController!.preferredContentSize = CGSize(width: viewW, height: viewH)
        popOverController!.cgvc = self
        popOverController!.userKey = userKey
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
    @IBAction func planetsPressed(_ sender: Any) {
        callPerformSegue(groupName: "Planets")
    }
}

