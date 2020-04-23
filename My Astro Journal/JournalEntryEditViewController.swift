//
//  FirstViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftKeychainWrapper
import DropDown

@IBDesignable extension UIButton {
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

class JournalEntryEditViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    @IBOutlet var VCview: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var multTargetWarning: UILabel!
    @IBOutlet weak var targetField: UITextField!
    @IBOutlet weak var constellationField: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var timeStartField: UITextField!
    @IBOutlet weak var timeEndField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var observedCheckBox: UIButton!
    @IBOutlet weak var observedCheckImage: UIImageView!
    @IBOutlet weak var bigImageViewText: UILabel!
    @IBOutlet weak var photographedCheckBox: UIButton!
    @IBOutlet weak var photographedCheckImage: UIImageView!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var bigImageViewRemoveButton: UIButton!
    @IBOutlet weak var memoriesField: UITextView!
    @IBOutlet weak var telescopeField: UITextField!
    @IBOutlet weak var mountField: UITextField!
    @IBOutlet weak var cameraField: UITextField!
    @IBOutlet weak var acquisitionField: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var attachImageButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var arrowWC: NSLayoutConstraint!
    @IBOutlet weak var targetFieldWC: NSLayoutConstraint!
    @IBOutlet weak var mountFieldWC: NSLayoutConstraint!
    var entryDate = ""
    var entryList: [Dictionary<String, Any>] = []
    var selectedEntryInd = 0
    var entryData: Dictionary<String, Any> = [:]
    let userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
    var userData: Dictionary<String, Any> = [:]
    var firstJournalEntry = false
    var locationsVisited: [String] = []
    var activeField: UIView? = nil
    var observedSelected = false
    var photographedSelected = false
    var timeStartDropDown: DropDown? = nil
    var showingTimeStartDropDown = false
    var timeEndDropDown: DropDown? = nil
    var showingTimeEndDropDown = false
    var target = ""
    var formattedTarget = ""
    var numHours = 0
    var mainImageKey = ""
    var mainImage: UIImage? = nil
    var mainImageData: Data? = nil
    var mainImageUpdated = false
    var imageKeyList: [String] = []
    var imageList: [UIImage] = []
    var imageDataList: [Data] = []
    var bigImageViewTapped = false
    var imageSelected: UIImage? = nil
    //for targets that appear together
    var otherTarget = ""
    var featuredDate = ""
    var cvc: CalendarViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setAutoComp(_ textField: UITextField, _ data: [String], _ ddType: Int) {
        let dropDown = VPAutoComplete()
        dropDown.dataSource = data
        dropDown.onTextField = textField // Your TextField
        dropDown.onView = self.view // ViewController's View
        dropDown.cellHeight = 34
        //dropDownTop.showAlwaysOnTop = true
        //To show dropdown always on top.
        dropDown.show {(str, index) in
            var commaInd = -1
            for (i, char) in textField.text!.enumerated() {
                if char == "," {
                    commaInd = i
                }
            }
            if commaInd == -1 {
                textField.text = str
            } else {
                textField.text = textField.text!.prefix(commaInd + 1) + str
            }
        }
        if ddType == 0 {
            dropDown.frame.origin.y = targetField.frame.origin.y + 40
        } else if ddType == 1 {
            dropDown.frame.origin.y = locationField.frame.origin.y + 36
        } else {
            if screenH < 1000 {
                dropDown.frame.origin.y = screenH * 0.25 - 10
            } else {
                dropDown.frame.origin.y = screenH * 0.4 - 10
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if screenH < 600 {//iphone SE, 5s
            targetFieldWC.constant = 140
            arrowWC.constant = 130
            mountFieldWC.constant = 98
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH > 1000 {//ipads
            background.image = UIImage(named: "ViewEntry/background-ipad")
            border.image = UIImage(named: "border-ipad")
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: imageCollectionView.bounds.height, height: imageCollectionView.bounds.height)
            imageCollectionView.collectionViewLayout = layout
        }
        let monthInt = Int(entryDate.prefix(2))!
        let monthStr = monthNames[monthInt - 1]
        dateField.text = monthStr + " " + String(Int(entryDate.prefix(4).suffix(2))!) + " " + String(entryDate.suffix(4))
        multTargetWarning.isHidden = true
        func editTextViewLayout(textView: UITextView) {
            textView.layer.cornerRadius = 0
            textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            textView.layer.borderWidth = 0.5
        }
        editTextViewLayout(textView: memoriesField)
        editTextViewLayout(textView: acquisitionField)
        for field in [targetField, locationField, timeStartField, timeEndField, cameraField, telescopeField, mountField] {
            field!.delegate = (self as UITextFieldDelegate)
        }
        memoriesField.delegate = (self as UITextViewDelegate)
        acquisitionField.delegate = (self as UITextViewDelegate)
        scrollView.delegate = (self as UIScrollViewDelegate)
        let color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        targetField.attributedPlaceholder = NSAttributedString(string: "target", attributes: [NSAttributedString.Key.foregroundColor : color])
        bigImageView.layer.borderWidth = 2
        bigImageView.layer.borderColor = UIColor.orange.cgColor
        timeStartDropDown = DropDown()
        timeStartDropDown!.backgroundColor = .gray
        timeStartDropDown!.textColor = .white
        timeStartDropDown!.textFont = UIFont(name: "Pacifica Condensed", size: 15)!
        timeStartDropDown!.separatorColor = .white
        timeStartDropDown!.cellHeight = 34
        timeStartDropDown!.cornerRadius = 10
        timeStartDropDown!.anchorView = timeStartField
        timeStartDropDown!.bottomOffset = CGPoint(x: 0, y: 35)
        timeStartDropDown!.dataSource = ["12AM", "1AM", "2AM", "3AM", "4AM", "5AM", "6AM", "7AM", "8AM", "9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM", "5PM", "6PM", "7PM", "8PM", "9PM", "10PM", "11PM"]
        timeStartDropDown!.selectionAction = {(index: Int, item: String) in
            self.timeStartField.text = item
        }
        timeEndDropDown = DropDown()
        timeEndDropDown!.backgroundColor = .gray
        timeEndDropDown!.textColor = .white
        timeEndDropDown!.textFont = UIFont(name: "Pacifica Condensed", size: 15)!
        timeEndDropDown!.separatorColor = .white
        timeEndDropDown!.cellHeight = 34
        timeEndDropDown!.cornerRadius = 10
        timeEndDropDown!.anchorView = timeEndField
        timeEndDropDown!.bottomOffset = CGPoint(x: 0, y: 35)
        timeEndDropDown!.dataSource = ["12AM", "1AM", "2AM", "3AM", "4AM", "5AM", "6AM", "7AM", "8AM", "9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM", "5PM", "6PM", "7PM", "8PM", "9PM", "10PM", "11PM"]
        timeEndDropDown!.selectionAction = {(index: Int, item: String) in
            self.timeEndField.text = item
        }
        let cgWhite = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        for field in [timeStartField, timeEndField, locationField, telescopeField, mountField, cameraField, memoriesField, acquisitionField] {
            field!.layer.borderColor = cgWhite
            field!.layer.borderWidth = 1
        }
        targetField.autocorrectionType = .no
        locationField.autocorrectionType = .no
        telescopeField.autocorrectionType = .no
        mountField.autocorrectionType = .no
        cameraField.autocorrectionType = .no
        bigImageViewRemoveButton.isHidden = true
        deleteButton.isHidden = true
        let docRef = db.collection("userData").document(userKey)
        docRef.getDocument(completion: {(QuerySnapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                let docData = QuerySnapshot!.data()!
                if docData["firstJournalEntryDate"] as! String == "" {
                    self.firstJournalEntry = true
                } else {
                    let dayInt = Int(self.entryDate.prefix(4).suffix(2))!
                    let yearInt = Int(self.entryDate.suffix(4))!
                    let fjeStr = docData["firstJournalEntryDate"] as! String
                    let fjeStrMonth = Int(fjeStr.prefix(2))!
                    let fjeStrDay = Int(fjeStr.prefix(4).suffix(2))!
                    let fjeStrYear = Int(fjeStr.suffix(4))!
                    if yearInt < fjeStrYear || (yearInt == fjeStrYear && monthInt < fjeStrMonth) || (yearInt == fjeStrYear && monthInt == fjeStrMonth && dayInt < fjeStrDay) {
                        self.firstJournalEntry = true
                    }
                }
                self.locationsVisited = docData["locationsVisited"] as! [String]
                let eqData = docData["userEquipment"] as! Dictionary<String, [String]>
                self.setAutoComp(self.targetField, ["Messier", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"], 0)
                self.setAutoComp(self.locationField, self.locationsVisited, 1)
                self.setAutoComp(self.telescopeField, eqData["telescopes"]!, 2)
                self.setAutoComp(self.mountField, eqData["mounts"]!, 2)
                self.setAutoComp(self.cameraField, eqData["cameras"]!, 2)
                self.userData = docData
            }
        })
        if entryData.count != 0 {
            targetField.isUserInteractionEnabled = false
            targetField.borderStyle = UITextField.BorderStyle.none
            constellationField.isUserInteractionEnabled = false
            
            let entryData = self.entryData
            targetField.text = (entryData["target"] as! String)
            constellationField.text = (entryData["constellation"] as! String)
            locationField.text = (entryData["locations"] as! [String]).joined(separator: ", ")
            timeStartField.text = (entryData["timeStart"] as! String)
            timeEndField.text = (entryData["timeEnd"] as! String)
            if (entryData["observed"] as? Bool ?? false) {
                observedCheckImage.image = UIImage(named: "ViewEntry/checkmark")
                observedSelected = true
            }
            if (entryData["photographed"] as? Bool ?? false) {
                photographedCheckImage.image = UIImage(named: "ViewEntry/checkmark")
                photographedSelected = true
            }
            memoriesField.text = (entryData["memories"] as! String)
            telescopeField.text = (entryData["telescope"] as! String)
            mountField.text = (entryData["mount"] as! String)
            cameraField.text = (entryData["camera"] as! String)
            acquisitionField.text = (entryData["acquisition"] as! String)
            mainImageKey = (entryData["mainImageKey"] as! String)
            if mainImageKey != "" {
                bigImageViewText.text = "Tap to add main image"
                bigImageViewText.isHidden = true
                mainImage = (entryData["mainImage"] as! UIImage)
                bigImageView.image = mainImage
                featuredDate = entryData["featuredDate"] as! String
                if featuredDate == "" || !isEarlierDate(date1: featuredDate, date2: dateToday) {
                    bigImageViewRemoveButton.isHidden = false
                } else {
                    photographedCheckBox.isUserInteractionEnabled = false
                }
            }
            imageKeyList = entryData["imageKeys"] as! [String]
            if imageKeyList != [] {
                for i in 0...(entryData["imageList"] as! Dictionary<Int, UIImage>).count - 1 {
                    imageList.append((entryData["imageList"] as! Dictionary<Int, UIImage>)[i]!)
                    imageDataList.append(NSData() as Data)
                }
                if imageList.count == 3 {
                    attachImageButton.isHidden = true
                }
            }
            deleteButton.isHidden = false
        }
        acquisitionField.autocapitalizationType = .none
        acquisitionField.autocorrectionType = .yes
        memoriesField.autocapitalizationType = .none
        memoriesField.autocorrectionType = .yes
        endNoInput()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! JournalEntryEditImageCell
        cell.imageView.image = imageList[indexPath.row]
        let xLabel = UILabel(frame: CGRect(x: cell.frame.width - 13, y: 0, width: 25, height: 20))
        xLabel.text = "X"
        xLabel.textColor = UIColor.white
        xLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeImageCollectionViewImage)))
        xLabel.isUserInteractionEnabled = true
        cell.addSubview(xLabel)
        return cell
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        activeField?.resignFirstResponder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == targetField || textField == locationField {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else {
            if screenH < 1000 {//iphones
                scrollView.setContentOffset(CGPoint(x: 0, y: acquisitionField.frame.origin.y - (screenH * 0.25)), animated: true)
            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: acquisitionField.frame.origin.y - (screenH * 0.4)), animated: true)
            }
        }
        activeField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == targetField && targetField.text != "" {
            let inp = formatTarget(inputTarget: targetField.text!)
            if  inp.count > 1 && inp.prefix(1) == "M" && MessierConst[Int(String(inp.suffix(inp.count - 1))) ?? -1] != nil {
                constellationField.text = MessierConst[Int(String(inp.suffix(inp.count - 1)))!]
            } else if inp.count > 3 && inp.prefix(3) == "NGC" && NGCConst[Int(String(inp.suffix(inp.count - 3))) ?? -1] != nil {
                constellationField.text = NGCConst[Int(String(inp.suffix(inp.count - 3)))!]
            } else if inp.count > 2 && inp.prefix(2) == "IC" && ICConst[Int(String(inp.suffix(inp.count - 2))) ?? -1] != nil {
                constellationField.text = ICConst[Int(String(inp.suffix(inp.count - 2)))!]
            } else {
                constellationField.text = ""
            }
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = toolbar
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if screenH < 1000 {//iphones
            if screenH < 600 {//iphone SE, 5s
                scrollView.setContentOffset(CGPoint(x: 0, y: textView.frame.origin.y - (screenH * 0.11)), animated: true)
            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: textView.frame.origin.y - (screenH * 0.25)), animated: true)
            }
        } else {
            if screenH < 1150 && textView == memoriesField {
                scrollView.setContentOffset(CGPoint(x: 0, y: memoriesField.frame.origin.y - (screenH * 0.3)), animated: true)
            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: acquisitionField.frame.origin.y - (screenH * 0.4)), animated: true)
            }
        }
        activeField = textView
    }
    func textViewShouldReturn(_ textView: UITextField) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    @IBAction func textFieldEditingDidChange(_ sender: Any) {
        if targetField.text!.contains(",") {
            multTargetWarning.isHidden = false
        } else {
            multTargetWarning.isHidden = true
        }
    }
    @IBAction func toolbarButtonTapped(_ sender: Any) {
        view.endEditing(true)
    }
    @IBAction func observedCheckboxTapped(_ sender: Any) {
        if !observedSelected {
            observedCheckImage.image = UIImage(named: "ViewEntry/checkmark")
            observedSelected = true
        } else {
            observedCheckImage.image = nil
            observedSelected = false
        }
        activeField?.resignFirstResponder()
    }
    @IBAction func photographedCheckboxTapped(_ sender: Any) {
        if !photographedSelected {
            photographedCheckImage.image = UIImage(named: "ViewEntry/checkmark")
            photographedSelected = true
            if mainImage != nil {
                bigImageViewText.isHidden = true
                bigImageView.image = mainImage
                bigImageViewRemoveButton.isHidden = false
            } else {
                bigImageViewText.text = "Tap to add main image"
            }
        } else {
            photographedCheckImage.image = nil
            photographedSelected = false
            bigImageView.image = nil
            bigImageViewRemoveButton.isHidden = true
            bigImageViewText.isHidden = false
            bigImageViewText.text = "No main image if not photographed"
        }
        activeField?.resignFirstResponder()
    }
    @IBAction func timeStartButton(_ sender: Any) {
        activeField?.resignFirstResponder()
        if scrollView.contentOffset.y != 0 {
            showingTimeStartDropDown = true
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else {
            timeStartDropDown?.show()
        }
    }
    @IBAction func timeEndButton(_ sender: Any) {
        activeField?.resignFirstResponder()
        if scrollView.contentOffset.y != 0 {
            showingTimeEndDropDown = true
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else {
            timeEndDropDown?.show()
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if showingTimeStartDropDown {
            timeStartDropDown?.show()
            showingTimeStartDropDown = false
        } else if showingTimeEndDropDown {
            timeEndDropDown?.show()
            showingTimeEndDropDown = false
        }
    }
    @IBAction func attachImage(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        present(image, animated: true) {
            //after completion
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: true, completion: nil)
            view.addSubview(formatLoadingIcon(icon: loadingIcon))
            loadingIcon.startAnimating()
            let newImageData = resizeByByte(img: newImage, maxByte: 1024 * 1024 * 3)
            loadingIcon.stopAnimating()
            if newImageData == nil {
                let alertController = UIAlertController(title: "Error", message: "The image size is too big. Please choose another image. Max size: 7 MB", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                if bigImageViewTapped {
                    bigImageViewText.isHidden = true
                    bigImageView.image = newImage
                    bigImageViewRemoveButton.isHidden = false
                    if (entryData["mainImageKey"] as? String ?? "") != "" {
                        mainImageKey = entryData["mainImageKey"] as! String
                        mainImageUpdated = true
                    } else {
                        mainImageKey = NSUUID().uuidString
                    }
                    mainImage = newImage
                    mainImageData = newImageData![0]
                    bigImageViewTapped = false
                } else {
                    imageKeyList.append(NSUUID().uuidString)
                    imageList.append(newImage)
                    imageDataList.append(newImageData![0])
                    imageCollectionView.insertItems(at: [IndexPath(row: imageList.count - 1, section: 0)])
                    if imageList.count == 3 {
                        attachImageButton.isHidden = true
                    }
                }
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func bigImageTapped(_ sender: Any) {
        if !photographedSelected {
            return
        }
        if bigImageView.image == nil {
            bigImageViewTapped = true
            attachImage("")
        } else {
            imageSelected = bigImageView.image
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
            self.addChild(popOverVC)
            let f = self.view.frame
            popOverVC.view.frame = CGRect(x: 0, y: 0, width: f.width, height: f.height)
            self.view.addSubview(popOverVC.view)
            popOverVC.imageView.image = imageSelected
            popOverVC.didMove(toParent: self)
        }
    }
    @IBAction func imageCollectionViewTapped(_ sender: UITapGestureRecognizer) {
        let touch = sender.location(in: imageCollectionView)
        let indexPath = imageCollectionView.indexPathForItem(at: touch)
        if indexPath == nil {
            return
        }
        imageSelected = (imageCollectionView.cellForItem(at: indexPath!) as! JournalEntryEditImageCell).imageView.image
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
        self.addChild(popOverVC)
        let f = self.view.frame
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: f.width, height: f.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.imageView.image = imageSelected
        popOverVC.didMove(toParent: self)
    }
    @IBAction func removeBigImage(_ sender: Any) {
        if doneButton.isHidden {return}
        bigImageView.image = nil
        bigImageViewRemoveButton.isHidden = true
        bigImageViewText.isHidden = false
        mainImageKey = ""
        mainImageData = nil
        mainImage = nil
    }
    @objc func removeImageCollectionViewImage(_ sender: UITapGestureRecognizer) {
        if doneButton.isHidden {return}
        let indexPath = imageCollectionView.indexPathForItem(at: sender.location(in: imageCollectionView))
        let i = indexPath!.row
        imageKeyList.remove(at: i)
        imageDataList.remove(at: i)
        imageList.remove(at: i)
        imageCollectionView.deleteItems(at: [indexPath!])
        attachImageButton.isHidden = false
    }
    func processInput(inp: String) -> [String] {
        let inpStripped = inp.trimmingCharacters(in: .whitespacesAndNewlines) + ","
        var res: [String] = []
        var word = ""
        var wordStarted = false
        var prevSpace = false
        var wordsSeen = Set<String>()
        for c in inpStripped {
            if !wordStarted {
                if c != " " && c != "," {
                    word.append(c)
                    wordStarted = true
                }
            } else {
                if c != " " && c != "," {
                    word.append(c)
                    prevSpace = false
                } else if c == " " {
                    if !prevSpace {
                        word.append(c)
                        prevSpace = true
                    }
                } else if c == "," {
                    if prevSpace {
                        word.remove(at: word.index(word.startIndex, offsetBy: word.count - 1))
                        prevSpace = false
                    }
                    wordStarted = false
                    if !wordsSeen.contains(word) {
                        res.append(word)
                        wordsSeen.insert(word)
                    }
                    word = ""
                }
            }
        }
        return res
    }
    func updateDict(dict: inout Dictionary<String, Any>, t: String, inc: Bool, dateDictType: String) {
        if inc {
            if dict[t] == nil {
                if dateDictType != "" {
                    dict[t] = [self.entryDate]
                    if self.cvc?.cardUnlocked == "" && dateDictType == "photo" {
                        self.cvc?.cardUnlocked = t
                        self.cvc?.unlockedDate = entryDate
                    }
                } else {
                    dict[t] = 1
                }
            } else {
                if dateDictType != "" {
                    var dates = dict[t] as! [String]
                    let date = self.entryDate
                    let curYear = date.suffix(4)
                    let curMonth = date.prefix(2)
                    let curDay = date.prefix(4).suffix(2)
                    var year = ""
                    var month = ""
                    var day = ""
                    var indToInsert = 0
                    for i in 0...dates.count - 1 {
                        year = String(dates[i].suffix(4))
                        month = String(dates[i].prefix(2))
                        day = String(dates[i].prefix(4).suffix(2))
                        if (curYear > year) || (curYear == year && curMonth > month) || (curYear == year && curMonth == month && curDay > day) {
                            indToInsert = i
                            break
                        }
                        if i == dates.count - 1 {
                            indToInsert = dates.count
                        }
                    }
                    dates.insert(date, at: indToInsert)
                    dict[t] = dates
                } else {
                    dict[t] = dict[t] as! Int + 1
                }
            }
        } else {
            if dateDictType != "" {
                var dates = dict[t] as! [String]
                if dates.count > 1 {
                    dates.remove(at: dates.firstIndex(of: self.entryDate)!)
                    dict[t] = dates
                } else {
                    dict.removeValue(forKey: t)
                }
            } else {
                if dict[t] as! Int > 1 {
                    dict[t] = (dict[t] as! Int) - 1
                } else {
                    dict.removeValue(forKey: t)
                }
            }
        }
    }
    func removeIodData() {
        if featuredDate != "" && featuredDate == featuredImageDate {//currently being featured
            db.collection("imageOfDayKeys").document(featuredDate).setData([:], merge: false)
        } else {//will be or was featured
            db.collection("imageOfDayKeys").document(featuredDate).delete()
        }
        db.collection("imageOfDayLikes").document(featuredDate).delete()
        db.collection("imageOfDayComments").document(featuredDate).delete()
        var alertDates = userData["featuredAlertDates"] as! [String]
        if alertDates.contains(featuredDate) {
            alertDates.remove(at: alertDates.index(of: featuredDate)!)
        }
        let copyKey = (userData["userDataCopyKeys"] as! [String: String])[featuredDate]!
        db.collection("userData").document(userKey).setData(["featuredAlertDates": alertDates, "userDataCopyKeys": [featuredDate: FieldValue.delete()]], merge: true)
        db.collection("userData").document(copyKey).delete()
        
        var t = target
        if t == "" {t = formattedTarget}
        if isEarlierDate(date1: dateToday, date2: featuredDate) {
            //notify Antoine
            db.collection("iodDeletedNotifications").document(featuredDate).setData(["target": t])
        }
    }
    func processDone() {
        attachImageButton.isHidden = true
        doneButton.isHidden = true
        deleteButton.isHidden = true
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
        loadingIcon.startAnimating()
        if entryData.count == 0 {
            if newEntries[formattedTarget] == nil {
                newEntries[formattedTarget] = [entryDate]
            } else {
                newEntries[formattedTarget]!.append(entryDate)
            }
            if otherTarget != "" {
                if newEntries[otherTarget] == nil {
                    newEntries[otherTarget] = [entryDate]
                } else {
                    newEntries[otherTarget]!.append(entryDate)
                }
            }
            if photographedSelected {
                if newEntriesPhoto[formattedTarget] == nil {
                   newEntriesPhoto[formattedTarget] = [entryDate]
                } else {
                    newEntriesPhoto[formattedTarget]!.append(entryDate)
                }
                if otherTarget != "" {
                    if newEntriesPhoto[otherTarget] == nil {
                        newEntriesPhoto[otherTarget] = [entryDate]
                    } else {
                        newEntriesPhoto[otherTarget]!.append(entryDate)
                    }
                }
            }
        }
        let constellation = constellationField.text!
        let locations = processInput(inp: locationField.text!)
        for location in locations {
            if !locationsVisited.contains(location) {
                locationsVisited.append(location)
            }
        }
        if !photographedSelected {
            mainImageKey = ""
            mainImage = nil
        }
        let tel = telescopeField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cam = cameraField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let mount = mountField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var newEntryData = ["constellation": constellation, "target": target, "formattedTarget": formattedTarget, "observed": observedSelected, "photographed": photographedSelected, "locations": locations, "timeStart": timeStartField.text!, "timeEnd": timeEndField.text!, "numHours": numHours, "telescope": tel, "camera": cam, "mount": mount, "memories": memoriesField.text!, "acquisition": acquisitionField.text!, "mainImageKey": mainImageKey, "imageKeys": imageKeyList, "featuredDate": featuredDate] as [String : Any]
        if (entryData["mainImageKey"] as? String ?? "") != "" && mainImageKey == "" {//if picked to be featured, deselect entry as iod bc images was removed
            newEntryData["featuredDate"] = ""
        }
        var dataToPut: Dictionary<String, Any> = [:]
        let userName = KeychainWrapper.standard.string(forKey: "userName")!
        if entryData.count == 0 {
            if entryList.count == 0 {
                dataToPut = ["data": [newEntryData], "userName": userName]
            } else {
                entryList.append(newEntryData)
                dataToPut = ["data": entryList, "userName": userName]
            }
        } else {
            entryList[selectedEntryInd] = newEntryData
            dataToPut = ["data": entryList, "userName": userName]
        }
        db.collection("journalEntries").document(userKey + entryDate).setData(dataToPut, merge: false)
        
        var cardTargetDatesDict: Dictionary<String, Any> = userData["cardTargetDates"] as! Dictionary<String, [String]>
        var photoCardTargetDatesDict: Dictionary<String, Any> = userData["photoCardTargetDates"] as! Dictionary<String, [String]>
        var photoTargetNumDict: Dictionary<String, Any> = userData["photoTargetNum"] as! Dictionary<String, Int>
        var obsTargetNumDict: Dictionary<String, Any> = userData["obsTargetNum"] as! Dictionary<String, Int>
        var totalHours = userData["totalHours"] as! Int

        func cardListContainsTarget(_ target: String) -> Bool {
            return (target.count > 1 && target.prefix(1) == "M" &&  MessierTargets.contains(target)) || (target.count > 3 && target.prefix(3) == "NGC" &&  NGCTargets.contains(target)) || (target.count > 2 && target.prefix(2) == "IC" &&  ICTargets.contains(target)) || (PlanetTargets.contains(target))
        }
        if entryData.count == 0 {
            if cardListContainsTarget(formattedTarget) {
                updateDict(dict: &cardTargetDatesDict, t: formattedTarget, inc: true, dateDictType: "normal")
                if otherTarget != "" {
                    updateDict(dict: &cardTargetDatesDict, t: otherTarget, inc: true, dateDictType: "normal")
                }
            }
            if observedSelected {
                updateDict(dict: &obsTargetNumDict, t: formattedTarget, inc: true, dateDictType: "")
                if otherTarget != "" {
                    updateDict(dict: &obsTargetNumDict, t: otherTarget, inc: true, dateDictType: "")
                }
            }
            if photographedSelected {
                if cardListContainsTarget(formattedTarget) {
                    updateDict(dict: &photoCardTargetDatesDict, t: formattedTarget, inc: true, dateDictType: "photo")
                    if otherTarget != "" {
                        updateDict(dict: &photoCardTargetDatesDict, t: otherTarget, inc: true, dateDictType: "photo")
                    }
                }
                updateDict(dict: &photoTargetNumDict, t: formattedTarget, inc: true, dateDictType: "")
                if otherTarget != "" {
                    updateDict(dict: &photoTargetNumDict, t: otherTarget, inc: true, dateDictType: "")
                }
            }
        } else {
            if !(entryData["observed"] as? Bool ?? false) && observedSelected {
                updateDict(dict: &obsTargetNumDict, t: formattedTarget, inc: true, dateDictType: "")
                if otherTarget != "" {
                    updateDict(dict: &obsTargetNumDict, t: otherTarget, inc: true, dateDictType: "")
                }
            }
            else if (entryData["observed"] as? Bool ?? false) && !observedSelected {
                updateDict(dict: &obsTargetNumDict, t: formattedTarget, inc: false, dateDictType: "")
                if otherTarget != "" {
                    updateDict(dict: &obsTargetNumDict, t: otherTarget, inc: false, dateDictType: "")
                }
            }
            if !(entryData["photographed"] as? Bool ?? false) && photographedSelected {
                if cardListContainsTarget(formattedTarget) {
                    updateDict(dict: &photoCardTargetDatesDict, t: formattedTarget, inc: true, dateDictType: "photo")
                    if otherTarget != "" {
                        updateDict(dict: &photoCardTargetDatesDict, t: otherTarget, inc: true, dateDictType: "photo")
                    }
                    if newEntriesPhoto[formattedTarget] == nil {
                       newEntriesPhoto[formattedTarget] = [entryDate]
                    } else {
                        newEntriesPhoto[formattedTarget]!.append(entryDate)
                    }
                    if otherTarget != "" {
                        if newEntriesPhoto[otherTarget] == nil {
                           newEntriesPhoto[otherTarget] = [entryDate]
                        } else {
                            newEntriesPhoto[otherTarget]!.append(entryDate)
                        }
                    }
                }
                updateDict(dict: &photoTargetNumDict, t: formattedTarget, inc: true, dateDictType: "")
                if otherTarget != "" {
                    updateDict(dict: &photoTargetNumDict, t: otherTarget, inc: true, dateDictType: "")
                }
            }
            else if (entryData["photographed"] as? Bool ?? false) && !photographedSelected {
                if cardListContainsTarget(formattedTarget) && photoCardTargetDatesDict[formattedTarget] != nil {
                    updateDict(dict: &photoCardTargetDatesDict, t: formattedTarget, inc: false, dateDictType: "photo")
                    if otherTarget != "" {
                        updateDict(dict: &photoCardTargetDatesDict, t: otherTarget, inc: false, dateDictType: "photo")
                    }
                    if deletedEntriesPhoto[formattedTarget] == nil {
                       deletedEntriesPhoto[formattedTarget] = [entryDate]
                    } else {
                        deletedEntriesPhoto[formattedTarget]!.append(entryDate)
                    }
                    if otherTarget != "" {
                        if deletedEntriesPhoto[otherTarget] == nil {
                           deletedEntriesPhoto[otherTarget] = [entryDate]
                        } else {
                            deletedEntriesPhoto[otherTarget]!.append(entryDate)
                        }
                    }
                }
                updateDict(dict: &photoTargetNumDict, t: formattedTarget, inc: false, dateDictType: "")
                if otherTarget != "" {
                    updateDict(dict: &photoTargetNumDict, t: otherTarget, inc: false, dateDictType: "")
                }
            }
        }
        var numEntriesInDate = userData["numEntriesInDate"] as! [String: Int]
        var newTotalHours = totalHours
        if entryData.count == 0 {
            if numEntriesInDate[entryDate] == nil {
                numEntriesInDate[entryDate] = 1
            } else {
                numEntriesInDate[entryDate] = numEntriesInDate[entryDate]! + 1
            }
            newTotalHours += numHours
        } else {
            newTotalHours += numHours - (entryData["numHours"] as! Int)
        }
        userData["numEntriesInDate"] = numEntriesInDate
        userData["locationsVisited"] = locationsVisited
        userData["cardTargetDates"] = cardTargetDatesDict
        userData["photoCardTargetDates"] = photoCardTargetDatesDict
        userData["photoTargetNum"] = photoTargetNumDict
        userData["obsTargetNum"] = obsTargetNumDict
        userData["totalHours"] = newTotalHours
        if firstJournalEntry {
            userData["firstJournalEntryDate"] = entryDate
        }
        cvc!.numEntriesDict = numEntriesInDate
        db.collection("userData").document(userKey).setData(userData, merge: false)
        let copyKeys = userData["userDataCopyKeys"] as! [String: String]
        if copyKeys.count != 0 {
            for (date, key) in copyKeys {
                if date == featuredImageDate || isEarlierDate(date1: dateToday, date2: date) {
                    db.collection("userData").document(key).setData(["photoTargetNum": userData["photoTargetNum"]!, "obsTargetNum": userData["obsTargetNum"]!, "totalHours": userData["totalHours"]!], merge: true)
                }
            }
        }
        
        var addedMainImageKey = ""
        var removedMainImageKey = ""
        let originalMainImageKey = entryData["mainImageKey"] as? String ?? ""
        if mainImageKey != "" {
            if originalMainImageKey == "" || mainImageUpdated {
                addedMainImageKey = mainImageKey
            }
        } else if originalMainImageKey != "" {
            removedMainImageKey = originalMainImageKey
        }
        var addedImageKeyList: [String] = []
        var removedImageKeyList: [String] = []
        var originalImageKeys = entryData["imageKeys"] as? [String] ?? []
        let originalImageKeyNum = originalImageKeys.count
        if originalImageKeyNum != 0 {
            for imageKey in imageKeyList {
                for i in 0...originalImageKeyNum - 1 {
                    if imageKey == originalImageKeys[i] {
                        originalImageKeys[i] = ""
                        break
                    }
                    if i == originalImageKeyNum - 1 {
                        addedImageKeyList.append(imageKey)
                    }
                }
            }
            for imageKey in originalImageKeys {
                if imageKey != "" {
                    removedImageKeyList.append(imageKey)
                }
            }
        } else {
            addedImageKeyList = imageKeyList
        }
        //no change in image set
        if addedMainImageKey == "" && removedMainImageKey == "" && addedImageKeyList == [] && removedImageKeyList == [] {
            //new first entry for this day
            if entryData.count == 0 && entryList.count == 0 {
                db.collection("userData").document(userKey).setData(["calendarImages": [entryDate: ""]], merge: true)
                cvc?.editedEntryDate = entryDate
                cvc?.newImage = UIImage(named: "Calendar/placeholder")
            }
            navigationController?.popToRootViewController(animated: true)
            return
        } else {
            var dataRef: StorageReference
            
            func manageCalendarImages() {
                //check previous entries in the same day for main image
                if selectedEntryInd != 0 {
                    for i in 0...selectedEntryInd - 1 {
                        if (entryList[i]["mainImageKey"] as! String) != "" {
                            self.navigationController?.popToRootViewController(animated: true)
                            return
                        }
                    }
                }
                //no change in current entry's main image
                if (entryData.count != 0 && originalMainImageKey == "" && mainImageKey == "") || (originalMainImageKey != "" && removedMainImageKey == "" && !mainImageUpdated) {
                    self.navigationController?.popToRootViewController(animated: true)
                    return
                }
                cvc?.editedEntryDate = entryDate
                var calImageKey = ""
                func finishManageCalendarImages() {
                    //store image key as calendar image key and return to previous page
                    db.collection("userData").document(userKey).setData(["calendarImages": [entryDate: calImageKey]], merge: true)
                    self.navigationController?.popToRootViewController(animated: true)
                }
                //use current main image
                if mainImageKey != "" {
                    calImageKey = mainImageKey
                    cvc?.newImage = bigImageView.image
                    finishManageCalendarImages()
                    return
                }
                cvc?.newImage = UIImage(named: "Calendar/placeholder")!
                //check later entries in the same day for main image
                if entryList.count > selectedEntryInd + 1 {
                    for i in selectedEntryInd + 1...entryList.count - 1 {
                        //main image found
                        if (entryList[i]["mainImageKey"] as! String) != "" {
                            calImageKey = entryList[i]["mainImageKey"] as! String
                            break
                        }
                    }
                    if calImageKey != "" {
                        //get image data from db
                        let imageRef = storage.child(calImageKey)
                        imageRef.getData(maxSize: 1024 * 1024 * 3) {data, Error in
                            if let Error = Error {
                                print(Error)
                                return
                            } else {
                                self.cvc?.newImage = UIImage(data: data!)
                                finishManageCalendarImages()
                                return
                            }
                        }
                        //no main image in later entries
                    } else {
                        finishManageCalendarImages()
                        return
                    }
                    //there are no later entries
                } else {
                    finishManageCalendarImages()
                    return
                }
            }
            func storeImages(imagesRemoved: Bool) {
                for i in 0...addedImageKeyList.count - 1 {
                    let imageKey = addedImageKeyList[i]
                    let dataRef = storage.child(imageKey)
                    var imageToPut: Data? = nil
                    if imageKeyList.index(of: imageKey) == nil {
                        imageToPut = mainImageData
                    } else {
                        imageToPut = imageDataList[imageKeyList.index(of: imageKey)!]
                    }
                    dataRef.putData(imageToPut!, metadata: nil) {(metadata, error) in
                        if error != nil {
                            print(error as Any)
                            return
                        } else {
                            print("done storing new journal entry image #" + String(i))
                            if i == addedImageKeyList.count - 1 {
                                if imagesRemoved {
                                    deleteImages()
                                } else {
                                    manageCalendarImages()
                                }
                                return
                            }
                        }
                    }
                }
            }
            func deleteImages() {
                for i in 0...removedImageKeyList.count - 1 {
                    let imageKey = removedImageKeyList[i]
                    let dataRef = storage.child(imageKey)
                    dataRef.delete {error in
                        if error != nil {
                            print(error as Any)
                            return
                        } else {
                            print("done deleting journal entry image #" + String(i))
                            if i == removedImageKeyList.count - 1 {
                                manageCalendarImages()
                                return
                            }
                        }
                    }
                }
            }
            if addedMainImageKey != "" {addedImageKeyList.append(addedMainImageKey)}
            if removedMainImageKey != "" {
                removedImageKeyList.append(removedMainImageKey)
                if featuredDate != "" {
                    removeIodData()
                }
            }
            if addedImageKeyList != [] {
                storeImages(imagesRemoved: removedImageKeyList != [])
            } else {
                //no extra images added, images removed
                if removedImageKeyList != [] {
                    deleteImages()
                    //no extra images added, no images removed
                } else {
                    manageCalendarImages()
                }
            }
        }
    }
    
    
    @IBAction func done(_ sender: Any) {
        //if target or constellation was left blank, show alert
        if targetField.text == "" || locationField.text == "" || (!observedSelected && !photographedSelected) {
            let alertController = UIAlertController(title: "Error", message: "Target, time, location, oberved or photographed must not be left blank.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let targets = processInput(inp: targetField.text!)
        if targets.count > 1 {
            let alertController = UIAlertController(title: "Error", message: "Only one target per entry allowed. But more than one entry per day is allowed if different targets.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        var duplicateTargets = false
        self.target = targets[0]
        self.formattedTarget = formatTarget(inputTarget: target)
        //these targets appear together
        otherTarget = doubleTargets[formattedTarget] ?? ""
        for entry in entryList {
            if (entry["formattedTarget"] as! String) == formattedTarget || (entry["formattedTarget"] as! String) == otherTarget {
                duplicateTargets = true
            }
        }
        if entryData.count == 0 && duplicateTargets {
            let alertController = UIAlertController(title: "Error", message: "Two entries in a day with the same target is not allowed.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if photographedSelected && mainImageKey == "" {
            let alertController = UIAlertController(title: "Error", message: "Main image is required if target was photographed", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let timeStart = timeStartField.text!
        var timeStartInt = 0
        if timeStart != "12AM" {
            if timeStart.count < 4 {
                timeStartInt = Int(timeStart.prefix(1))!
            } else {
                timeStartInt = Int(timeStart.prefix(2))!
            }
        }
        if timeStart.prefix(2) != "12" && timeStart.suffix(2) == "PM" {
            timeStartInt += 12
        }
        let timeEnd = timeEndField.text!
        var timeEndInt = 0
        if timeEnd != "12AM" {
            if timeEnd.count < 4 {
                timeEndInt = Int(timeEnd.prefix(1))!
            } else {
                timeEndInt = Int(timeEnd.prefix(2))!
            }
        }
        if timeEnd.prefix(2) != "12" && timeEnd.suffix(2) == "PM" {
            timeEndInt += 12
        }
        numHours = timeEndInt - timeStartInt
        if numHours < 0 {
            numHours += 24
        }
        if (entryData["photographed"] as? Bool ?? false) && !photographedSelected {
            let alertController = UIAlertController(title: "Warning", message: "Unchecking photographed will delete the main image for this journal entry, and may delete a card from your card collection. Do you want to continue?", preferredStyle: .alert)
            func continueDone(_: UIAlertAction) {
                processDone()
            }
            let continueAction = UIAlertAction(title: "Yes", style: .default, handler: continueDone)
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertController.addAction(continueAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        processDone()
    }
    func deleteEntry(_ alertAction: UIAlertAction) {
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
        loadingIcon.startAnimating()
        let formattedTarget = formatTarget(inputTarget: targetField.text!)
        //these targets appear together
        otherTarget = doubleTargets[formattedTarget] ?? ""
        if deletedEntries[formattedTarget] == nil {
           deletedEntries[formattedTarget] = [entryDate]
        } else {
            deletedEntries[formattedTarget]!.append(entryDate)
        }
        if otherTarget != "" {
            if deletedEntries[otherTarget] == nil {
               deletedEntries[otherTarget] = [entryDate]
            } else {
                deletedEntries[otherTarget]!.append(entryDate)
            }
        }
        let entryDoc = db.collection("journalEntries").document(userKey + entryDate)
        if entryList.count > 1 {
            //delete journal entry from list
            entryList.remove(at: selectedEntryInd)
            entryDoc.setData(["data": entryList], merge: false)
        } else {
            //delete journal entry document
            entryList = []
            entryDoc.delete(completion: {error in
                if error != nil {
                    print(error as Any)
                    return
                } else {
                    print("entry deleted")
                }
            })
        }
        var dataRef: StorageReference
        var imageKeys = (entryData["imageKeys"] as! [String])
        let mainImageKey = (entryData["mainImageKey"] as! String)
        if mainImageKey != "" {imageKeys.append(mainImageKey)}
        //delete image data
        for imageKey in imageKeys {
            dataRef = storage.child(imageKey)
            dataRef.delete {error in
                if error != nil {
                    print(error as Any)
                    return
                } else {
                    print("image deleted")
                }
            }
        }
        //update user data
        var firstEntryDate = userData["firstJournalEntryDate"] as! String
        var userImageKeys = userData["calendarImages"] as! Dictionary<String, String>
        var numEntriesInDate = userData["numEntriesInDate"] as! [String: Int]
        var cardTargetDatesDict: Dictionary<String, Any> = userData["cardTargetDates"] as! Dictionary<String, [String]>
        var photoCardTargetDatesDict: Dictionary<String, Any> = userData["photoCardTargetDates"] as! Dictionary<String, [String]>
        var photoTargetNumDict: Dictionary<String, Any> = userData["photoTargetNum"] as! Dictionary<String, Int>
        var obsTargetNumDict: Dictionary<String, Any> = userData["obsTargetNum"] as! Dictionary<String, Int>
        var totalHours = userData["totalHours"] as! Int
        
        //update date of first journal entry if deleted entry was the first entry
        if firstEntryDate == entryDate && entryList.count == 0 {
            if (userData["calendarImages"] as! Dictionary<String, String>).count == 1 {
                firstEntryDate = ""
            } else {
                var earliestDate = "99999999"
                for (key, value) in (userData["calendarImages"] as! Dictionary<String, String>) {
                    if key == entryDate {
                        continue
                    }
                    if isEarlierDate(date1: key, date2: earliestDate) {
                        earliestDate = key
                    }
                }
                firstEntryDate = earliestDate
            }
        }
        func finishUserDataUpdate() {
            if entryList.count == 0 {
                numEntriesInDate[entryDate] = nil
            } else {
                numEntriesInDate[entryDate] = numEntriesInDate[entryDate]! - 1
            }
            cvc!.numEntriesDict = numEntriesInDate
            if cardTargetDatesDict[formattedTarget] != nil {
                updateDict(dict: &cardTargetDatesDict, t: formattedTarget, inc: false, dateDictType: "photo")
                if otherTarget != "" {
                    updateDict(dict: &cardTargetDatesDict, t: otherTarget, inc: false, dateDictType: "photo")
                }
            }
            if (entryData["photographed"] as! Bool) {
                if photoCardTargetDatesDict[formattedTarget] != nil {
                    updateDict(dict: &photoCardTargetDatesDict, t: formattedTarget, inc: false, dateDictType: "photo")
                    if otherTarget != "" {
                        updateDict(dict: &photoCardTargetDatesDict, t: otherTarget, inc: false, dateDictType: "photo")
                    }
                    if deletedEntriesPhoto[formattedTarget] == nil {
                       deletedEntriesPhoto[formattedTarget] = [entryDate]
                    } else {
                        deletedEntriesPhoto[formattedTarget]!.append(entryDate)
                    }
                    if otherTarget != "" {
                        if deletedEntriesPhoto[otherTarget] == nil {
                           deletedEntriesPhoto[otherTarget] = [entryDate]
                        } else {
                            deletedEntriesPhoto[otherTarget]!.append(entryDate)
                        }
                    }
                }
                updateDict(dict: &photoTargetNumDict, t: formattedTarget, inc: false, dateDictType: "")
                if otherTarget != "" {
                    updateDict(dict: &photoTargetNumDict, t: otherTarget, inc: false, dateDictType: "")
                }
            }
            if (entryData["observed"] as! Bool) {
                updateDict(dict: &obsTargetNumDict, t: formattedTarget, inc: false, dateDictType: "")
                if otherTarget != "" {
                    updateDict(dict: &obsTargetNumDict, t: otherTarget, inc: false, dateDictType: "")
                }
            }
            let newTotalHours = (userData["totalHours"] as! Int) - (entryData["numHours"] as! Int)
            userData["firstJournalEntryDate"] = firstEntryDate
            userData["calendarImages"] = userImageKeys
            userData["numEntriesInDate"] = numEntriesInDate
            userData["cardTargetDates"] = cardTargetDatesDict
            userData["photoCardTargetDates"] = photoCardTargetDatesDict
            userData["photoTargetNum"] = photoTargetNumDict
            userData["obsTargetNum"] = obsTargetNumDict
            userData["totalHours"] = newTotalHours
            db.collection("userData").document(userKey).setData(userData, merge: false) {err in
                if let err = err {
                    print("Error updating user Data: \(err)")
                } else {
                    print("updated user data")
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            if featuredDate != "" {
                removeIodData()
            }
            //if there is a featured entry on the same day as current entry, fix index in entry list in iod db
            for i in selectedEntryInd..<entryList.count {
                if entryList[i]["featuredDate"] as! String != "" {
                    db.collection("imageOfDayKeys").document(entryList[i]["featuredDate"] as! String).setData(["journalEntryInd": i], merge: true)
                }
            }
        }
        var changeCalendarImage = true
        if selectedEntryInd != 0 {
            for i in 0...selectedEntryInd - 1 {
                if (entryList[i]["mainImageKey"] as! String) != "" {
                    changeCalendarImage = false
                    break
                }
            }
        }
        if entryList.count == 0 {
            userImageKeys.removeValue(forKey: entryDate)
            cvc?.editedEntryDate = entryDate
            cvc?.newImage = nil
            changeCalendarImage = false
        }
        if changeCalendarImage {
            cvc?.editedEntryDate = entryDate
            userImageKeys[entryDate] = ""
            cvc?.newImage = UIImage(named: "Calendar/placeholder")!
            if entryList.count > selectedEntryInd {
                var imageKey = ""
                for i in selectedEntryInd...entryList.count - 1 {
                    if entryList[i]["mainImageKey"] as! String != "" {
                        imageKey = entryList[i]["mainImageKey"] as! String
                        break
                    }
                }
                if imageKey != "" {
                    let imageRef = storage.child(imageKey)
                    imageRef.getData(maxSize: 1024 * 1024 * 3) {data, Error in
                        if let Error = Error {
                            print(Error)
                            return
                        } else {
                            userImageKeys[self.entryDate] = imageKey
                            self.cvc?.newImage = UIImage(data: data!)
                            finishUserDataUpdate()
                            return
                        }
                    }
                } else {
                    finishUserDataUpdate()
                    return
                }
            } else {
                finishUserDataUpdate()
                return
            }
        } else {
            finishUserDataUpdate()
            return
        }
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        var messageStr = "Are you sure you want to delete this journal entry? You may lose some cards from your card collection."
        if featuredDate != "" {
            messageStr += " Also this entry was or is currently being featured"
        }
        let alertController = UIAlertController(title: "Delete Journal Entry", message: messageStr, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .destructive, handler: deleteEntry)
        let action2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }
}


