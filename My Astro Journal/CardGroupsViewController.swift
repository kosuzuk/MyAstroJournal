//
//  SecondViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class CardGroupsViewController: UIViewController {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var catalogsLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var categoriesLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var galaxiesLeadingC: NSLayoutConstraint!
    @IBOutlet weak var messierWC: NSLayoutConstraint!
    @IBOutlet weak var galaxiesWC: NSLayoutConstraint!
    @IBOutlet weak var messierWCipad: NSLayoutConstraint!
    @IBOutlet weak var galaxiesWCipad: NSLayoutConstraint!
    var groupChosen = ""
    var doneLoading = false
    var photoCardTargetDatesDict: [String: [String]]? = nil
    var cardTargetDatesDict: [String: [String]]? = nil
    var catalogVC: CardCatalogViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
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
                    self.doneLoading = true
                    loadingIcon.stopAnimating()
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
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? CardCatalogViewController
        if vc != nil {
            vc?.group = groupChosen
            vc?.photoCardTargetDatesDict = photoCardTargetDatesDict!
            vc?.cardTargetDatesDict = cardTargetDatesDict!
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
