//
//  FirstViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SwiftKeychainWrapper

extension Bool {
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
}

infix operator £
//returns true if time1 is earlier than time2
func £(comment1: Dictionary<String, String>, comment2: Dictionary<String, String>) -> Bool {
    let time1 = String(comment1["userKey"]!.suffix(11))
    let time2 = String(comment2["userKey"]!.suffix(11))
    print(time1)
    print(time2)
    let d1 = Int(time1.prefix(2))!
    let d2 = Int(time2.prefix(2))!
    if d1 != d2 {
        return (abs(d1 - d2) > 1) ^ (d1 < d2)
    }
    let h1 = Int(time1.suffix(8).prefix(2))!
    let h2 = Int(time2.suffix(8).prefix(2))!
    if h1 != h2 {
        return (h1 < h2)
    }
    let m1 = Int(time1.suffix(5).prefix(2))!
    let m2 = Int(time2.suffix(5).prefix(2))!
    if m1 != m2 {
        return (m1 < m2)
    }
    let s1 = Int(time1.suffix(2))!
    let s2 = Int(time2.suffix(2))!
    if s1 != s2 {
        return (s1 < s2)
    }
    return true
}

class ImageOfDayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIScrollViewDelegate {
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var background: UIImageView!
//    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var targetField: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var locationField: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numLikes: UIButton!
    @IBOutlet weak var numComments: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var secondCommentIcon: UIImageView!
    @IBOutlet weak var commentInputTextView: UITextView!
    @IBOutlet weak var commentSendButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var bioField: UITextView!
    @IBOutlet weak var telescopeField: UILabel!
    @IBOutlet weak var mountField: UILabel!
    @IBOutlet weak var cameraField: UILabel!
    @IBOutlet weak var statsHoursLabel: UITextView!
    @IBOutlet weak var statsFeaturedLabel: UITextView!
    @IBOutlet weak var statsSeenLabel: UITextView!
    @IBOutlet weak var statsPhotoLabel: UITextView!
    @IBOutlet weak var statsHours: UILabel!
    @IBOutlet weak var statsFeatured: UILabel!
    @IBOutlet weak var statsPhoto: UILabel!
    @IBOutlet weak var statsSeen: UILabel!
    @IBOutlet weak var contentViewHC: NSLayoutConstraint!
    @IBOutlet weak var contentViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var locationFieldWC: NSLayoutConstraint!
    @IBOutlet weak var locationFieldWCipad: NSLayoutConstraint!
    @IBOutlet weak var commentInputHC: NSLayoutConstraint!
    @IBOutlet weak var imageViewWC: NSLayoutConstraint!
    @IBOutlet weak var imageViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var userImageLeadingCipad: NSLayoutConstraint!
    @IBOutlet weak var bioTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var websiteLeadingC: NSLayoutConstraint!
    @IBOutlet weak var websiteLeadingCipad: NSLayoutConstraint!
    @IBOutlet weak var websiteWC: NSLayoutConstraint!
    @IBOutlet weak var instaWC: NSLayoutConstraint!
    @IBOutlet weak var youtubeWC: NSLayoutConstraint!
    @IBOutlet weak var fbWC: NSLayoutConstraint!
    @IBOutlet weak var websiteWCipad: NSLayoutConstraint!
    @IBOutlet weak var instaWCipad: NSLayoutConstraint!
    @IBOutlet weak var youtubeWCipad: NSLayoutConstraint!
    @IBOutlet weak var fbWCipad: NSLayoutConstraint!
    @IBOutlet weak var statsLabelLeadingCipad: NSLayoutConstraint!
    @IBOutlet weak var mountFieldWC: NSLayoutConstraint!
    @IBOutlet weak var circle1TrailingC: NSLayoutConstraint!
    @IBOutlet weak var circle2LeadingC: NSLayoutConstraint!
    @IBOutlet weak var hoursLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var objPhotoLabelBottomC: NSLayoutConstraint!
    var imageData: UIImage? = nil
    var entryKey = ""
    var entryInd = 0
    var entryData: Dictionary<String, Any>? = nil
    var iodUserKey = ""
    var userData: Dictionary<String, Any>? = nil
    var featuredDate = ""
    var likesList: [String] = []
    var commentsList: [Dictionary<String, String>] = []
    var basicUserDataDict: Dictionary<String, Dictionary<String, Any>> = Dictionary()
    var currentUserKey: String = ""
    var imageLiked = false
    var keyForDifferentProfile = ""
    var iodEntryListener: ListenerRegistration? = nil
    var iodUserListener: ListenerRegistration? = nil
    var likesListener: ListenerRegistration? = nil
    var likesListenerInitiated = false
    var commentsListener: ListenerRegistration? = nil
    var commentsListenerInitiated = false
    let format = DateFormatter()
    var notEditable = false
    var sentEvenNumComments = true
    var locationWidthDefault = CGFloat(0)
    var commentTextViewHeightDefault = 36
    var commentInputHeightMax = CGFloat(117)
    var commentsTableViewWidth = CGFloat(0)
    var commentInputHeightDefault = CGFloat(0)
    var commentFontName = "Helvetica Neue"
    var commentFontSize = 14
    var commentFontAttributes: [NSAttributedString.Key : Any]? = nil
    var keyBoardH = CGFloat(0.0)
    let application = UIApplication.shared
    var cvc: CalendarViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        if keyBoardH < 1 {
            keyBoardH = keyboardRectangle.height
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        likeButton.isUserInteractionEnabled = false
        commentSendButton.isUserInteractionEnabled = false
        imageView.layer.borderColor = UIColor.orange.cgColor
        imageView.layer.borderWidth = 1.5
        bioField.layer.borderColor = UIColor.gray.cgColor
        bioField.layer.borderWidth = 1
        commentsTableView.layer.borderColor = UIColor.gray.cgColor
        commentsTableView.layer.borderWidth = 2
        commentInputTextView.layer.borderColor = UIColor.gray.cgColor
        commentInputTextView.layer.borderWidth = 1
        commentInputTextView.delegate = (self as UITextViewDelegate)
        commentInputTextView.autocorrectionType = .yes
        scrollView.delegate = (self as UIScrollViewDelegate)
        format.timeZone = TimeZone(abbreviation: "PDT")!
        format.dateFormat = "dd-HH:mm:ss"
        if notEditable {
            likeButton.isUserInteractionEnabled = true
            secondCommentIcon.isHidden = true
            commentInputTextView.isHidden = true
            commentSendButton.isHidden = true
        }
        if screenH < 1000 {
            locationWidthDefault = locationFieldWC.constant
        } else {
            locationWidthDefault = locationFieldWCipad.constant
            targetField.font = UIFont(name: targetField.font!.fontName, size: 45)
            if screenH > 1150 {
                userImageLeadingCipad.constant = screenW * 0.11
                bioTrailingCipad.constant = screenW * 0.11
                statsLabelLeadingCipad.constant = screenW * 0.16
            }
        }
        commentsTableViewWidth = commentsTableView.bounds.width
        
        imageView.image = imageData
        let iodEntryRef = db.collection("journalEntries").document(entryKey)
        iodEntryListener = iodEntryRef.addSnapshotListener(includeMetadataChanges: true, listener: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                if (snapshot?.metadata.isFromCache)! {
                    return
                }
                if snapshot?.data() == nil {
                    return
                }
                let data = (snapshot?.data()!["data"] as! [[String: Any]])[self.entryInd]
                self.entryData = data
                var target = (data["formattedTarget"] as! String)
                if target.count > 1 && target.prefix(1) == "M" && MessierConst[Int(String(target.suffix(target.count - 1))) ?? -1] != nil {
                    target = "Messier " + String(target.suffix(target.count - 1))
                } else if target.count > 3 && target.prefix(3) == "NGC" && NGCConst[Int(String(target.suffix(target.count - 3))) ?? -1] != nil {
                    target = "NGC " + String(target.suffix(target.count - 3))
                } else if target.count > 2 && target.prefix(2) == "IC" && ICConst[Int(String(target.suffix(target.count - 2))) ?? -1] != nil {
                    target = "IC " + String(target.suffix(target.count - 2))
                }
                self.targetField.text = target
                let entryDate = String(self.entryKey.suffix(8))
                self.dateField.text = monthNames[Int(entryDate.prefix(2))! - 1] + " " + String(Int(entryDate.prefix(4).suffix(2))!) + " " + String(entryDate.suffix(4))
                self.locationField.text = (data["locations"] as! [String]).joined(separator: ", ")
                var font = UIFont(name: self.locationField.font.fontName, size: self.locationField.font.pointSize)
                var fontAttributes = [NSAttributedString.Key.font: font]
                var size = (self.locationField.text! as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
                if size.width < self.locationWidthDefault {
                    self.locationFieldWC.constant = size.width + 10
                    self.locationFieldWCipad.constant = size.width + 10
                } else {
                    self.locationFieldWC.constant = self.locationWidthDefault
                    self.locationFieldWCipad.constant = self.locationWidthDefault
                }
                if self.locationField.text! == "" {
                    self.locationIcon.isHidden = true
                }
                self.telescopeField.text = (data["telescope"] as! String)
                self.cameraField.text = (data["camera"] as! String)
                self.mountField.text = (data["mount"] as! String)
            }
        })
        
