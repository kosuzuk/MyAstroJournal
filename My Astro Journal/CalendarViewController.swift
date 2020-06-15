//
//  FirstViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftKeychainWrapper
import DropDown
import CoreMotion
import StoreKit

extension UINavigationController {
   open override var preferredStatusBarStyle: UIStatusBarStyle {
      return topViewController?.preferredStatusBarStyle ?? .default
   }
}
class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var newEntryButton: UIButton!
    @IBOutlet weak var selectDateText: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var showEarlierMonthButton: UIButton!
    @IBOutlet weak var calendarsListView: UITableView!
    @IBOutlet weak var imageOfDayImageView: UIImageView!
    @IBOutlet weak var imageOfDayLight: UIImageView!
    @IBOutlet weak var imageOfDayMainLabel: UILabel!
    @IBOutlet weak var imageOfDayLabel: UILabel!
    @IBOutlet weak var antoinePowersButton: UIButton!
    @IBOutlet weak var bannerHC: NSLayoutConstraint!
    @IBOutlet weak var newEntryButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var yearButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var calendarWC: NSLayoutConstraint!
    @IBOutlet weak var calendarHC: NSLayoutConstraint!
    @IBOutlet weak var calendarWCipad: NSLayoutConstraint!
    @IBOutlet weak var calendarHCipad: NSLayoutConstraint!
    @IBOutlet weak var earlierMonthButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayBottomC: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayBottomCipad: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayWC: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayLightWC: NSLayoutConstraint!
    var userData: [String: Any]? = nil
    var userKey: String = ""
    var firstJournalEntryDate = ""
    var startMonth = 0
    var startYear = 0
    var numMonths = 0
    var monthDropDown: DropDown? = nil
    var yearDropDown: DropDown? = nil
    var numCalendarImagesAndPlaceholders = 0
    var imageDict: [String: UIImage] = [:] {
        didSet {
            if imageDict.count == numCalendarImagesAndPlaceholders {
                calendarsListView.reloadData()
                loadingIcon.stopAnimating()
            }
        }
    }
    var numEntriesDict: [String: Int] = [:]
    var userAlertDates: [String] = []
    var entryDropDown: DropDown? = nil
    var userDataInitialized = false
    var imageOfDayListenerInitiated = false
    var imageOfDayKeysData: [String: Any]? = nil
    var imageOfDayImageData: UIImage? = nil
    var imageOfDayTarget = ""
    var noImageOfDay = false
    var newIodUserName = "" {
        didSet {
            if newIodUserName != "" {
                imageOfDayLabel.text = imageOfDayTarget + " by " + newIodUserName + " "
                let font = UIFont(name: self.imageOfDayLabel.font.fontName, size: self.imageOfDayLabel.font.pointSize)
                let fontAttributes = [NSAttributedString.Key.font: font]
                let size = (self.imageOfDayLabel.text! as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
                self.imageOfDayLightWC.constant = size.width + 30
                newIodUserName = ""
            }
        }
    }
    var newEntryMode = false
    var numEarlierMonthsAdded = 0
    var newEntryDate = ""
    var newEntryIndexPathRow = 0
    var preventOfflineOverwrite = true {
        didSet {
            let alertController = UIAlertController(title: "Error", message: "Cannot enter journal for this date while offline.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    var cannotPullEntry = true {
        didSet {
            let alertController = UIAlertController(title: "Error", message: "Cannot currently display this entry while offline.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    var newImage: UIImage? = nil
    var imageChangedDate = ""
    var cardUnlocked = ""
    var entryToShowDate = ""
    var selectedEntryList: [[String: Any]] = []
    var selectedEntryInd = 0
    var formattedTargetsList: [String] = []
    var jevc: JournalEntryViewController? = nil
    var iodvc: ImageOfDayViewController? = nil
    var monthTodayInt = 0
    var yearTodayInt = 0
    var unlockedDate = ""
    var motionManager = CMMotionManager()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func addDropDownData() {
        var curMonth = (monthTodayInt - 1) % 12
        var months: [String] = []
        var curYear = yearTodayInt
        var years: [String] = []
        if curMonth != 11 {
            years.append(String(yearTodayInt))
        }
        startMonth = Int(self.firstJournalEntryDate.prefix(2))!
        startYear = Int(self.firstJournalEntryDate.suffix(4))!
        var numMonthNames = 0
        while !((curMonth < startMonth - 1 && curYear == startYear) || curYear < startYear) {
            if numMonthNames < 12 {
                months.append(monthNames[curMonth])
                numMonthNames += 1
            }
            if curMonth == 11 {
                years.append(String(curYear))
            }
            curMonth -= 1
            if curMonth == -1 {
                curMonth = 11
                curYear -= 1
            }
        }
        self.monthDropDown!.dataSource = months
        self.yearDropDown!.dataSource = years
    }
    func scrollToCalendar() {
        if  self.yearDropDown?.selectedItem == nil {
            self.monthButton.setTitle(self.monthDropDown!.selectedItem!, for: .normal)
            return
        }
        if self.monthDropDown?.selectedItem == nil {
            self.yearButton.setTitle(self.yearDropDown!.selectedItem!, for: .normal)
            return
        }
        let selectedMonth = monthNames.firstIndex(of: self.monthDropDown!.selectedItem!)! + 1
        let selectedYear = Int(self.yearDropDown!.selectedItem!)!
        if (selectedYear == yearTodayInt && selectedMonth > monthTodayInt) || (selectedYear == self.startYear && selectedMonth < self.startMonth) {
            return
        }
        self.monthButton.setTitle(self.monthDropDown!.selectedItem!, for: .normal)
        self.yearButton.setTitle(self.yearDropDown!.selectedItem!, for: .normal)
        var numMonthsScroll = 0
        if monthTodayInt < selectedMonth {
            numMonthsScroll = (12 - (selectedMonth - monthTodayInt)) + (yearTodayInt - selectedYear - 1) * 12
        } else {
            numMonthsScroll = (monthTodayInt - selectedMonth) + (yearTodayInt - selectedYear) * 12
        }
        self.calendarsListView.scrollToRow(at: NSIndexPath(row: numMonthsScroll, section: 0) as IndexPath, at: UITableView.ScrollPosition.top, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(formatLoadingIcon(loadingIcon))
        loadingIcon.startAnimating()
        if (screenH < 670) {//iphone 8, 5s
            earlierMonthButtonTopC.constant = -50
            imageOfDayMainLabel.font = imageOfDayMainLabel.font.withSize(18)
        } else if (screenH == 896) {//iphone 11 pro max
            newEntryButtonTopC.constant = 30
            yearButtonTopC.constant = 30
            imageOfDayBottomC.constant = 15
        }
        else if screenH > 1000 {//ipads
            background.image = UIImage(named: "Calendar/background-ipad")
            border.image = UIImage(named: "border-ipad")
            imageOfDayMainLabel.font = imageOfDayMainLabel.font.withSize(31)
            if (screenH > 1140) {//big ipads
                imageOfDayBottomCipad.constant = 30
            }
        }
        imageOfDayImageView.layer.borderColor = astroOrange
        imageOfDayImageView.layer.borderWidth = 1.0
        monthDropDown = DropDown()
        monthDropDown!.backgroundColor = .darkGray
        monthDropDown!.textColor = .white
        monthDropDown!.textFont = UIFont(name: "Pacifica Condensed", size: 14)!
        monthDropDown!.cellHeight = 34
        monthDropDown!.cornerRadius = 10
        monthDropDown!.anchorView = monthButton
        monthDropDown!.bottomOffset = CGPoint(x: 0, y: 25)
        if screenH > 1000 {
            monthDropDown!.bottomOffset = CGPoint(x: 0, y: 31)
        }
        yearDropDown = DropDown()
        yearDropDown!.backgroundColor = .darkGray
        yearDropDown!.textColor = .white
        yearDropDown!.textFont = UIFont(name: "Pacifica Condensed", size: 14)!
        yearDropDown!.cellHeight = 34
        yearDropDown!.cornerRadius = 10
        yearDropDown!.bottomOffset = CGPoint(x: 0, y: 25)
        if screenH > 1000 {
            yearDropDown!.bottomOffset = CGPoint(x: 0, y: 31)
        }
        yearDropDown!.anchorView = yearButton
        for item in [antoinePowersButton, selectDateText, cancelButton, showEarlierMonthButton, todayButton, monthButton, yearButton, calendarsListView, imageOfDayImageView, imageOfDayLight, imageOfDayMainLabel, imageOfDayLabel] {
            item!.isHidden = true
        }
        imageOfDayImageView.isUserInteractionEnabled = false
        let date = Date()
        let dateComps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        monthTodayInt = dateComps.month!
        yearTodayInt = dateComps.year!
        dateToday = String(format: "%02ld%02ld", monthTodayInt, dateComps.day!) + String(yearTodayInt)
        Timer.scheduledTimer(timeInterval: TimeInterval(60), target: self, selector: #selector(checkDayChange), userInfo: nil,  repeats: true)
        userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        
        Database.database().reference(withPath: ".info/connected").observe(.value, with: { snapshot in
          if snapshot.value as? Bool ?? false {
            print("Connected")
            isConnected = true
          } else {
            print("Not connected")
            isConnected = false
          }
        })
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {_ in
            if !isConnected && self.userData != nil {
                for (date, _) in self.userData!["calendarImages"] as! [String: String] {
                    if self.imageDict[date] == nil {
                        self.imageDict[date] = UIImage(named: "Calendar/placeholder")!
                    }
                }
            }
        }
        
        if userData!["firstJournalEntryDate"] as! String == "" {
            self.monthDropDown!.dataSource = [monthNames[self.monthTodayInt - 1]]
            self.yearDropDown!.dataSource = [String(self.yearTodayInt)]
            self.numMonths = 1
            self.calendarsListView.reloadData()
            loadingIcon.stopAnimating()
        } else {
            self.firstJournalEntryDate = userData!["firstJournalEntryDate"] as! String
            self.startMonth = Int(self.firstJournalEntryDate.prefix(2))!
            self.startYear = Int(self.firstJournalEntryDate.suffix(4))!
            self.numMonths = (self.monthTodayInt - self.startMonth) % 12 + 1
            if self.yearTodayInt - self.startYear > 0 {
                self.numMonths += (self.yearTodayInt - self.startYear) * 12
            }
            self.addDropDownData()
            self.monthDropDown!.selectionAction = {(index: Int, item: String) in
                self.scrollToCalendar()
            }
            self.yearDropDown!.selectionAction = {(index: Int, item: String) in
                self.scrollToCalendar()
            }
            
            let imageKeyDict = userData!["calendarImages"] as! [String : String]
            self.numCalendarImagesAndPlaceholders = imageKeyDict.count
            for (dateString, imageKey) in imageKeyDict {
                if imageKey == "" {
                    self.imageDict[dateString] = UIImage(named: "Calendar/placeholder")!
                    continue
                }
                let imageRef = storage.child(imageKey)
                imageRef.getData(maxSize: imgMaxByte) {data, Error in
                    if let Error = Error {
                        print(Error)
                        self.imageDict[dateString] = UIImage(named: "Calendar/placeholder")!
                    } else {
                        self.imageDict[dateString] = UIImage(data: data!)!
                    }
                }
            }
            self.numEntriesDict = userData!["numEntriesInDate"] as! [String : Int]
            if imageKeyDict.count == 0 {
                loadingIcon.stopAnimating()
                self.numEntriesDict = [:]
            }
        }
        self.yearDropDown!.selectRow(0)
        var alertDates = userData!["featuredAlertDates"] as! [String]
        if alertDates != [] {
            for alertDate in alertDates {
                if isEarlierDate(alertDate, dateToday) {
                    let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CongratsViewController") as! CongratsViewController
                    popOverVC.featuredDate = alertDate
                    popOverVC.cvc = self
                    self.addChild(popOverVC)
                    popOverVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.view.addSubview(popOverVC.view)
                    popOverVC.didMove(toParent: self)
                    alertDates.remove(at: alertDates.index(of: alertDate)!)
                }
            }
            db.collection("userData").document(userKey).updateData(["featuredAlertDates": alertDates])
        }
        self.userAlertDates = alertDates
        if userData!["isMonthlyWinner"] as! Bool {
            let alertController = UIAlertController(title: "Congratulations!", message: "You have been selected as the winner for the Monthly Challenge! An email will be sent to your email address with the prize.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            let imageSize = 27
            let imageView = UIImageView(frame: CGRect(x: 36, y: 13, width: imageSize, height: imageSize))
            imageView.image = UIImage(named: "MonthlyChallenge/trophy")!
            let imageView2 = UIImageView(frame: CGRect(x: 209, y: 13, width: imageSize, height: imageSize))
            imageView2.image = UIImage(named: "MonthlyChallenge/trophy")!
            alertController.view.addSubview(imageView)
            alertController.view.addSubview(imageView2)
            self.present(alertController, animated: true, completion: nil)
            db.collection("userData").document(userKey).updateData(["isMonthlyWinner": false])
        }
        if (userData!["email"] as! String) == adminEmail || (userData!["email"] as! String) == "therealkoso@gmail.com" {
            isAdmin = true
        }
        if isAdmin {
            self.antoinePowersButton.isHidden = false
            db.collection("iodDeletedNotifications").addSnapshotListener(includeMetadataChanges: true, listener: {(snapshot, Error) in
                if Error != nil {
                    return
                }
                if (snapshot?.metadata.isFromCache)! && isConnected {
                    return
                }
                var deletedStr = ""
                for doc in snapshot!.documents {
                    deletedStr += doc.documentID + ": " + String(doc.data()["target"] as! String) + "\n"
                    db.collection("iodDeletedNotifications").document(doc.documentID).delete()
                }
                if deletedStr != "" {
                    let alertController = UIAlertController(title: "Notification", message: "These chosen entries were deleted by the user:\n\n" + deletedStr, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        db.collection("userData").document(userKey).addSnapshotListener (includeMetadataChanges: true, listener: {(QuerySnapshot, error) in
            if error != nil {
                return
            }
            if (QuerySnapshot?.metadata.isFromCache)! && isConnected {
                return
            }
            if !self.userDataInitialized {
                self.userDataInitialized = true
            } else {
                self.userData = QuerySnapshot!.data()!
            }
        })
        db.collection("imageOfDayKeys").addSnapshotListener(includeMetadataChanges: true, listener: {(snapshot, Error) in
            self.imageOfDayImageView.isUserInteractionEnabled = false
            if Error != nil {
                return
            }
            if (snapshot?.metadata.isFromCache)! {
                return
            }
            self.noImageOfDay = false
            let iodDocs = snapshot!.documents
            //if dropdown is displayed for entry that was just modified in the db, hide it
            func checkDropDown() {
                for i in 0..<self.selectedEntryList.count {
                    let entryFeaturedDate = self.selectedEntryList[i]["featuredDate"] as! String
                    //entry was just picked as iod for today or future
                    if entryFeaturedDate == "" {
                        for j in 0..<iodDocs.count {
                            if iodDocs[j].data()["journalEntryListKey"] as? String == self.userKey +
                                self.entryToShowDate && iodDocs[j].data()["journalEntryInd"] as? Int == i {
                                self.entryDropDown?.hide()
                                let iodDate = iodDocs[j].documentID
                                if isEarlierDate(iodDate, dateToday) {
                                    self.jevc?.navigationController?.popToRootViewController(animated: true)
                                } else {
                                    self.jevc?.featuredDate = iodDate
                                    self.jevc?.jeevc?.featuredDate = iodDate
                                }
                                return
                            }
                        }
                    } else {
                        for j in 0..<iodDocs.count {
                            //different entry was selected
                            if iodDocs[j].documentID == entryFeaturedDate {
                                if iodDocs[j].data()["journalEntryListKey"] as? String != self.userKey + self.entryToShowDate || iodDocs[j].data()["journalEntryInd"] as? Int != i {
                                    self.entryDropDown?.hide()
                                    if isEarlierDate(iodDocs[j].documentID, dateToday) {
                                        self.jevc?.featuredButton.isHidden = true
                                        self.jevc?.jeevc?.photographedCheckBox.isUserInteractionEnabled = true
                                        self.jevc?.jeevc?.bigImageViewRemoveButton.isHidden = false
                                    }
                                    self.jevc?.featuredDate = ""
                                    self.jevc?.jeevc?.featuredDate = ""
                                    return
                                }
                                break
                            }
                            //iod doc for this date was deleted
                            if j == iodDocs.count - 1 {
                                self.entryDropDown?.hide()
                                if isEarlierDate(iodDocs[j].documentID, dateToday) {
                                    self.jevc?.featuredButton.isHidden = true
                                    self.jevc?.jeevc?.photographedCheckBox.isUserInteractionEnabled = true
                                    self.jevc?.jeevc?.bigImageViewRemoveButton.isHidden = false
                                }
                                self.jevc?.featuredDate = ""
                                self.jevc?.jeevc?.featuredDate = ""
                                return
                            }
                        }
                    }
                }
            }
            checkDropDown()
            //if no iod data, make image view blank
            func noIodData() {
                //iod was deleted
                if featuredImageDate != "" {
                    //kick out users from current iod view
                    self.iodvc?.navigationController?.popToRootViewController(animated: true)
                }
                featuredImageDate = ""
                self.imageOfDayImageView.image = UIImage(named: "Calendar/placeholder")
                self.imageOfDayImageView.contentMode = .scaleAspectFit
                self.imageOfDayLight.isHidden = true
                self.imageOfDayListenerInitiated = true
                self.noImageOfDay = true
            }
            //udpdate or initialize iod image view and data
            self.imageOfDayLabel.text = ""
            if iodDocs == [] {
                print("no featured entries")
                noIodData()
                return
            }
            var iodDocToShow = iodDocs[0]
            for doc in iodDocs {
                //the entry date is not in the future and latest entry seen so far not in the future
                if isEarlierDate(doc.documentID, dateToday) && (!isEarlierDate(iodDocToShow.documentID, dateToday) || isEarlierDate(iodDocToShow.documentID, doc.documentID)) {
                    iodDocToShow = doc
                }
            }
            if !isEarlierDate(iodDocToShow.documentID, dateToday) {
                print("there are only featured images for the future")
                noIodData()
                return
            }
            if featuredImageDate != "" && !isEarlierDate(featuredImageDate, iodDocToShow.documentID) {
                print("Antoine has deleted today's iod data")
                noIodData()
                return
            }
            let iodKeysData: [String: Any] = iodDocToShow.data()
            var oldIodImageKey = ""
            if self.imageOfDayKeysData != nil && self.imageOfDayKeysData!.count != 0 {
                oldIodImageKey = String(self.imageOfDayKeysData!["imageKey"] as! String)
            }
            self.imageOfDayKeysData = iodKeysData
            if iodKeysData.count == 0 {
                print("empty iod keys data")
                noIodData()
                return
            }
            let iodImageKey = iodKeysData["imageKey"] as! String
            if iodImageKey == "" {
                print("no image key for featured entry")
                noIodData()
                return
            }
            let imageRef = storage.child(iodImageKey)
            imageRef.getData(maxSize: imgMaxByte) {imageData, Error in
                if let Error = Error {
                    print("no image data for featured entry", Error)
                    noIodData()
                    return
                } else if !self.noImageOfDay {
                    self.imageOfDayImageView.image = UIImage(data: imageData!)!
                    self.imageOfDayImageView.contentMode = .scaleAspectFill
                    self.imageOfDayImageView.clipsToBounds = true
                    self.imageOfDayImageData = self.imageOfDayImageView.image
                    self.imageOfDayImageView.isUserInteractionEnabled = true
                    self.imageOfDayLight.isHidden = false
                }
            }
            let docRef = db.collection("journalEntries").document(iodKeysData["journalEntryListKey"] as! String)
            docRef.getDocument(completion: {(QuerySnapshot, Error) in
                if Error != nil {
                    print(Error!)
                } else {
                    let data = QuerySnapshot!.data()
                    if data == nil {
                        print("no iod entry doc found")
                        noIodData()
                        return
                    }
                    if data!.count == 0 {
                        print("empty iod entry data")
                        noIodData()
                        return
                    }
                    let entryListData = data!["data"] as! [[String: Any]]
                    if entryListData.count <= iodKeysData["journalEntryInd"] as! Int {
                        print("entry list ind for featured entry is out of bounds")
                        noIodData()
                        return
                    }
                    let ind = iodKeysData["journalEntryInd"] as! Int
                    if entryListData[ind]["formattedTarget"] as! String != iodKeysData["formattedTarget"] as! String {
                        print("wrong entry is set for featured entry")
                        noIodData()
                        return
                    }
                    var iodTarget = entryListData[ind]["formattedTarget"] as! String
                    iodTarget = formattedTargetToTargetName(target: iodTarget)
                    self.imageOfDayLabel.text = iodTarget + " by " + (data!["userName"] as! String) + " "
                    let font = UIFont(name: self.imageOfDayLabel.font.fontName, size: self.imageOfDayLabel.font.pointSize)
                    let fontAttributes = [NSAttributedString.Key.font: font]
                    let size = (self.imageOfDayLabel.text! as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
                    self.imageOfDayLightWC.constant = size.width + 30
                    self.imageOfDayTarget = iodTarget
                }
            })
            featuredImageDate = iodDocToShow.documentID
            //iod changed
            if self.imageOfDayListenerInitiated && iodKeysData["imageKey"] as! String != oldIodImageKey {
                //kick out users from current iod view
                self.iodvc?.navigationController?.popToRootViewController(animated: true)
                let iodEntryListKey = iodKeysData["journalEntryListKey"] as! String
                //check if this user was picked for iod while app was on. If so, show congrats alert
                if (iodEntryListKey).prefix(iodEntryListKey.count - 8) == self.userKey {
                    self.entryDropDown?.hide()
                    let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CongratsViewController") as! CongratsViewController
                    popOverVC.featuredDate = iodDocToShow.documentID
                    popOverVC.cvc = self
                    self.addChild(popOverVC)
                    popOverVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.view.addSubview(popOverVC.view)
                    popOverVC.didMove(toParent: self)
                    db.collection("userData").document(self.userKey).updateData(["featuredAlertDates": self.userAlertDates])
                }
            }
            if !self.imageOfDayListenerInitiated {
                self.imageOfDayListenerInitiated = true
            }
        })
        motionManager.gyroUpdateInterval = 0.02
        motionManager.startGyroUpdates(to: OperationQueue.current!) {(data, error) in
            if data != nil {
                self.background.frame.origin.x += CGFloat(data!.rotationRate.y / 4.5)
                self.background.frame.origin.y += CGFloat(data!.rotationRate.x / 4.5)
                if self.background.frame.origin.x < -10 {
                    self.background.frame.origin.x = -10
                }
                if self.background.frame.origin.x > 0 {
                    self.background.frame.origin.x = 0
                }
                if self.background.frame.origin.y < -10 {
                    self.background.frame.origin.y = -10
                }
                if self.background.frame.origin.y > 0 {
                    self.background.frame.origin.y = 0
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        if appDelegate.transactionObserver.incompletePurchaseProductIDs != [] {
            let IDs = appDelegate.transactionObserver.incompletePurchaseProductIDs
            for id in IDs {
                //a pack item
                if packProductIDs.contains(id) {
                    let packImageNames = ["1", "2", "3", "4"]
                    let packNumberToRestore = packImageNames[packProductIDs.index(of: id)!]
                    
                    showUnlockAnimation(imagePath: "AddOns/" + "Packs/" + packNumberToRestore)
                    db.collection("userData").document(userKey).setData(["packsUnlocked": [packNumberToRestore: true]], merge: true)
                }
                //a card back item
                else if cardBackProductIDs.contains(id) {
                    let cardBackImageNames = ["6", "7", "8", "9", "10", "11", "12", "13"]
                    let cardBackNumberToRestore = cardBackImageNames[cardBackProductIDs.index(of: id)!]
                    showUnlockAnimation(imagePath: "AddOns/" + "CardBacks/" + "Backgrounds/" +  cardBackNumberToRestore)
                    db.collection("userData").document(userKey).setData(["cardBacksUnlocked": [cardBackNumberToRestore: true]], merge: true)
                }
            }
            appDelegate.transactionObserver.incompletePurchaseProductIDs = []
        }
        if firstTime {
            let alertController = UIAlertController(title: "Tutorial", message: "This is the Calendar screen where you can add, view, and edit journal entries for any date. Upon entering a target and attaching your image, its card will unlock! Cards can be viewed in the Catalog tab. Try to collect them all!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    @objc func checkDayChange() {
        var day = String(Calendar.current.dateComponents([.day], from: Date()).day!)
        if day.count == 1 {
            day = "0" + day
        }
        if day != dateToday.prefix(4).suffix(2) {
            newEntryButton.isHidden = false
            newEntryMode = false
            showEarlierMonthButton.isHidden = true
            dateToday = ""
            imageOfDayListenerInitiated = false
            featuredImageDate = ""
            viewDidLoad()
            viewDidAppear(true)
        }
    }
    func showUnlockAnimation(imagePath: String) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardUnlockedViewController") as! CardUnlockedViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        if imagePath.prefix(13) == "UnlockedCards" {//showing card
            popOverVC.unlockedDateLabel.text = monthNames[Int(unlockedDate.prefix(2))! - 1] + " " + String(Int(unlockedDate.prefix(4).suffix(2))!) + " " + String(unlockedDate.suffix(4))
        } else {
            popOverVC.unlockedDateLabel.isHidden = true
            if #available(iOS 13.3, *) {
                popOverVC.closeButton.setTitle("", for: .normal)
                popOverVC.closeButton.setImage(UIImage(systemName: "x.circle")!, for: .normal)
            } else {
                popOverVC.closeButton.titleLabel?.font =  UIFont(name: "Helvetica Neue", size: 35)
                popOverVC.closeButton.titleLabel?.textColor = .white
            }
        }
        popOverVC.imageView.image = UIImage(named: imagePath)
        popOverVC.didMove(toParent: self)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (screenH < 600) {//iphone SE, 5s
            bannerHC.constant = 35
            earlierMonthButtonTopC.constant = -38
            imageOfDayMainLabel.text = ""
            imageOfDayWC.constant = 287
        }
        let calendarSize = screenW * 0.9
        calendarWC.constant = calendarSize
        calendarHC.constant = calendarSize
        calendarWCipad.constant = calendarSize
        calendarHCipad.constant = calendarSize * 0.83
    }
    override func viewDidAppear(_ animated: Bool) {
        //check for users with capitals in email
//        db.collection("userData").getDocuments(completion: {(QuerySnapshot, Error) in
//        if Error != nil {
//            print(Error!)
//        } else {
//            let data = QuerySnapshot!.documents
//            for i in data {
//                for j in i["email"] as! String {
//                    let a = j.asciiValue!
//                    if a > 64 && a < 91 {
//                        print(i["email"])
//                        break
//                    }
//                }
//            }
//            }})
        super.viewDidAppear(true)
        jevc = nil
        if imageChangedDate != "" {
            imageDict[imageChangedDate] = newImage
            newImage = nil
            if newEntryIndexPathRow + 1 > numMonths {
                numMonths = newEntryIndexPathRow + 1
                firstJournalEntryDate = imageChangedDate
                addDropDownData()
                monthDropDown!.selectionAction = {(index: Int, item: String) in
                    self.scrollToCalendar()
                }
                yearDropDown!.selectionAction = {(index: Int, item: String) in
                    self.scrollToCalendar()
                }
                newEntryIndexPathRow = 0
            }
            imageChangedDate = ""
        }
        if cardUnlocked != "" {
            let othertarget = doubleTargets[cardUnlocked]
            if othertarget != nil {
                showUnlockAnimation(imagePath: "UnlockedCards/" + formattedTargetToImageName(target: othertarget!))
            }
            showUnlockAnimation(imagePath: "UnlockedCards/" + formattedTargetToImageName(target: cardUnlocked))
            unlockedDate = ""
            cardUnlocked = ""
        }
        calendarsListView.reloadData()
        endNoInput()
        for item in [todayButton, monthButton, yearButton, calendarsListView, imageOfDayImageView, imageOfDayLight, imageOfDayMainLabel, imageOfDayLabel] {
            item!.isHidden = false
        }
        iodvc = nil
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numMonths
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell", for: indexPath) as! CalendarTableViewCell
        cell.selectionStyle = .none
        cell.curRow = indexPath.row
        cell.cvc = self
        cell.calendarView.reloadData()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height
    }
    @objc func willEnterForeground() {
        for cell in calendarsListView.visibleCells {
            let calendarCell = cell as! CalendarTableViewCell
            calendarCell.sunLabelLeadingC.constant = floor(calendarCell.bounds.width / 7) / 2 - calendarCell.sunLabelW / 2
        }
        calendarsListView.reloadData()
    }
    @IBAction func pickerButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "calendarToPicker", sender: self)
    }
    @IBAction func newEntryTapped(_ sender: Any) {
        newEntryButton.isHidden = true
        newEntryMode = true
        selectDateText.isHidden = false
        cancelButton.isHidden = false
        showEarlierMonthButton.isHidden = false
        calendarsListView.reloadData()
    }
    @IBAction func cancelTapped(_ sender: Any) {
        newEntryButton.isHidden = false
        newEntryMode = false
        selectDateText.isHidden = true
        cancelButton.isHidden = true
        showEarlierMonthButton.isHidden = true
        numMonths -= numEarlierMonthsAdded
        numEarlierMonthsAdded = 0
        calendarsListView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: UITableView.ScrollPosition.top, animated: true)
        calendarsListView.reloadData()
    }
    @IBAction func showEarlierMonthTapped(_ sender: Any) {
        numMonths += 1
        calendarsListView.reloadData()
        calendarsListView.scrollToRow(at: NSIndexPath(row: numMonths - 1, section: 0) as IndexPath, at: UITableView.ScrollPosition.top, animated: true)
        numEarlierMonthsAdded += 1
    }
    @IBAction func todayButtonTapped(_ sender: Any) {
        self.calendarsListView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: UITableView.ScrollPosition.top, animated: true)
        monthButton.setTitle("month", for: .normal)
        yearButton.setTitle("year", for: .normal)
    }
    @IBAction func monthButtonTapped(_ sender: Any) {
        monthDropDown!.show()
    }
    @IBAction func yearButtonTapped(_ sender: Any) {
        yearDropDown!.show()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JournalEntryEditViewController
        vc?.entryDate = newEntryDate
        if vc != nil {
            vc!.entryDate = newEntryDate
            vc!.entryList = selectedEntryList
            vc!.selectedEntryInd = selectedEntryList.count
            vc!.formattedTargetsList = formattedTargetsList
            vc!.cvc = self
            newEntryDate = ""
            newEntryButton.isHidden = false
            newEntryMode = false
            selectDateText.isHidden = true
            cancelButton.isHidden = true
            showEarlierMonthButton.isHidden = true
            numMonths -= numEarlierMonthsAdded
            numEarlierMonthsAdded = 0
            calendarsListView.reloadData()
            calendarsListView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: UITableView.ScrollPosition.top, animated: false)
            return
        }
        let vc2 = segue.destination as? JournalEntryViewController
        if vc2 != nil {
            vc2!.entryDate = entryToShowDate
            vc2!.entryList = selectedEntryList
            vc2!.selectedEntryInd = selectedEntryInd
            vc2!.formattedTargetsList = formattedTargetsList
            vc2!.cvc = self
            jevc = vc2!
            return
        }
        let vc3 = segue.destination as? ImageOfDayViewController
        if vc3 != nil {
            vc3!.entryKey = self.imageOfDayKeysData!["journalEntryListKey"] as! String
            vc3!.entryInd = self.imageOfDayKeysData!["journalEntryInd"] as! Int
            vc3!.iodUserKey = self.imageOfDayKeysData!["userKey"] as! String
            vc3!.imageData = self.imageOfDayImageData
            vc3!.featuredDate = featuredImageDate
            vc3!.cvc = self
            self.iodvc = vc3!
            return
        }
    }
    @IBAction func imageTapped(_ sender: Any) {
        if imageOfDayImageView.image != nil {
            performSegue(withIdentifier: "calendarToImageOfDay", sender: self)
        }
    }
}

