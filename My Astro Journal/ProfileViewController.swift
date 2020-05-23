//
//  FirstViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var mathBackground: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var favObjField: UILabel!
    @IBOutlet weak var favObjFieldLabel: UILabel!
    @IBOutlet weak var userBio: UITextView!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var instaButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var equipmentLabel: UILabel!
    @IBOutlet weak var telescopeIcon: UIImageView!
    @IBOutlet weak var mountIcon: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var userTelescope: UILabel!
    @IBOutlet weak var userTelescope2: UILabel!
    @IBOutlet weak var userTelescope3: UILabel!
    @IBOutlet weak var userMount: UILabel!
    @IBOutlet weak var userMount2: UILabel!
    @IBOutlet weak var userMount3: UILabel!
    @IBOutlet weak var userCamera: UILabel!
    @IBOutlet weak var userCamera2: UILabel!
    @IBOutlet weak var userCamera3: UILabel!
    @IBOutlet weak var statsBanner: UIImageView!
    @IBOutlet weak var statsHoursLabel: UITextView!
    @IBOutlet weak var statsFeaturedLabel: UITextView!
    @IBOutlet weak var statsSeenLabel: UITextView!
    @IBOutlet weak var statsPhotoLabel: UITextView!
    @IBOutlet weak var statsHours: UILabel!
    @IBOutlet weak var statsFeatured: UILabel!
    @IBOutlet weak var statsSeen: UILabel!
    @IBOutlet weak var statsPhoto: UILabel!
    @IBOutlet weak var userImageWCipad: NSLayoutConstraint!
    @IBOutlet weak var userImageLeadingCipad: NSLayoutConstraint!
    @IBOutlet weak var userNameTopC: NSLayoutConstraint!
    @IBOutlet weak var websiteWC: NSLayoutConstraint!
    @IBOutlet weak var websiteLeadingC: NSLayoutConstraint!
    @IBOutlet weak var websiteTrailingC: NSLayoutConstraint!
    @IBOutlet weak var instaWC: NSLayoutConstraint!
    @IBOutlet weak var instaTrailingC: NSLayoutConstraint!
    @IBOutlet weak var youtubeWC: NSLayoutConstraint!
    @IBOutlet weak var youtubeTrailingC: NSLayoutConstraint!
    @IBOutlet weak var fbWC: NSLayoutConstraint!
    @IBOutlet weak var websiteWCipad: NSLayoutConstraint!
    @IBOutlet weak var websiteLeadingCipad: NSLayoutConstraint!
    @IBOutlet weak var websiteTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var instaWCipad: NSLayoutConstraint!
    @IBOutlet weak var instaTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var youtubeWCipad: NSLayoutConstraint!
    @IBOutlet weak var youtubeTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var fbWCipad: NSLayoutConstraint!
    @IBOutlet weak var favObjTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var dividerTopC: NSLayoutConstraint!
    @IBOutlet weak var dividerTopCipad: NSLayoutConstraint!
    @IBOutlet weak var eqLabelTopCipad: NSLayoutConstraint!
    @IBOutlet weak var circleTopC: NSLayoutConstraint!
    @IBOutlet weak var circleBottomC: NSLayoutConstraint!
    @IBOutlet weak var circleTrailingC: NSLayoutConstraint!
    @IBOutlet weak var circleLeadingC: NSLayoutConstraint!
    @IBOutlet weak var userImageTopCipad: NSLayoutConstraint!
    @IBOutlet weak var circleTopCipad: NSLayoutConstraint!
    @IBOutlet weak var circleBottomCipad: NSLayoutConstraint!
    var userKey = ""
    var userData: Dictionary<String, Any>! = nil
    var eqFields: [UILabel] = []
    var websiteLeadingCDefault = CGFloat(0.0)
    var websiteLeadingCipadDefault = CGFloat(0.0)
    var iconW = CGFloat(0.0)
    var iconGap = CGFloat(0.0)
    var profileChanged = false
    var newImage: UIImage? = nil
    var keyForDifferentProfile = ""
    var pevc: ProfileEditViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func layOutSMIcons() {
        let websiteName = (userData["websiteName"] as! String)
        let instaUsername = (userData["instaUsername"] as! String)
        let youtubeChannel = (userData["youtubeChannel"] as! String)
        let fbPage = (userData["fbPage"] as! String)
        var numIconsPresent = 0
        for field in [websiteName, instaUsername, youtubeChannel, fbPage] {
            if field != "" {numIconsPresent += 1}
        }
        if numIconsPresent == 1 {
            websiteLeadingC.constant = websiteLeadingCDefault + iconW + iconGap + iconW / 2
            websiteLeadingCipad.constant = websiteLeadingCipadDefault + iconW + iconGap + iconW / 2
        } else if numIconsPresent == 2 {
            websiteLeadingC.constant = websiteLeadingCDefault + iconW + iconGap
            websiteLeadingCipad.constant = websiteLeadingCipadDefault + iconW + iconGap
        } else if numIconsPresent == 3 {
            websiteLeadingC.constant = websiteLeadingCDefault + iconW / 2
            websiteLeadingCipad.constant = websiteLeadingCipadDefault + iconW / 2
        } else if numIconsPresent == 4 {
            websiteLeadingC.constant = websiteLeadingCDefault
            websiteLeadingCipad.constant = websiteLeadingCipadDefault
        }
        if websiteName == "" {
            websiteWC.constant = 0
            websiteTrailingC.constant = 0
            websiteWCipad.constant = 0
            websiteTrailingCipad.constant = 0
        } else {
            websiteWC.constant = 21
            websiteTrailingC.constant = 10
            websiteWCipad.constant = 31
            websiteTrailingCipad.constant = 15
        }
        if instaUsername == "" {
            instaWC.constant = 0
            instaTrailingC.constant = 0
            instaWCipad.constant = 0
            instaTrailingCipad.constant = 0
        } else {
            instaWC.constant = 21
            instaTrailingC.constant = 10
            instaWCipad.constant = 31
            instaTrailingCipad.constant = 15
        }
        if youtubeChannel == "" {
            youtubeWC.constant = 0
            youtubeTrailingC.constant = 0
            youtubeWCipad.constant = 0
            youtubeTrailingCipad.constant = 0
        } else {
            youtubeWC.constant = 21
            youtubeTrailingC.constant = 10
            youtubeWCipad.constant = 31
            youtubeTrailingCipad.constant = 15
        }
        if fbPage == "" {
            fbWC.constant = 0
            fbWCipad.constant = 0
        } else {
            fbWC.constant = 21
            fbWCipad.constant = 31
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eqFields = [self.userTelescope, self.userTelescope2, self.userTelescope3, self.userMount, self.userMount2, self.userMount3, self.userCamera, self.userCamera2, self.userCamera3]
        if (screenH < 600) {//iphone SE, 5s
            favObjFieldLabel.text = "fav object:"
            equipmentLabel.isHidden = true
            telescopeIcon.isHidden = true
            mountIcon.isHidden = true
            cameraIcon.isHidden = true
            for eq in eqFields {
                eq.isHidden = true
            }
            statsBanner.isHidden = true
            statsHoursLabel.font = UIFont(name: "Pacifica Condensed", size: 14)
            statsHoursLabel.textAlignment = .right
            statsFeaturedLabel.font = UIFont(name: "Pacifica Condensed", size: 14)
            statsSeenLabel.font = UIFont(name: "Pacifica Condensed", size: 14)
            statsSeenLabel.textAlignment = .right
            statsPhotoLabel.font = UIFont(name: "Pacifica Condensed", size: 14)
        }
        else if (screenH < 700) {//iphone 8
            statsBanner.isHidden = true
        } else if (screenH < 750) {//iphone 8 plus
            userNameTopC.constant = 6
            dividerTopC.constant = 6
        } else if (screenH > 820 && screenH < 900) {//11, pro max
            userNameTopC.constant = 14
            dividerTopC.constant = 30
            circleTopC.constant = 45
            circleBottomC.constant = 45
        } else if screenH > 1000 {//ipads
            background.image = UIImage(named: "Profile/background-ipad")
            mathBackground.image = UIImage(named: "Profile/math-ipad")
            border.image = UIImage(named: "border-ipad")
            userName.font = UIFont(name: userName.font!.fontName, size: 28)
            userLocation.font = UIFont(name: userLocation.font!.fontName, size: 18)
            if screenH > 1150 {//11 and 12.9
                userImageTopCipad.constant = 80
                dividerTopCipad.constant = 40
                circleTopCipad.constant = 80
                circleBottomCipad.constant = 80
                if screenH > 1300 {//12.9
                    userImageWCipad.constant = 250
                    userImageLeadingCipad.constant = 110
                    websiteLeadingCipad.constant = 50
                    favObjTrailingCipad.constant = 160
                    dividerTopCipad.constant = 70
                    eqLabelTopCipad.constant = 40
                }
            }
        }
        websiteLeadingCDefault = websiteLeadingC.constant
        websiteLeadingCipadDefault = websiteLeadingCipad.constant
        if screenH < 1000 {
            iconW = websiteWC.constant
            iconGap = websiteTrailingC.constant
        } else {
            iconW = websiteWCipad.constant
            iconGap = websiteTrailingCipad.constant
        }
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = astroOrange
        editButton.isHidden = true
        userBio.textContainerInset.top = 0
        userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        if keyForDifferentProfile != "" {
            userKey = keyForDifferentProfile
            logOutButton.isHidden = true
        }
        websiteButton.isHidden = true
        instaButton.isHidden = true
        youtubeButton.isHidden = true
        fbButton.isHidden = true
        userName.adjustsFontSizeToFitWidth = true
        userName.minimumScaleFactor = 0.6
        if firstTime {
            let alertController = UIAlertController(title: "Tutorial", message: "This is your profile! Add some information about yourself and save your equipment for easy access when entering new entries.\nYour bio, profile picture, social media links and stats will be visible to the public when one of your images is featured as Image of the Week!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        let docRef = db.collection("userData").document(userKey)
        docRef.getDocument(completion: {(QuerySnapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                if QuerySnapshot!.data() == nil {
                    self.navigationController?.popViewController(animated: true)
                }
                let docData = QuerySnapshot!.data()!
                self.userData = docData
                let imageKey = (docData["profileImageKey"] as! String)
                if imageKey != "" {
                    self.view.addSubview(formatLoadingIcon(icon: loadingIcon))
                    loadingIcon.startAnimating()
                    let imageRef = storage.child(imageKey)
                    imageRef.getData(maxSize: imgMaxByte) {data, Error in
                        if let Error = Error {
                            print(Error)
                            self.userImage.image = nil
                            return
                        } else {
                            if data != nil {
                                print("image set!")
                                self.userImage.image = UIImage(data: data!)
                                if self.keyForDifferentProfile == "" {
                                    self.editButton.isHidden = false
                                }
                                loadingIcon.stopAnimating()
                            }
                        }
                    }
                } else {
                    self.userImage.image = UIImage(named: "Profile/placeholderProfileImage")
                    if self.keyForDifferentProfile == "" {
                        self.editButton.isHidden = false
                    }
                }
                self.userName.text = (docData["userName"] as! String)
                self.userLocation.text = (docData["userLocation"] as! String)
                self.favObjField.text = " " + (docData["favoriteObject"] as! String)
                self.userBio.text = (docData["userBio"] as! String)
                self.layOutSMIcons()
                self.websiteButton.isHidden = false
                self.instaButton.isHidden = false
                self.youtubeButton.isHidden = false
                self.fbButton.isHidden = false
                let eqData = docData["userEquipment"] as! Dictionary<String, [String]>
                for (i, field) in self.eqFields.enumerated() {
                    if i / 3 == 0 {
                        if i < eqData["telescopes"]!.count {
                            field.text = eqData["telescopes"]![i]
                        } else {
                            field.text = ""
                        }
                    } else if i / 3 == 1 {
                        if i - 3 < eqData["mounts"]!.count {
                            field.text = eqData["mounts"]![i - 3]
                        } else {
                           field.text = ""
                       }
                    } else {
                        if i - 6 < eqData["cameras"]!.count {
                            field.text = eqData["cameras"]![i - 6]
                        } else {
                           field.text = ""
                       }
                    }
                }
                self.statsHours.text = String(docData["totalHours"] as! Int)
                var numfeatures = 0
                for (date, _) in (docData["userDataCopyKeys"] as! [String: String]) {
                    if isEarlierDate(date, dateToday) {
                        numfeatures += 1
                    }
                }
                self.statsFeatured.text = String(numfeatures)
                self.statsSeen.text = String((docData["obsTargetNum"] as! Dictionary<String, Int>).count)
                self.statsPhoto.text = String((docData["photoTargetNum"] as! Dictionary<String, Int>).count)
                self.userData = docData
            }
        })
        if keyForDifferentProfile != "" {return}
        db.collection("userData").document(userKey).addSnapshotListener (includeMetadataChanges: true, listener: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                if (snapshot?.metadata.isFromCache)! {
                    print("using cached data")
                }
                if self.userData != nil {
                    let data = snapshot!.data()!
                    self.userData = data
                    let hours = data["totalHours"] as! Int
                    let copyKeys = data["userDataCopyKeys"] as! [String: String]
                    let obs = data["obsTargetNum"] as! [String: Int]
                    let photo = data["photoTargetNum"] as! [String: Int]
                    self.statsHours.text = String(hours)
                    var numfeatures = 0
                    for (date, _) in copyKeys {
                        if isEarlierDate(date, dateToday) {
                            numfeatures += 1
                        }
                    }
                    self.statsFeatured.text = String(numfeatures)
                    self.statsSeen.text = String(obs.count)
                    self.statsPhoto.text = String(photo.count)
                    self.pevc?.userData = data
                }
            }
        })
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if profileChanged {
            userImage.image = newImage
            newImage = nil
            userName.text = (userData["userName"] as! String)
            userLocation.text = (userData["userLocation"] as! String)
            favObjField.text = " " + (userData["favoriteObject"] as! String)
            userBio.text = (userData["userBio"] as! String)
            layOutSMIcons()
            let eqData = userData["userEquipment"] as! Dictionary<String, [String]>
            eqFields = [userTelescope, userTelescope2, userTelescope3, userMount, userMount2, userMount3, userCamera, userCamera2, userCamera3]
            for (i, field) in eqFields.enumerated() {
                if i / 3 == 0 {
                    if i < eqData["telescopes"]!.count {
                        field.text = eqData["telescopes"]![i]
                    } else {
                        field.text = ""
                    }
                } else if i / 3 == 1 {
                    if i - 3 < eqData["mounts"]!.count {
                        field.text = eqData["mounts"]![i - 3]
                    } else {
                       field.text = ""
                   }
                } else {
                    if i - 6 < eqData["cameras"]!.count {
                        field.text = eqData["cameras"]![i - 6]
                    } else {
                       field.text = ""
                   }
                }
            }
            profileChanged = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if screenH < 600 {//iphone SE, 5s
            circleTrailingC.constant = 5
            circleLeadingC.constant = 5
            circleBottomC.constant = 30
        }
        else if screenH > 1100  && screenH < 1150 {//ipad 10.5
            circleTopCipad.constant = 60
            circleBottomCipad.constant = 60
        }
    }
    @objc func willEnterForeground() {
        layOutSMIcons()
    }
    @IBAction func imageTapped(_ sender: Any) {
        if (userData["profileImageKey"] as! String != "") {
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
            self.addChild(popOverVC)
            popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            self.view.addSubview(popOverVC.view)
            popOverVC.imageView.image = userImage.image
            popOverVC.didMove(toParent: self)
        }
    }
    @IBAction func websiteTapped(_ sender: Any) {
        let webURL = NSURL(string: "https://www." + (userData["websiteName"] as! String))!
        application.open(webURL as URL)
    }
    @IBAction func instaTapped(_ sender: Any) {
        let instaUsername = userData["instaUsername"] as! String
        let appURL = NSURL(string: "instagram://www.instagram.com/" + instaUsername +  "/?hl=en")!
        let webURL = NSURL(string: "https://www.instagram.com/" + instaUsername + "?hl=en")!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    @IBAction func youtubeTapped(_ sender: Any) {
        let youtubeChannel = userData["youtubeChannel"] as! String
        let appURL = NSURL(string: "youtube://www.youtube.com/" + youtubeChannel)!
        let webURL = NSURL(string: "https://www.youtube.com/" + youtubeChannel)!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    @IBAction func fbTapped(_ sender: Any) {
        let fbPage = userData["fbPage"] as! String
        let appURL = NSURL(string: "facebook://www.facebook.com/" + fbPage)!
        let webURL = NSURL(string: "https://www.facebook.com/" + fbPage)!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    @IBAction func logOutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ProfileEditViewController
        if vc != nil {
            vc?.userKey = userKey
            vc?.userData = userData
            if userImage.image == UIImage(named: "Profile/placeholderProfileImage") {
                vc?.image = nil
            } else {
                vc?.image = userImage.image
            }
            vc?.pvc = self
            pevc = vc
        }
    }
}