        let iodUserRef = db.collection("userData").document(iodUserKey)
        iodUserListener = iodUserRef.addSnapshotListener(includeMetadataChanges: true, listener: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                if (snapshot?.metadata.isFromCache)! {
                    return
                }
                let oldUserImageKey = self.userData?["profileImageKey"] as? String
                if snapshot!.data() == nil {
                    return
                }
                let data = snapshot!.data()!
                self.userData = data
                self.nameField.text = (data["userName"] as! String)
                let font = UIFont(name: self.nameField.font.fontName, size: self.nameField.font.pointSize)
                let fontAttributes = [NSAttributedString.Key.font: font]
                let size = (self.nameField.text! as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
                self.bioField.text = (data["userBio"] as! String)
                let imageKey = (data["profileImageKey"] as! String)
                if imageKey != oldUserImageKey {
                    if imageKey == "" {
                        self.userImage.image = UIImage(named: "ImageOfTheDay/placeholderProfileImage")!
                    } else {
                        let imageRef = storage.child(imageKey)
                        imageRef.getData(maxSize: 1024 * 1024 * 3) {imageData, Error in
                            if let Error = Error {
                                print(Error)
                                return
                            } else {
                                self.userImage.image = UIImage(data: imageData!)!
                            }
                        }
                    }
                }
                if data["websiteName"] as! String == "" {
                    self.websiteWC.constant = 0
                    self.websiteWCipad.constant = 0
                    self.websiteLeadingC.constant = -10
                    self.websiteLeadingCipad.constant = -15
                } else {
                    self.websiteWC.constant = 21
                    self.websiteWCipad.constant = 31
                    self.websiteLeadingC.constant = 0
                    self.websiteLeadingCipad.constant = 0
                }
                if data["instaUsername"] as! String == "" {
                    self.instaWC.constant = 0
                    self.instaWCipad.constant = 0
                } else {
                    self.instaWC.constant = 21
                    self.instaWCipad.constant = 31
                }
                if data["youtubeChannel"] as! String == "" {
                    self.youtubeWC.constant = 0
                    self.youtubeWCipad.constant = 0
                } else {
                    self.youtubeWC.constant = 21
                    self.youtubeWCipad.constant = 31
                }
                if data["fbPage"] as! String == "" {
                    self.fbWC.constant = 0
                    self.fbWCipad.constant = 0
                } else {
                    self.fbWC.constant = 21
                    self.fbWCipad.constant = 31
                }
                self.statsHours.text = String(data["totalHours"] as! Int)
                var numfeatures = 0
                for (date, _) in (data["userDataCopyKeys"] as! [String: String]) {
                    if isEarlierDate(date1: date, date2: dateToday) {
                        numfeatures += 1
                    }
                }
                self.statsFeatured.text = String(numfeatures)
                self.statsSeen.text = String((data["obsTargetNum"] as! Dictionary<String, Int>).count)
                self.statsPhoto.text = String((data["photoTargetNum"] as! Dictionary<String, Int>).count)
            }
        })
        
        func setUserInfo(key: String, name: String, img: UIImage) {
            basicUserDataDict[key]!["userImage"] = img
            if commentsList.count > 0 {
                for i in 0...commentsList.count - 1 {
                    if commentsList[i]["userKey"] == key {
                        let cell = commentsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? CommentsTableViewCell
                        //currently displayed on screen
                        if cell != nil {
                            cell!.userNameLabel.text = name
                            cell!.userImageView.image = img
                        }
                    }
                }
            }
        }
        //username and profile image for user using the app
        currentUserKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        let currentUserName = KeychainWrapper.standard.string(forKey: "userName")!
        basicUserDataDict[currentUserKey] = ["userName": currentUserName]
        let docRef = db.collection("basicUserData").document(currentUserKey)
        docRef.getDocument(completion: {(QuerySnapshot, Error) in
            if Error == nil {
                let imageKey = QuerySnapshot!.data()!["compressedProfileImageKey"] as! String
                if imageKey == "" {
                    setUserInfo(key: self.currentUserKey, name: currentUserName, img: UIImage(named: "ImageOfTheDay/placeholderProfileImage")!)
                } else {
                    let imageRef = storage.child(imageKey)
                    imageRef.getData(maxSize: 1024 * 1024 * 3) {imageData, Error in
                        if Error == nil {
                            setUserInfo(key: self.currentUserKey, name: currentUserName, img: UIImage(data: imageData!)!)
                        }
                    }
                }
            }
        })
        likesListener = db.collection("imageOfDayLikes").document(self.featuredDate).addSnapshotListener (includeMetadataChanges: true, listener: {(snapshot, error) in
            if error != nil {
                print("Error fetching updated likes document: \(error!)")
                return
            } else {
                if (snapshot?.metadata.isFromCache)! {
                    return
                }
                self.likesList = []
                let likesData = snapshot!.data()! as! [String: String]
                for (userKey, _) in likesData {
                    self.likesList.append(userKey)
                    if userKey == self.currentUserKey {
                        self.imageLiked = true
                        self.likeButton.setImage(UIImage(named: "ImageOfTheDay/heartFilled"), for: .normal)
                    }
                }
                if self.likesList.count == 0 {
                    self.numLikes.setTitle(" ", for: .normal)
                } else {
                    self.numLikes.setTitle(String(self.likesList.count), for: .normal)
                }
                if !self.likesListenerInitiated {
                    self.likeButton.isUserInteractionEnabled = true
                    self.likesListenerInitiated = true
                }
            }
        })
        let font = UIFont(name: commentFontName, size: CGFloat(commentFontSize))
        commentFontAttributes = [NSAttributedString.Key.font: font as Any]
        func processCommentsData(commentsData: [String: String]) {
            let basicUserDataCollection = db.collection("basicUserData")
            for (userKeyTime, comment) in commentsData {
                let userKey = String(userKeyTime.prefix(userKeyTime.count - 11))
                if self.basicUserDataDict[userKey] == nil {
                    self.basicUserDataDict[userKey] = [:]
                    basicUserDataCollection.document(userKey).getDocument(completion: {(QuerySnapshot, Error) in
                        if Error == nil {
                            let userName = QuerySnapshot!.data()!["userName"] as! String
                            self.basicUserDataDict[userKey]!["userName"] = userName
                            let imageKey = QuerySnapshot!.data()!["compressedProfileImageKey"] as! String
                            if imageKey == "" {
                                setUserInfo(key:userKey, name: userName, img: UIImage(named: "ImageOfTheDay/placeholderProfileImage")!)
                            } else {
                                storage.child(imageKey).getData(maxSize: 1024 * 1024 * 3) {imageData, Error in
                                    if Error == nil {
                                        setUserInfo(key:userKey, name: userName, img: UIImage(data: imageData!)!)
                                    }
                                }
                            }
                        }
                    })
                }
                self.commentsList.append(["userKey": userKeyTime, "comment": comment])
            }
            self.commentsList = self.commentsList.sorted(by: £)
            if self.commentsList.count > 0 {
                for i in 0...self.commentsList.count - 1 {
                    let userKeyTime = self.commentsList[i]["userKey"]!
                    self.commentsList[i]["userKey"] = String(userKeyTime.prefix(userKeyTime.count - 11))
                    self.commentsList[i]["timeStamp"] = String(userKeyTime.suffix(11))
                }
                self.numComments.text = String(self.commentsList.count)
                self.numComments.isHidden = false
            } else {
                self.numComments.isHidden = true
            }
            self.commentsTableView.reloadData()
            commentSendButton.isUserInteractionEnabled = true
        }
        let commentsRef = db.collection("imageOfDayComments").document(self.featuredDate)
        commentsRef.getDocument() { (snapshot, err) in
            if let err = err {
                print("Error gfetting comments: \(err)")
            } else {
                processCommentsData(commentsData: snapshot!.data() as! [String: String])
            }
        }
        commentsListener = commentsRef.addSnapshotListener (includeMetadataChanges: true, listener: {(snapshot, error) in
            if error != nil {
                print("Error fetching updated comment document: \(error!)")
                return
            } else {
                if (snapshot?.metadata.isFromCache)! {
                    return
                }
                if self.commentsListenerInitiated {
                    let oldCommentsList = self.commentsList
                    self.commentsList = []
                    processCommentsData(commentsData: snapshot!.data() as! [String: String])
                    let commentsListCount = self.commentsList.count
                    if commentsListCount > 0 && commentsListCount > oldCommentsList.count {
                        self.commentsTableView.scrollToRow(at: IndexPath(row: commentsListCount - 1, section: 0), at: .bottom, animated: true)
                    }
                } else {
                    self.commentsListenerInitiated = true
                }
            }
        })
        imageView.isHidden = true
        endNoInput()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if screenH < 600 {//iphone SE, 5s
            imageViewWC.constant = 300
            mountFieldWC.constant = 98
            circle1TrailingC.constant = 5
            circle2LeadingC.constant = 5
            statsHoursLabel.font = UIFont(name: "Pacifica Condensed", size: 14)
            statsHoursLabel.textAlignment = .right
            statsFeaturedLabel.font = UIFont(name: "Pacifica Condensed", size: 14)
            statsSeenLabel.font = UIFont(name: "Pacifica Condensed", size: 14)
            statsSeenLabel.textAlignment = .right
            statsPhotoLabel.font = UIFont(name: "Pacifica Condensed", size: 14)
        }
        else if screenH < 670 {//iphone 8 or smaller
            contentViewHC.constant = 1370
            hoursLabelTopC.constant = 20
            objPhotoLabelBottomC.constant = 17
        } else if screenH > 850 && screenH < 900 {//iphone 11 pro max
            objPhotoLabelBottomC.constant = 90
        }
        if screenH > 1000 {//ipads
            background.image = UIImage(named: "ViewEntry/background-ipad")
//            border.image = UIImage(named: "border-ipad")
            let scale = imageView.bounds.width * 0.6
            imageViewHCipad.constant = scale
            contentViewHCipad.constant = 1450 + scale
        }
        commentInputHeightDefault = commentInputHC.constant
        imageView.isHidden = false
        keyForDifferentProfile = ""
    }
    func getNumLines(str: String, fontAttr: [NSAttributedString.Key : Any], containerW: CGFloat) -> Int {
        var strCopy = str
        var size = "".size(withAttributes: (commentFontAttributes!))
        var numLines = 0
        var i = 0
        for c in str {
            if c == "\n" {
                if i == 0 {
                    numLines += 1
                } else {
                    size = String(strCopy.prefix(i)).size(withAttributes: (commentFontAttributes!))
                    numLines += Int(ceil(size.width / containerW))
                }
                strCopy = String(str.suffix(strCopy.count - i - 1))
                i = 0
            } else {
                i += 1
            }
        }
        numLines += 1
        if numLines == 1 {
            size = str.size(withAttributes: (commentFontAttributes!))
            numLines = Int(ceil(size.width / containerW))
        }
        return numLines
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell", for: indexPath) as! CommentsTableViewCell
        cell.selectionStyle = .none
        let userKey = (commentsList[indexPath.row]["userKey"]!)
        cell.userImageView.image = (basicUserDataDict[userKey]?["userImage"] as? UIImage)
        let cellLayer = cell.userImageView.layer
        cellLayer.borderWidth = 1.5
        cellLayer.borderColor = UIColor.orange.cgColor
        cellLayer.masksToBounds = true
        cellLayer.cornerRadius = cell.userImageView.bounds.width / 2
        cell.userNameLabel.text = (basicUserDataDict[userKey]?["userName"] as? String)
        cell.commentTextView.text = (commentsList[indexPath.row]["comment"]!)
        cell.commentTextViewHC.constant = CGFloat(commentTextViewHeightDefault / 2 * (Int(commentsList[indexPath.row]["numLines"]!)! + 1))
        if commentsList[indexPath.row]["userKey"] == currentUserKey && cell.viewWithTag(2) == nil {
            let deleteCommentLabel = UILabel(frame: CGRect(x: Int(cell.bounds.width) - 50, y: 6, width: 70, height: 20))
            deleteCommentLabel.text = "Delete"
            deleteCommentLabel.textColor = UIColor.init(red: 0.9, green: 0, blue: 0, alpha: 1)
            deleteCommentLabel.font = UIFont(name: "Helvetica Neue", size: 13)
            deleteCommentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteCommentTapped)))
            deleteCommentLabel.isUserInteractionEnabled = true
            deleteCommentLabel.tag = 2
            cell.addSubview(deleteCommentLabel)
        } else if commentsList[indexPath.row]["userKey"] != currentUserKey {
            cell.viewWithTag(2)?.removeFromSuperview()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let comment = commentsList[indexPath.row]["comment"]! + "kk" //kk to account for padding
        let numLines = getNumLines(str: comment, fontAttr: commentFontAttributes!, containerW: commentsTableViewWidth)
        if commentsList[indexPath.row]["numLines"] == nil {
            commentsList[indexPath.row]["numLines"] = String(numLines)
        }
        return CGFloat(commentTextViewHeightDefault / 2 * (numLines + 3))
    }
    @IBAction func imageTapped(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
        self.addChild(popOverVC)
        let f = self.view.frame
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: f.width, height: f.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.imageView.image = imageView.image
        popOverVC.didMove(toParent: self)
    }
    @IBAction func likeButtonTapped(_ sender: Any) {
        if !imageLiked {
            likeButton.setImage(UIImage(named: "ImageOfTheDay/heartFilled"), for: .normal)
            likesList.append(currentUserKey)
            db.collection("imageOfDayLikes").document(self.featuredDate).setData([currentUserKey: ""], merge: true)
        } else {
            likeButton.setImage(UIImage(named: "ImageOfTheDay/heartUnfilled"), for: .normal)
            likesList.remove(at: likesList.index(of: currentUserKey)!)
            db.collection("imageOfDayLikes").document(self.featuredDate).updateData([currentUserKey: FieldValue.delete()])
        }
        imageLiked = !imageLiked
        let likeCount = likesList.count
        if likeCount == 0 {
            numLikes.setTitle(" ", for: .normal)
        } else {
            numLikes.setTitle(String(likeCount), for: .normal)
        }
    }
    @IBAction func numLikesTapped(_ sender: Any) {
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ProfileViewController
        if vc != nil {
            vc!.keyForDifferentProfile = keyForDifferentProfile
        }
    }
    @IBAction func commentsTableViewUserProfileTapped(_ sender: UITapGestureRecognizer) {
        let indexPath = commentsTableView.indexPathForRow(at: sender.location(in: commentsTableView))
        if indexPath == nil {
            return
        }
        let i = indexPath!.row
        keyForDifferentProfile = commentsList[i]["userKey"]!
        performSegue(withIdentifier: "imageOfDayToProfile", sender: self)
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = toolbar
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: commentInputTextView.frame.origin.y - scrollView.bounds.height + keyBoardH + commentInputHeightMax - 30), animated: true)
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.text! == "" {
            commentInputHC.constant = commentInputHeightDefault
        } else {
            let numLines = getNumLines(str: textView.text!, fontAttr: commentFontAttributes!, containerW: commentInputTextView.bounds.width)
            var newH = commentInputHeightDefault / 2 * CGFloat((numLines + 1))
            if newH > commentInputHeightMax {
               newH = commentInputHeightMax
            }
            commentInputHC.constant = newH
        }
    }
    @IBAction func toolBarItemTapped(_ sender: Any) {
        commentInputTextView.endEditing(true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        commentInputTextView.resignFirstResponder()
    }
    @IBAction func commentSendButtonTapped(_ sender: Any) {
        let inp = commentInputTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var onlyWhiteSpace = true
        for c in inp {
            if c != " " && c != "\t" && c != "\n" {
                onlyWhiteSpace = false
                break
            }
        }
        if onlyWhiteSpace {
            return
        }
        commentInputTextView.resignFirstResponder()
        if sentEvenNumComments {//make button flicker
            commentSendButton.setTitle("send", for: .normal)
        } else {
            commentSendButton.setTitle("Send", for: .normal)
        }
        sentEvenNumComments = !sentEvenNumComments
        commentInputTextView.text = ""
        commentInputHC.constant = commentInputHeightDefault
        let timeStamp = format.string(from: Date())
        commentsList.append(["userKey": currentUserKey, "comment": inp, "timeStamp": timeStamp])
        let listCount = commentsList.count
        commentsTableView.insertRows(at: [IndexPath.init(row: listCount - 1, section: 0)], with: .automatic)
        commentsTableView.scrollToRow(at: IndexPath(row: listCount - 1, section: 0), at: .bottom, animated: true)
        db.collection("imageOfDayComments").document(self.featuredDate).setData([currentUserKey + timeStamp: inp], merge: true)
        numComments.text = String(listCount)
        numComments.isHidden = false
    }
    @objc func deleteCommentTapped(_ sender: UIGestureRecognizer) {
        let indexPath = commentsTableView.indexPathForRow(at: sender.location(in: commentsTableView))
        let i = indexPath!.row
        let commentKey = currentUserKey + commentsList[i]["timeStamp"]!
        commentsList.remove(at: i)
        commentsTableView.deleteRows(at: [indexPath!], with: .fade)
        db.collection("imageOfDayComments").document(self.featuredDate).updateData([commentKey: FieldValue.delete()])
        let listCount = commentsList.count
        numComments.text = String(listCount)
        if listCount == 0 {
            numComments.isHidden = true
        }
    }
    @IBAction func websiteButtonTapped(_ sender: Any) {
        let webURL = NSURL(string: "https://www." + (userData!["websiteName"] as! String))!
        application.open(webURL as URL)
    }
    @IBAction func instaButtonTapped(_ sender: Any) {
        let instaUsername = userData!["instaUsername"] as! String
        let appURL = NSURL(string: "instagram://www.instagram.com/" + instaUsername +  "/?hl=en")!
        let webURL = NSURL(string: "https://www.instagram.com/" + instaUsername + "?hl=en")!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    @IBAction func youtubeButtonTapped(_ sender: Any) {
        let youtubeChannel = userData!["youtubeChannel"] as! String
        let appURL = NSURL(string: "youtube://www.youtube.com/" + youtubeChannel)!
        let webURL = NSURL(string: "https://www.youtube.com/" + youtubeChannel)!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    @IBAction func fbButtonTapped(_ sender: Any) {
        let fbPage = userData!["fbPage"] as! String
        let appURL = NSURL(string: "facebook://www.facebook.com/" + fbPage)!
        let webURL = NSURL(string: "https://www.facebook.com/" + fbPage)!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    override func willMove(toParent parent: UIViewController?) {
        if likesListenerInitiated {
            likesListener!.remove()
            commentsListener!.remove()
            iodUserListener!.remove()
            iodEntryListener!.remove()
        }
    }
}

