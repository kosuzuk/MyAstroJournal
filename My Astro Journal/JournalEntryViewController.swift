//
//  FirstViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import Foundation
import SwiftKeychainWrapper
import DropDown
import MessageUI

class JournalEntryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var challengeWinnerButton: UIButton!
    @IBOutlet weak var targetArrow: UIImageView!
    @IBOutlet weak var targetField: UILabel!
    @IBOutlet weak var constellationField: UILabel!
    @IBOutlet weak var moonImageView: UIImageView!
    @IBOutlet weak var ilumPercLabel: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var timeField: UILabel!
    @IBOutlet weak var locationField: UILabel!
    @IBOutlet weak var observedCheckImage: UIImageView!
    @IBOutlet weak var photographedCheckImage: UIImageView!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var featuredButton: UIButton!
    @IBOutlet weak var memoriesLabel: UILabel!
    @IBOutlet weak var memoriesUnderline: UILabel!
    @IBOutlet weak var memoriesField: UITextView!
    @IBOutlet weak var telescopeField: UILabel!
    @IBOutlet weak var mountField: UILabel!
    @IBOutlet weak var cameraField: UILabel!
    @IBOutlet weak var acquisitionField: UITextView!
    @IBOutlet weak var extraPhotosLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var contentViewHC: NSLayoutConstraint!
    @IBOutlet weak var contentViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var arrowWC: NSLayoutConstraint!
    @IBOutlet weak var targetFieldWC: NSLayoutConstraint!
    @IBOutlet weak var imageViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var memoriesLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var memoriesLabelTopCipad: NSLayoutConstraint!
    @IBOutlet weak var acquisitionLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var acquisitionLabelTopCipad: NSLayoutConstraint!
    @IBOutlet weak var mountFieldWC: NSLayoutConstraint!
    var entryList: [[String: Any]] = []
    var selectedEntryInd = 0
    var formattedTargetsList: [String]? = nil
    var entryData: [String: Any] = [:]
    var entryDate = ""
    var contentViewH = CGFloat(0.0)
    var contentViewHipad = CGFloat(0.0)
    var imageSelected: UIImage? = nil
    var featuredDate = ""
    var iodKeysData: [String: Any]? = nil
    var telescopeDD: DropDown? = nil
    var mountDD: DropDown? = nil
    var cameraDD: DropDown? = nil
    var segueFromMonthlyChallenge = false
    var keyForDifferentProfile = ""
    var entryUserName = ""
    var loaded = false
    var cvc: CalendarViewController? = nil
    var jeevc: JournalEntryEditViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(formatLoadingIcon(loadingIcon))
        loadingIcon.startAnimating()
        if screenH > 1000 {//ipads
            background.image = UIImage(named: "ViewEntry/background-ipad")
            border.image = UIImage(named: "border-ipad")
            targetArrow.image = UIImage(named: "ViewEntry/arrow-ipad")
            bigImageView.isHidden = true
        }
        bigImageView.layer.borderWidth = 2
        bigImageView.layer.borderColor = astroOrange
        bigImageView.isUserInteractionEnabled = false
        imageCollectionView.isUserInteractionEnabled = false
        editButton.isHidden = true
        featuredButton.isHidden = true
        
        entryData = entryList[selectedEntryInd]
        targetField.text = (entryData["target"]! as! String)
        constellationField.text = (entryData["constellation"]! as! String)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: entryDate.suffix(4) + "-" + entryDate.prefix(2) + "-" + entryDate.prefix(4).suffix(2))!
        let moonIllumination = suncalc.getMoonIllumination(date: date)
        let moonPhase = moonIllumination["phase"]!
        let ilumPerc = moonIllumination["fraction"]!
        moonImageView.image = moonPhaseValueToImg(moonPhase)
        ilumPercLabel.text = String(Int(ilumPerc * 100.0)) + "%"
        let monthInt = Int(entryDate.prefix(2))!
        let monthStr = monthNames[monthInt - 1]
        dateField.text = monthStr + " " + String(Int(entryDate.prefix(4).suffix(2))!) + " " + String(entryDate.suffix(4))
        timeField.text = (entryData["timeStart"] as! String) + " to " + (entryData["timeEnd"] as! String)
        locationField.text = (entryData["locations"]! as! [String]).joined(separator: ", ")
        if let data = entryData["observed"] {
            if (data as! Bool) {
                observedCheckImage.image = UIImage(named: "ViewEntry/checkmark")
            }
        }
        if let data = entryData["photographed"] {
            if (data as! Bool) {
                photographedCheckImage.image = UIImage(named: "ViewEntry/checkmark")
            }
        }
        let eqFieldValueList = [(entryData["telescope"] as! String), (entryData["mount"] as! String), (entryData["camera"] as! String)]
        if segueFromMonthlyChallenge {
            let eqFieldList = [self.telescopeField!, self.mountField!, self.cameraField!]
            telescopeDD = checkEqToLink(eqType: "telescope", eqFields: eqFieldList, eqFieldValues: eqFieldValueList, iodvc: nil, jevc: self, pvc: nil)
            mountDD = checkEqToLink(eqType: "mount", eqFields: eqFieldList, eqFieldValues: eqFieldValueList, iodvc: nil, jevc: self, pvc: nil)
            cameraDD = checkEqToLink(eqType: "camera", eqFields: eqFieldList, eqFieldValues: eqFieldValueList, iodvc: nil, jevc: self, pvc: nil)
        } else {
            profileButton.isHidden = true
        }
        if !isAdmin || !segueFromMonthlyChallenge {
            challengeWinnerButton.isHidden = true
        }
        memoriesField.text = (entryData["memories"] as! String)
        telescopeField.text = eqFieldValueList[0]
        mountField.text = eqFieldValueList[1]
        cameraField.text = eqFieldValueList[2]
        acquisitionField.text = (entryData["acquisition"] as! String)
        var mainImagePulled = false
        var imagesPulled = false
        func checkFinishedPullingImages() {
            if mainImagePulled && imagesPulled {
                if cvc != nil {//moved from calendar view controller
                    editButton.isHidden = false
                }
                if iodKeysData != nil {
                    featuredButton.isHidden = false
                }
                loadingIcon.stopAnimating()
            }
        }
        let mainImageKey = entryData["mainImageKey"] as! String
        if mainImageKey != "" {
            if !isConnected {
                let alertController = UIAlertController(title: "Error", message: "Images cannot be loaded while offline", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                self.bigImageView.image = UIImage(named: "placeholder")
                self.entryData["mainImage"] = UIImage(named: "placeholder")
                mainImagePulled = true
                checkFinishedPullingImages()
            } else {
                let imageRef = storage.child(mainImageKey)
                imageRef.getData(maxSize: imgMaxByte) {data, Error in
                    if let Error = Error {
                        print(Error)
                        let alertController = UIAlertController(title: "Error", message: "The main image could not be loaded. It may have been deleted.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                        self.entryData["mainImage"] = UIImage(named: "placeholder")
                        mainImagePulled = true
                        checkFinishedPullingImages()
                    } else {
                        self.bigImageView.image = UIImage(data: data!)
                        self.entryData["mainImage"] = UIImage(data: data!)
                        self.bigImageView.isUserInteractionEnabled = true
                        mainImagePulled = true
                        checkFinishedPullingImages()
                    }
                }
            }
        } else {
            bigImageView.isHidden = true
            mainImagePulled = true
        }
        let imageKeyList = entryData["imageKeys"] as! [String]
        var imageList = Dictionary<Int, UIImage>()
        if imageKeyList != [] && !segueFromMonthlyChallenge {
            if !isConnected {
                let img = UIImage(named: "placeholder")
                for i in 0..<imageKeyList.count {
                    imageList[i] = img!
                }
                self.entryData["imageList"] = imageList
                imagesPulled = true
                checkFinishedPullingImages()
            } else {
                for (i, imageKey) in imageKeyList.enumerated() {
                    let imageRef = storage.child(imageKey)
                    imageRef.getData(maxSize: imgMaxByte) {data, Error in
                        var img: UIImage? = nil
                        if let Error = Error {
                            print(Error)
                            img = UIImage(named: "placeholder")
                        } else {
                            img = UIImage(data: data!)
                        }
                        let cell = self.imageCollectionView.cellForItem(at: NSIndexPath(row: i, section: 0) as IndexPath) as! JournalEntryImageCell
                        cell.imageView.image = img!
                        imageList[i] = img!
                        if imageList.count == imageKeyList.count {
                            self.entryData["imageList"] = imageList
                            self.imageCollectionView.isUserInteractionEnabled = true
                            imagesPulled = true
                            checkFinishedPullingImages()
                        }
                    }
                }
            }
        } else {
            extraPhotosLabel.isHidden = true
            imageCollectionView.isHidden = true
            imagesPulled = true
            checkFinishedPullingImages()
        }
        featuredDate = entryData["featuredDate"] as! String
        if featuredDate != "" && isEarlierDate(featuredDate, dateToday) {
            db.collection("imageOfDayKeys").document(featuredDate).getDocument(completion: {(snapshot, Error) in
                if Error != nil {
                    print(Error!)
                } else {
                    self.iodKeysData = snapshot!.data()!
                    if mainImagePulled && imagesPulled {
                        self.featuredButton.isHidden = false
                    }
                }
            })
        }
        if segueFromMonthlyChallenge {
            editButton.isHidden = true
            memoriesLabel.isHidden = true
            memoriesUnderline.isHidden = true
            memoriesField.isHidden = true
            extraPhotosLabel.isHidden = true
            imageCollectionView.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if loaded {
            return
        }
        if screenH < 600 {//iphone SE, 5s
            targetFieldWC.constant = 145
            arrowWC.constant = 135
            mountFieldWC.constant = 98
        }
        else if screenH > 1000 {//ipads
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: imageCollectionView.bounds.height, height: imageCollectionView.bounds.height)
            imageCollectionView.collectionViewLayout = layout
            imageViewHCipad.constant = bigImageView.bounds.width * 0.6
            contentViewHCipad.constant = imageCollectionView.frame.origin.y + imageViewHCipad.constant
            if entryData["mainImageKey"] as! String != "" {
                self.bigImageView.isHidden = false
            }
        }
        if bigImageView.isHidden {
            contentViewHC.constant -= 190
            contentViewHCipad.constant -= bigImageView.bounds.width * 0.6
            memoriesLabelTopC.constant = -160
            memoriesLabelTopCipad.constant = -bigImageView.bounds.width * 0.6 + 20
        }
        if memoriesField.isHidden {
            contentViewHC.constant -= 150
            contentViewHCipad.constant -= bigImageView.bounds.height * 0.37
            acquisitionLabelTopC.constant = -120
            acquisitionLabelTopCipad.constant = -bigImageView.bounds.height * 0.37
        }
        if imageCollectionView.isHidden {
            contentViewHC.constant -= 140
            contentViewHCipad.constant -= 200
        }
        contentViewH = contentViewHC.constant
        contentViewHipad = contentViewHCipad.constant
        loaded = true
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! JournalEntryImageCell
        return cell
    }
    @objc func willEnterForeground() {
        contentViewHC.constant = contentViewH
        contentViewHCipad.constant = contentViewHipad
    }
    @IBAction func profileButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "journalEntryToProfile", sender: self)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    @IBAction func challengeWinnerButtonTapped(_ sender: Any) {
        func managePickWinner() {
            db.collection("userData").document(keyForDifferentProfile).getDocument(completion: {(QuerySnapshot, Error) in
                if Error != nil {
                    print(Error!)
                } else {
                    let email = QuerySnapshot!.data()!["email"] as! String
                    if MFMailComposeViewController.canSendMail() {
                        let mailComposerVC = MFMailComposeViewController()
                        mailComposerVC.mailComposeDelegate = (self as MFMailComposeViewControllerDelegate)
                        mailComposerVC.setToRecipients([email])
                        mailComposerVC.setSubject("My Astro Journal Monthly Challenge Winner")
                        mailComposerVC.setMessageBody("Hi " + self.entryUserName + ",\n\nCongratulations! You are the winner of this month's challenge!\nYou may redeem this $50 off, one-time-use coupon code on your next purchase of $500 or more at Oceanside Photo & Telescope: \n\nZE25JCKVEWKV\n\nThank you for using the My Astro Journal app and we hope you will continue adding fantastic images!\nYou are of course encouraged to participate in other monthly challenges, although the rewards will be discounts on prints as coupons can only be used once per person 🙂\n\nClear Skies,\nAntoine & Dalia Grelin\nGalactic Hunter", isHTML: false)
                        self.present(mailComposerVC, animated: true, completion: nil)
                    }
                }
            })
            db.collection("userData").document(keyForDifferentProfile).updateData(["isMonthlyWinner": true])
            var nextMonth = ""
            if dateToday.prefix(2) == "12" {
                nextMonth = "01" + String(Int(dateToday.suffix(4))! + 1)
            } else {
                nextMonth = String(Int(dateToday.prefix(2))! + 1) + dateToday.suffix(4)
                if nextMonth.count == 5 {
                    nextMonth = "0" + nextMonth
                }
            }
            let entryKey = keyForDifferentProfile + entryDate
            db.collection("monthlyChallenges").document(nextMonth).updateData(["lastMonthJournalEntryListKey": entryKey, "lastMonthWinnerName": entryUserName])
        }
        
        let alertController = UIAlertController(title: "Confirmation", message: "Choose this user as the monthly winner? They will get a popup message.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "yes", style: .destructive, handler: {(alertAction) in managePickWinner()})
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func featuredButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "journalEntryToImageOfDay", sender: self)
    }
    @IBAction func bigImageTapped(_ sender: Any) {
        imageSelected = bigImageView.image
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.imageView.image = imageSelected
        popOverVC.didMove(toParent: self)
    }
    @objc func eqTapped(sender: UIGestureRecognizer) {
        if sender.view == telescopeField {
            telescopeDD!.show()
        } else if sender.view == mountField {
            mountDD!.show()
        } else if sender.view == cameraField {
            cameraDD!.show()
        }
    }
    @IBAction func imageCollectionViewTapped(_ sender: Any) {
        let touch = (sender as AnyObject).location(in: imageCollectionView)
        let indexPath = imageCollectionView.indexPathForItem(at: touch)
        if indexPath == nil {
            return
        }
        imageSelected = (imageCollectionView.cellForItem(at: indexPath!) as! JournalEntryImageCell).imageView.image
        if imageSelected == nil {
            return
        }
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.imageView.image = imageSelected
        popOverVC.didMove(toParent: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JournalEntryEditViewController
        if vc != nil {
            vc!.entryDate = entryDate
            vc!.entryList = entryList
            vc!.selectedEntryInd = selectedEntryInd
            vc!.formattedTargetsList = formattedTargetsList
            vc!.entryData = entryData
            vc!.featuredDate = featuredDate
            vc!.cvc = cvc
            jeevc = vc!
            return
        }
        let vc2 = segue.destination as? ImageOfDayViewController
        if vc2 != nil {
            vc2!.entryKey = iodKeysData!["journalEntryListKey"] as! String
            vc2!.entryInd = selectedEntryInd
            vc2!.iodUserKey = iodKeysData!["userKey"] as! String
            vc2!.imageData = bigImageView.image
            vc2!.featuredDate = featuredDate
            vc2!.cvc = cvc
            //not currently featured
            if featuredDate != featuredImageDate {
                vc2!.notEditable = true
            }
            cvc?.iodvc = vc2
            return
        }
        let vc3 = segue.destination as? ProfileViewController
        if vc3 != nil {
            vc3!.keyForDifferentProfile = keyForDifferentProfile
            return
        }
    }
}

