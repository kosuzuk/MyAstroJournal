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

extension UINavigationController {
   open override var preferredStatusBarStyle: UIStatusBarStyle {
      return topViewController?.preferredStatusBarStyle ?? .default
   }
}
class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var background: UIImageView!
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
    @IBOutlet weak var yearButtonLeadingC: NSLayoutConstraint!
    @IBOutlet weak var calendarWC: NSLayoutConstraint!
    @IBOutlet weak var calendarHC: NSLayoutConstraint!
    @IBOutlet weak var calendarWCipad: NSLayoutConstraint!
    @IBOutlet weak var calendarHCipad: NSLayoutConstraint!
    @IBOutlet weak var earlierMonthButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayTopC: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayTopCipad: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayBottomC: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayBottomCipad: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayWC: NSLayoutConstraint!
    @IBOutlet weak var imageOfDayLightWC: NSLayoutConstraint!
    var monthDropDown: DropDown? = nil
    var yearDropDown: DropDown? = nil
    var firstJournalEntryDate = ""
    var startMonth = 0
    var startYear = 0
    var numMonths = 0
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
    var imageOfDayListenerInitiated = false
    var imageOfDayKeysData: [String: Any]? = nil
    var imageOfDayImageData: UIImage? = nil
    var imageOfDayTarget = ""
    var newEntryMode = false
    var numEarlierMonthsAdded = 0
    var newEntryDate = ""
    var newEntryIndexPathRow = 0
    var newImage: UIImage? = nil
    var imageChangedDate = ""
    var cardUnlocked = ""
    var entryToShowDate = ""
    var selectedEntryList: [[String: Any]] = []
    var selectedEntryInd = 0
    var jevc: JournalEntryViewController? = nil
    var iodvc: ImageOfDayViewController? = nil
    var monthTodayInt = 0
    var yearTodayInt = 0
    var unlockedDate = ""
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
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
        loadingIcon.startAnimating()
        if (screenH < 670) {//iphone 8
            earlierMonthButtonTopC.constant = -50
        }
        if (screenH < 750) {//iphone 8 and plus
            imageOfDayTopC.constant = -4
            imageOfDayMainLabel.font = imageOfDayMainLabel.font.withSize(18)
        }
        else if (screenH == 896) {//iphone 11 pro max
            newEntryButtonTopC.constant = 30
            yearButtonTopC.constant = 30
            imageOfDayLabelTopC.constant = 40
            imageOfDayBottomC.constant = 15
        }
        else if screenH > 1000 {//ipads
            background.image = UIImage(named: "Calendar/background-ipad")
            imageOfDayMainLabel.font = imageOfDayMainLabel.font.withSize(31)
            if screenH < 1050 {//small ipads
                imageOfDayTopCipad.constant = 0
            } else if (screenH > 1140) {//big ipads
                imageOfDayBottomCipad.constant = 30
            }
        }
        imageOfDayImageView.layer.borderColor = UIColor.orange.cgColor
        imageOfDayImageView.layer.borderWidth = 1.0
        monthDropDown = DropDown()
        monthDropDown!.backgroundColor = .darkGray
        monthDropDown!.textColor = .white
        monthDropDown!.textFont = UIFont(name: "Pacifica Condensed", size: 14)!
        monthDropDown!.separatorColor = .white
        monthDropDown!.cellHeight = 34
        monthDropDown!.cornerRadius = 10
        monthDropDown!.anchorView = monthButton
        monthDropDown!.bottomOffset = CGPoint(x: 0, y: 25)
        yearDropDown = DropDown()
        yearDropDown!.backgroundColor = .darkGray
        yearDropDown!.textColor = .white
        yearDropDown!.textFont = UIFont(name: "Pacifica Condensed", size: 14)!
        yearDropDown!.separatorColor = .white
        yearDropDown!.cellHeight = 34
        yearDropDown!.cornerRadius = 10
        yearDropDown!.bottomOffset = CGPoint(x: 0, y: 25)
        yearDropDown!.anchorView = yearButton
        
        for item in [antoinePowersButton, selectDateText, cancelButton, showEarlierMonthButton, todayButton, monthButton, yearButton, calendarsListView, imageOfDayImageView, imageOfDayLight, imageOfDayMainLabel, imageOfDayLabel] {
            item!.isHidden = true
        }
        imageOfDayImageView.isUserInteractionEnabled = false
        let date = Date()
        let calendar = Calendar.current
        let dateComps = calendar.dateComponents([.year, .month, .day], from: date)
        monthTodayInt = dateComps.month!
        yearTodayInt = dateComps.year!
        if String(monthTodayInt).count == 1 {
            dateToday = "0"
        }
        dateToday += String(monthTodayInt)
        if String(dateComps.day!).count == 1 {
            dateToday += "0"
        }
        dateToday += String(dateComps.day!)
        dateToday += String(yearTodayInt)
        Timer.scheduledTimer(timeInterval: TimeInterval(60), target: self, selector: #selector(checkDayChange), userInfo: nil,  repeats: true)
        let userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        db.collection("userData").document(userKey).getDocument(completion: {(QuerySnapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                let userData = QuerySnapshot!.data()!
                if userData["firstJournalEntryDate"] as! String == "" {
                    self.monthDropDown!.dataSource = [monthNames[self.monthTodayInt - 1]]
                    self.yearDropDown!.dataSource = [String(self.yearTodayInt)]
                    self.numMonths = 1
                    self.calendarsListView.reloadData()
                    loadingIcon.stopAnimating()
                } else {
                    self.firstJournalEntryDate = userData["firstJournalEntryDate"] as! String
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
                    
                    let imageKeyDict = userData["calendarImages"] as! [String : String]
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
                                return
                            } else {
                                self.imageDict[dateString] = UIImage(data: data!)!
                            }
                        }
                    }
                    self.numEntriesDict = userData["numEntriesInDate"] as! [String : Int]
                }
                var alertDates = userData["featuredAlertDates"] as! [String]
                if alertDates != [] {
                    for alertDate in alertDates {
                        if isEarlierDate(date1: alertDate, date2: dateToday) {
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
                if (userData["email"] as! String) == "nevadaastrophotography@gmail.com" {
                    self.antoinePowersButton.isHidden = false
                    db.collection("iodDeletedNotifications").addSnapshotListener(includeMetadataChanges: true, listener: {(snapshot, Error) in
                        if Error != nil {
                            print(Error!)
                        } else {
                            if (snapshot?.metadata.isFromCache)! {
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
                        }
                    })
                }
            }
        })
        db.collection("imageOfDayKeys").addSnapshotListener(includeMetadataChanges: true, listener: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                if (snapshot?.metadata.isFromCache)! {
                    return
                }
                self.imageOfDayImageView.isUserInteractionEnabled = false
                let iodDocs = snapshot!.documents
                //if dropdown is displayed for entry that was just modified in the db, hide it
                func checkDropDown() {
                    for i in 0..<self.selectedEntryList.count {
                        let entryFeaturedDate = self.selectedEntryList[i]["featuredDate"] as! String
                        //entry was just picked as iod for today or future
                        if entryFeaturedDate == "" {
                            for j in 0..<iodDocs.count {
                                if iodDocs[j].data()["journalEntryListKey"] as? String == userKey +
                                    self.entryToShowDate && iodDocs[j].data()["journalEntryInd"] as? Int == i {
                                    self.entryDropDown?.hide()
                                    let iodDate = iodDocs[j].documentID
                                    if isEarlierDate(date1: iodDate, date2: dateToday) {
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
                                    if iodDocs[j].data()["journalEntryListKey"] as? String != userKey + self.entryToShowDate || iodDocs[j].data()["journalEntryInd"] as? Int != i {
                                        self.entryDropDown?.hide()
                                        if isEarlierDate(date1: iodDocs[j].documentID, date2: dateToday) {
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
                                    if isEarlierDate(date1: iodDocs[j].documentID, date2: dateToday) {
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
                    self.imageOfDayImageView.image = nil
                    self.imageOfDayListenerInitiated = true
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
                    if isEarlierDate(date1: doc.documentID, date2: dateToday) && (!isEarlierDate(date1: iodDocToShow.documentID, date2: dateToday) || isEarlierDate(date1: iodDocToShow.documentID, date2: doc.documentID)) {
                        iodDocToShow = doc
                    }
                }
                if !isEarlierDate(date1: iodDocToShow.documentID, date2: dateToday) {
                    print("there are only featured images for the future")
                    noIodData()
                    return
                }
                if featuredImageDate != "" && !isEarlierDate(date1: featuredImageDate, date2: iodDocToShow.documentID) {
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
                    } else {
                        self.imageOfDayImageView.image = UIImage(data: imageData!)!
                        self.imageOfDayImageData = self.imageOfDayImageView.image
                        self.imageOfDayImageView.isUserInteractionEnabled = true
                    }
                }
                var docRef = db.collection("journalEntries").document(iodKeysData["journalEntryListKey"] as! String)
                docRef.getDocument(completion: {(QuerySnapshot, Error) in
                    if Error != nil {
                        print(Error!)
                    } else {
                        let data = QuerySnapshot!.data()
                        if data == nil {
                            print("no iod entry doc found")
                            noIodData()
                            return
                        } else if data!.count == 0 {
                            print("empty iod entry data")
                            noIodData()
                            return
                        }
                        var iodTarget = (data!["data"] as! [Dictionary<String, Any>])[iodKeysData["journalEntryInd"] as! Int]["formattedTarget"] as! String
                        iodTarget = formattedTargetToTargetName(target: iodTarget)
                        self.imageOfDayLabel.text = iodTarget + " by " + (data!["userName"] as! String) + " "
                        let font = UIFont(name: self.imageOfDayLabel.font.fontName, size: self.imageOfDayLabel.font.pointSize)
                        let fontAttributes = [NSAttributedString.Key.font: font]
                        let size = (self.imageOfDayLabel.text! as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
                        self.imageOfDayLightWC.constant = size.width + 30
                        self.imageOfDayTarget = iodTarget
                    }
                })
                docRef = db.collection("userData").document(iodKeysData["userKey"] as! String)
                docRef.getDocument(completion: {(QuerySnapshot, Error) in
                    if Error != nil {
                        print(Error!)
                    } else {
                        if QuerySnapshot!.data() == nil {
                            print("empty user data")
                            noIodData()
                            return
                        }
                    }
                })
                featuredImageDate = iodDocToShow.documentID
                //iod changed
                if self.imageOfDayListenerInitiated && iodKeysData["imageKey"] as! String != oldIodImageKey {
                    //kick out users from current iod view
                    self.iodvc?.navigationController?.popToRootViewController(animated: true)
                    let iodEntryListKey = iodKeysData["journalEntryListKey"] as! String
                    //check if this user was picked for iod while app was on. If so, show congrats alert
                    if (iodEntryListKey).prefix(iodEntryListKey.count - 8) == userKey {
                        self.entryDropDown?.hide()
                        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CongratsViewController") as! CongratsViewController
                        popOverVC.featuredDate = iodDocToShow.documentID
                        popOverVC.cvc = self
                        self.addChild(popOverVC)
                        popOverVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                        self.view.addSubview(popOverVC.view)
                        popOverVC.didMove(toParent: self)
                        db.collection("userData").document(userKey).updateData(["featuredAlertDates": self.userAlertDates])
                    }
                }
            }
            if !self.imageOfDayListenerInitiated {
                self.imageOfDayListenerInitiated = true
            }
        })
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
    func showUnlockAnimation(_ cardName: String) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardUnlockedViewController") as! CardUnlockedViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.unlockedDateLabel.text = monthNames[Int(unlockedDate.prefix(2))! - 1] + " " + String(Int(unlockedDate.prefix(4).suffix(2))!) + " " + String(unlockedDate.suffix(4))
        popOverVC.imageView.image = UIImage(named: "UnlockedCards/" + formattedTargetToImageName(target: cardName))
        popOverVC.didMove(toParent: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if (screenH < 600) {//iphone SE, 5s
            bannerHC.constant = 35
            yearButtonLeadingC.constant = 20
            earlierMonthButtonTopC.constant = -38
            imageOfDayMainLabel.text = ""
            imageOfDayTopC.constant = 7
            imageOfDayWC.constant = 287
        }
        let calendarSize = screenW * 0.9
        calendarWC.constant = calendarSize
        calendarHC.constant = calendarSize
        calendarWCipad.constant = calendarSize
        calendarHCipad.constant = calendarSize * 0.83
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
                showUnlockAnimation(othertarget!)
            }
            showUnlockAnimation(cardUnlocked)
            unlockedDate = ""
            cardUnlocked = ""
        }
        calendarsListView.reloadData()
        endNoInput()
        for item in [todayButton, monthButton, yearButton, calendarsListView, imageOfDayImageView, imageOfDayLight, imageOfDayMainLabel, imageOfDayLabel] {
            item!.isHidden = false
        }
        if newIodUserName != "" {
            imageOfDayLabel.text = imageOfDayTarget + " by " + newIodUserName + " "
            let font = UIFont(name: self.imageOfDayLabel.font.fontName, size: self.imageOfDayLabel.font.pointSize)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = (self.imageOfDayLabel.text! as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
            self.imageOfDayLightWC.constant = size.width + 30
            newIodUserName = ""
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
    @IBAction func pickerButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "calendarToPicker", sender: self)
    }
    @IBAction func newEntryTapped(_ sender: Any) {
        newEntryButton.isHidden = true
        newEntryMode = true
        selectDateText.isHidden = false
        cancelButton.isHidden = false
        showEarlierMonthButton.isHidden = false
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
        startNoInput()
        let vc = segue.destination as? JournalEntryEditViewController
        vc?.entryDate = newEntryDate
        if vc != nil {
            vc!.entryDate = newEntryDate
            vc!.entryList = selectedEntryList
            vc!.selectedEntryInd = selectedEntryList.count
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

