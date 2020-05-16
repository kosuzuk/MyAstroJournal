//
//  ImageOfDayPickerViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/31/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ImageOfDayPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var fromDateField: UITextField!
    @IBOutlet weak var entriesCollectionView: UICollectionView!
    @IBOutlet weak var pageNumLabel: UILabel!
    @IBOutlet weak var prevPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var firstPageButton: UIButton!
    @IBOutlet weak var lastPageButton: UIButton!
    @IBOutlet weak var collectionViewLeadingCipad: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTrailingCipad: NSLayoutConstraint!
    var entriesBasicData: [[String: Any]] = []
    var endEntryInd = 0
    var curEntryRangeInPage: CountableRange = 0..<0
    var savedEntryImageData: [Int: UIImage] = [:]
    let maxSavedImages = 30
    var entryIndToShow = 0
    var entryListDataToShow: [[String: Any]] = []
    var entryIndInEntryList = 0
    var profileKeyToShow = ""
    var entryDataToSetAsIod: [String: Any] = [:]
    var dateToSetAsIod = ""
    
    func updateCollectionView() {
        entriesCollectionView.reloadData()
        pageNumLabel.text = String(Int(ceil(Double(curEntryRangeInPage.endIndex) / 10.0))) + "/" + String(Int(ceil(Double(endEntryInd) / 10.0)))
        for i in curEntryRangeInPage.startIndex..<curEntryRangeInPage.endIndex {
            if savedEntryImageData[i] == nil {
                let imageKey = (entriesBasicData[i]["mainImageKey"] as! String)
                storage.child(imageKey).getData(maxSize: imgMaxByte) {data, Error in
                    if let Error = Error {
                        print(Error)
                        return
                    } else {
                        let image = UIImage(data: data!)!
                        self.savedEntryImageData[i] = image
                        let cell = (self.entriesCollectionView.cellForItem(at: IndexPath(item: i - self.curEntryRangeInPage.startIndex, section: 0)) as? ImageOfDayPickerCollectionViewCell)
                        if cell != nil {
                            cell!.imageView.image = image
                            for view in cell!.subviews {
                                if view is UILabel {
                                    view.isHidden = false
                                }
                            }
                            cell!.targetNameLabel.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    func resetEntryRangeInPage() {
        if endEntryInd <= 10 {
            curEntryRangeInPage = 0..<endEntryInd
            nextPageButton.isHidden = true
            lastPageButton.isHidden = true
        } else {
            curEntryRangeInPage = 0..<10
        }
        prevPageButton.isHidden = true
        firstPageButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH > 1300 {
            collectionViewLeadingCipad.constant = 110
            collectionViewTrailingCipad.constant = 110
        }
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
        loadingIcon.startAnimating()
        
        db.collection("journalEntries").getDocuments(completion: {(QuerySnapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                for doc in QuerySnapshot!.documents {
                    var entryList = (doc.data()["data"] as! [[String: Any]])
                    for i in 0..<entryList.endIndex {
                        if entryList[i]["mainImageKey"] as! String != "" && entryList[i]["featuredDate"] as! String == "" {
                            entryList[i]["key"] = doc.documentID
                            let basicEntryData = ["key": doc.documentID, "mainImageKey": entryList[i]["mainImageKey"] as! String, "formattedTarget": entryList[i]["formattedTarget"] as! String]
                            self.entriesBasicData.append(basicEntryData)
                        }
                    }
                }
                //sort from most recent to oldest entries
                self.entriesBasicData.sort(by: ¬)
                self.endEntryInd = self.entriesBasicData.endIndex
                self.resetEntryRangeInPage()
                self.updateCollectionView()
                loadingIcon.stopAnimating()
                endNoInput()
            }
        })
    }
    
    func addButton(cell: ImageOfDayPickerCollectionViewCell, xPos: Int, yPos: Int, str: String, f: Selector) {
        let buttonLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: 120, height: 20))
        buttonLabel.text = str
        buttonLabel.textColor = UIColor.white
        buttonLabel.font = UIFont(name: "Helvetica Neue", size: 13)
        buttonLabel.layer.borderWidth = 1
        buttonLabel.layer.borderColor = astroOrange
        buttonLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: f))
        buttonLabel.isUserInteractionEnabled = true
        cell.imageView.addSubview(buttonLabel)
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return curEntryRangeInPage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageOfDayPickerCollectionViewCell
        var hasButtons = false
        for view in cell.subviews {
            if view is UILabel {
                hasButtons = true
                break
            }
        }
        if !hasButtons {
            addButton(cell: cell, xPos: 10, yPos: Int(cell.bounds.height) - 110, str: " Show Entry", f: #selector(showEntry))
            addButton(cell: cell, xPos: 10, yPos: Int(cell.bounds.height) - 80, str: " Show Profile", f: #selector(showProfile))
            addButton(cell: cell, xPos: 10, yPos: Int(cell.bounds.height) - 50, str: " Feature this image", f: #selector(setAsFeatured))
        }
        if savedEntryImageData[curEntryRangeInPage.startIndex + indexPath.row] != nil {
            cell.imageView.image = savedEntryImageData[curEntryRangeInPage.startIndex + indexPath.row]
            for view in cell.subviews {
                if view is UILabel {
                    view.isHidden = false
                }
            }
        } else {
            cell.imageView.image = nil
            for view in cell.subviews {
                if view is UILabel {
                    view.isHidden = true
                }
            }
        }
        let formattedTarget = entriesBasicData[curEntryRangeInPage.startIndex + indexPath.row]["formattedTarget"] as? String
        if formattedTarget != "" {
            let target = formattedTargetToTargetName(target: formattedTarget!)
            cell.targetNameLabel.text = target
        }
        cell.targetNameLabel.isHidden = false
        return cell
    }
    
    func isValidDate(date: String) -> Bool {
        for c in date {
            if !c.isNumber {
                return false
            }
        }
        if date.count != 8 || Int(String(date.prefix(2)))! > 12 || Int(String(date.prefix(4).suffix(2)))! > 31 {
            return false
        }
        return true
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        let inputDate = fromDateField.text!
        if !isValidDate(date: inputDate) {
            let alertController = UIAlertController(title: "Error", message: "Invalid date", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        entriesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        endEntryInd = 0
        var entryDate = ""
        for entry in entriesBasicData {
            entryDate = String((entry["key"] as! String).suffix(8))
            if !isEarlierDate(inputDate, entryDate)  {
                break
            }
            endEntryInd += 1
        }
        resetEntryRangeInPage()
        checkAndClearImageData()
        updateCollectionView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JournalEntryViewController
        if vc != nil {
            vc?.entryDate = String((entriesBasicData[entryIndToShow]["key"] as! String).suffix(8))
            vc?.entryList = entryListDataToShow
            vc?.selectedEntryInd = entryIndInEntryList
        }
        let vc2 = segue.destination as? ProfileViewController
        if vc2 != nil {
            vc2!.keyForDifferentProfile = profileKeyToShow
        }
    }
    
    @objc func showEntry(sender: UIGestureRecognizer) {
        let indexPath = entriesCollectionView.indexPathForItem(at: sender.location(in: entriesCollectionView))
        if indexPath != nil {
            entryIndToShow = curEntryRangeInPage.startIndex + indexPath!.row
            db.collection("journalEntries").document(self.entriesBasicData[entryIndToShow]["key"] as! String).getDocument(completion: {(snapshot, Error) in
                if Error != nil {
                    print(Error!, "journal entry deleted by user")
                } else {
                    var entryListData = snapshot!.data()!["data"] as! [[String: Any]]
                    for i in 0..<entryListData.endIndex {
                        if self.entriesBasicData[self.entryIndToShow]["formattedTarget"] as! String == entryListData[i]["formattedTarget"] as! String {
                            entryListData[i]["key"] = self.entriesBasicData[self.entryIndToShow]["key"] as! String
                            self.entryListDataToShow = entryListData
                            self.entryIndInEntryList = i
                            self.performSegue(withIdentifier: "pickerToEntry", sender: self)
                            break
                        }
                        if i == entryListData.endIndex - 1 {
                            print(Error!, "journal entry deleted by user")
                        }
                    }
                }
            })
        }
    }
    
    @objc func showProfile(sender: UIGestureRecognizer) {
        let indexPath = entriesCollectionView.indexPathForItem(at: sender.location(in: entriesCollectionView))
        if indexPath != nil {
            let key = entriesBasicData[curEntryRangeInPage.startIndex + indexPath!.row]["key"] as! String
            profileKeyToShow = String(key.prefix(key.count - 8))
            performSegue(withIdentifier: "pickerToProfile", sender: self)
        }
    }
    
    func changeFeaturedImage(curImageOfDayKeysData: [String: Any]) {
        let entryKey = curImageOfDayKeysData["journalEntryListKey"] as! String
        let userKey = String(entryKey.prefix(entryKey.count - 8))
        db.collection("userData").document(userKey).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!, "couldn't get user data to undo the feature")
            } else {
                let userData = snapshot!.data()!
                let userDataCopyKey = (userData["userDataCopyKeys"] as! [String: String])[self.dateToSetAsIod]!
                db.collection("userData").document(userDataCopyKey).delete()
                var featuredAlertDates = userData["featuredAlertDates"] as! [String]
                if featuredAlertDates.index(of: self.dateToSetAsIod) != nil {
                    featuredAlertDates.remove(at: featuredAlertDates.index(of: self.dateToSetAsIod)!)
                }
                db.collection("userData").document(userKey).setData(["featuredAlertDates": featuredAlertDates, "userDataCopyKeys": [self.dateToSetAsIod: FieldValue.delete()]], merge: true) {err in
                    if let err = err {
                        print(err)
                    } else {
                        self.updateUserData()
                    }
                }
            }
        })
        db.collection("journalEntries").document(entryKey).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!, "couldn't get entry data to undo the feature")
            } else {
                var entryListData = snapshot!.data()!["data"] as! [[String: Any]]
                entryListData[curImageOfDayKeysData["journalEntryInd"] as! Int]["featuredDate"] = ""
                db.collection("journalEntries").document(entryKey).setData(["data": entryListData], merge: true) {err in
                    if let err = err {
                        print(err)
                    } else {
                        self.updateJournalEntryData()
                    }
                }
            }
        })
    }
    
    func updateUserData() {
        let entryKey = entryDataToSetAsIod["key"] as! String
        let userKey = String(entryKey.prefix(entryKey.count - 8))
        db.collection("userData").document(userKey).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!, "getting profile data")
            } else {
                let userData = snapshot!.data()!
                var alertDates = userData["featuredAlertDates"] as! [String]
                alertDates.append(self.dateToSetAsIod)
                var newUserData = ["featuredAlertDates": alertDates] as [String : Any]
                let newUserDataCopy = ["userName": userData["userName"]!, "userBio": userData["userBio"]!, "websiteName": userData["websiteName"]!, "instaUsername": userData["instaUsername"]!, "youtubeChannel": userData["youtubeChannel"]!, "fbPage": userData["fbPage"]!, "profileImageKey": userData["profileImageKey"]!, "obsTargetNum": userData["obsTargetNum"]!, "photoTargetNum": userData["photoTargetNum"]!, "totalHours": userData["totalHours"]!] as [String : Any]
                //copy data into new doc for iod
                var newUserDataCopyDocRef: DocumentReference? = nil
                newUserDataCopyDocRef = db.collection("userData").addDocument(data: newUserDataCopy) {err in
                    if let err = err {
                        print("Error adding user data copy document: \(err)")
                    } else {
                        let userDataCopyKey = newUserDataCopyDocRef!.documentID
                        var userDataCopyKeys = userData["userDataCopyKeys"] as! [String: String]
                        userDataCopyKeys[self.dateToSetAsIod] = userDataCopyKey
                        db.collection("userData").document(userDataCopyKey).setData(["userDataCopyKeys": userDataCopyKeys], merge: true)
                        newUserData["userDataCopyKeys"] = userDataCopyKeys
                        db.collection("userData").document(userKey).setData(newUserData, merge: true)
                        let newIodData = ["imageKey": self.entryDataToSetAsIod["mainImageKey"]!, "journalEntryInd": self.entryIndInEntryList, "journalEntryListKey": entryKey, "userKey": userDataCopyKey, "formattedTarget": self.entryDataToSetAsIod["formattedTarget"] as! String]
                        db.collection("imageOfDayKeys").document(self.dateToSetAsIod).setData(newIodData, merge: false) {err in
                                if let err = err {
                                    print("Error updating iod keys data: \(err)")
                                } else {
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                        }
                        db.collection("imageOfDayLikes").document(self.dateToSetAsIod).setData([:], merge: false)
                        db.collection("imageOfDayComments").document(self.dateToSetAsIod).setData([:], merge: false)
                    }
                }
            }
        })
    }
    
    func updateJournalEntryData() {
        let entryKey = entryDataToSetAsIod["key"] as! String
        db.collection("journalEntries").document(entryKey).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!, "getting journal entry")
            } else {
                var entryListData = snapshot!.data()!["data"] as! [[String: Any]]
                entryListData[self.entryIndInEntryList]["featuredDate"] = self.dateToSetAsIod
                db.collection("journalEntries").document(entryKey).setData(["data": entryListData], merge: true)
            }
        })
    }
    
    func checkData() {
        if !isValidDate(date: dateToSetAsIod) {//|| !isEarlierDate(dateToday, dateToSetAsIod) {
            let alertController = UIAlertController(title: "Error", message: "Invalid date", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        db.collection("imageOfDayKeys").document(dateToSetAsIod).getDocument(completion: {(QuerySnapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                let docRef = db.collection("journalEntries").document(self.entryDataToSetAsIod["key"] as! String)
                docRef.getDocument(completion: {(snapshot, Error) in
                    var deleted = false
                    if Error != nil || snapshot!.data() == nil {
                        print(Error!)
                        deleted = true
                    } else {
                        var entryListData = snapshot!.data()!["data"] as! [[String: Any]]
                        for i in 0..<entryListData.endIndex {
                            if entryListData[i]["formattedTarget"] as! String == self.entryDataToSetAsIod["formattedTarget"] as! String {
                                if entryListData[i]["mainImageKey"] as! String == "" {
                                    deleted = true
                                    break
                                }
                                entryListData[i]["key"] = self.entryDataToSetAsIod["key"] as! String
                                self.entryDataToSetAsIod = entryListData[i]
                                self.entryIndInEntryList = i
                                let docData = QuerySnapshot!.data()
                                if docData != nil && docData!.count != 0 {
                                    let alertController = UIAlertController(title: "Warning", message: "You have already picked an entry to feature for this date. Do you want to change the chosen entry?", preferredStyle: .alert)
                                    let confirmAction = UIAlertAction(title: "yes", style: .destructive, handler: {(alertAction) in self.changeFeaturedImage(curImageOfDayKeysData: docData!)})
                                    let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
                                    alertController.addAction(confirmAction)
                                    alertController.addAction(cancelAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                else {
                                    self.updateUserData()
                                    self.updateJournalEntryData()
                                }
                                return
                            }
                            if i == entryListData.endIndex - 1 {
                                deleted = true
                            }
                        }
                    }
                    if deleted {
                        let alertController = UIAlertController(title: "User deleted entry", message: "User has deleted the entry you just picked!", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            }
        })
    }
    
    @objc func setAsFeatured(sender: UIGestureRecognizer) {
        let indexPath = entriesCollectionView.indexPathForItem(at: sender.location(in: entriesCollectionView))
        if indexPath != nil {
            let alertController = UIAlertController(title: "Set as Image of Day", message: "Choose this image as Image of the Day?", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "confirm", style: .destructive, handler: {(alertAction) in
                self.entryDataToSetAsIod = self.entriesBasicData[self.curEntryRangeInPage.startIndex + indexPath!.row]
                self.dateToSetAsIod = alertController.textFields![0].text!
                self.checkData()
            })
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            alertController.addTextField { (textField) in
                textField.placeholder = "Enter date to feature"
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func checkAndClearImageData() {
        if savedEntryImageData[curEntryRangeInPage.startIndex] != nil || savedEntryImageData.count + curEntryRangeInPage.count <= maxSavedImages {
            return
        }
        print(savedEntryImageData.count)
        var startAtInd = 0
        for (i, _) in savedEntryImageData {
            if i % 10 == 0 && abs(curEntryRangeInPage.startIndex - i) > abs(curEntryRangeInPage.startIndex - startAtInd) {
                startAtInd = i
            }
        }
        for i in startAtInd..<startAtInd + 10 {
            savedEntryImageData.removeValue(forKey: i)
        }
    }
    
    @IBAction func prevPageTapped(_ sender: Any) {
        entriesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        curEntryRangeInPage = curEntryRangeInPage.startIndex - 10..<curEntryRangeInPage.startIndex
        checkAndClearImageData()
        updateCollectionView()
        if curEntryRangeInPage.startIndex == 0 {
            prevPageButton.isHidden = true
            firstPageButton.isHidden = true
        }
        nextPageButton.isHidden = false
        lastPageButton.isHidden = false
    }
    
    @IBAction func nextPageTapped(_ sender: Any) {
        entriesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        if entriesBasicData.endIndex <= curEntryRangeInPage.endIndex + 10 {
            curEntryRangeInPage = curEntryRangeInPage.endIndex..<entriesBasicData.endIndex
            nextPageButton.isHidden = true
            lastPageButton.isHidden = true
        } else {
            curEntryRangeInPage = curEntryRangeInPage.endIndex..<curEntryRangeInPage.endIndex + 10
        }
        checkAndClearImageData()
        updateCollectionView()
        prevPageButton.isHidden = false
        firstPageButton.isHidden = false
    }
    @IBAction func firstPageTapped(_ sender: Any) {
        entriesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        resetEntryRangeInPage()
        checkAndClearImageData()
        updateCollectionView()
        prevPageButton.isHidden = true
        nextPageButton.isHidden = false
        firstPageButton.isHidden = true
        lastPageButton.isHidden = false
    }
    @IBAction func lastPageTapped(_ sender: Any) {
        entriesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        curEntryRangeInPage = (entriesBasicData.endIndex - 1) / 10 * 10..<entriesBasicData.endIndex
        checkAndClearImageData()
        updateCollectionView()
        prevPageButton.isHidden = false
        nextPageButton.isHidden = true
        firstPageButton.isHidden = false
        lastPageButton.isHidden = true
    }
}
