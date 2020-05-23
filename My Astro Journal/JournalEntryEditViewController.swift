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
    @IBOutlet weak var targetArrow: UIImageView!
    @IBOutlet weak var targetField: UITextField!
    @IBOutlet weak var multTargetWarning: UILabel!
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
    @IBOutlet weak var deleteEntryLeadingCipad: NSLayoutConstraint!
    var entryDate = ""
    var entryList: [Dictionary<String, Any>] = []
    var selectedEntryInd = 0
    var formattedTargetsList: [String]? = nil
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
    var calImageKey = ""
    var calImage: UIImage? = nil
    var calImageData: Data? = nil
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
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH > 1000 {//ipads
            background.image = UIImage(named: "ViewEntry/background-ipad")
            border.image = UIImage(named: "border-ipad")
            targetArrow.image = UIImage(named: "ViewEntry/arrow-ipad")
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: imageCollectionView.bounds.height, height: imageCollectionView.bounds.height)
            imageCollectionView.collectionViewLayout = layout
            if screenH > 1150 {
                deleteEntryLeadingCipad.constant = 40
            }
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
        bigImageView.layer.borderColor = astroOrange
        timeStartDropDown = DropDown()
        timeStartDropDown!.backgroundColor = .darkGray
        timeStartDropDown!.textColor = .white
        timeStartDropDown!.textFont = UIFont(name: "Pacifica Condensed", size: 15)!
        timeStartDropDown!.cellHeight = 34
        timeStartDropDown!.cornerRadius = 10
        timeStartDropDown!.anchorView = timeStartField
        timeStartDropDown!.bottomOffset = CGPoint(x: 0, y: 35)
        timeStartDropDown!.dataSource = ["12AM", "1AM", "2AM", "3AM", "4AM", "5AM", "6AM", "7AM", "8AM", "9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM", "5PM", "6PM", "7PM", "8PM", "9PM", "10PM", "11PM"]
        timeStartDropDown!.selectionAction = {(index: Int, item: String) in
            self.timeStartField.text = item
        }
        timeEndDropDown = DropDown()
        timeEndDropDown!.backgroundColor = .darkGray
        timeEndDropDown!.textColor = .white
        timeEndDropDown!.textFont = UIFont(name: "Pacifica Condensed", size: 15)!
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
        userData = (tabBarController!.viewControllers![0].children[0] as! CalendarViewController).userData!
        if userData["firstJournalEntryDate"] as! String == "" {
            firstJournalEntry = true
        } else {
            let dayInt = Int(entryDate.prefix(4).suffix(2))!
            let yearInt = Int(entryDate.suffix(4))!
            let fjeStr = userData["firstJournalEntryDate"] as! String
            let fjeStrMonth = Int(fjeStr.prefix(2))!
            let fjeStrDay = Int(fjeStr.prefix(4).suffix(2))!
            let fjeStrYear = Int(fjeStr.suffix(4))!
            if yearInt < fjeStrYear || (yearInt == fjeStrYear && monthInt < fjeStrMonth) || (yearInt == fjeStrYear && monthInt == fjeStrMonth && dayInt < fjeStrDay) {
                firstJournalEntry = true
            }
        }
        if (userData["calendarImages"] as! [String: String])[entryDate] != nil {
            calImageKey = (userData["calendarImages"] as! [String: String])[entryDate]!
        }
        locationsVisited = userData["locationsVisited"] as! [String]
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
                if featuredDate == "" || !isEarlierDate(featuredDate, dateToday) {
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
        if entryEditFirstTime {
            let alertController = UIAlertController(title: "Tutorial", message: "First, add the object's name on the top left, the constellation should be recognized automatically! Then, input the time, location, equipment used, and write down your memories from the night. Check Observed if you have seen the object through an eyepiece, and Photographed if you have captured the target and are proud of the result! Besides your final image, you can also add 3 extra photographs from the night. ", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            entryEditFirstTime = false
        }
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if screenH < 600 {//iphone SE, 5s
            targetFieldWC.constant = 140
            arrowWC.constant = 130
            mountFieldWC.constant = 98
        }
        setAutoComp(targetField, ["Messier", "Sharpless", "SH2-", "Milky Way", "Rho Ophiuchi", "XSS J16271-2423", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"], 0)
        setAutoComp(locationField, locationsVisited, 1)
        let eqData = userData["userEquipment"] as! Dictionary<String, [String]>
        setAutoComp(telescopeField, eqData["telescopes"]!, 2)
        setAutoComp(mountField, eqData["mounts"]!, 2)
        setAutoComp(cameraField, eqData["cameras"]!, 2)
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
            let inp = formatTarget(targetField.text!)
            if  inp.prefix(1) == "M" && MessierConst[Int(String(inp.suffix(inp.count - 1))) ?? -1] != nil {
                constellationField.text = MessierConst[Int(String(inp.suffix(inp.count - 1)))!]
            } else if inp.prefix(3) == "NGC" && NGCConst[Int(String(inp.suffix(inp.count - 3))) ?? -1] != nil {
                constellationField.text = NGCConst[Int(String(inp.suffix(inp.count - 3)))!]
            } else if inp.prefix(2) == "IC" && ICConst[Int(String(inp.suffix(inp.count - 2))) ?? -1] != nil {
                constellationField.text = ICConst[Int(String(inp.suffix(inp.count - 2)))!]
            } else if inp.prefix(4) == "SH2-" && SharplessConst[Int(String(inp.suffix(inp.count - 4))) ?? -1] != nil {
                constellationField.text = SharplessConst[Int(String(inp.suffix(inp.count - 4)))!]
            } else if OthersConst[inp] != nil {
                constellationField.text = OthersConst[inp]
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
            self.dismiss(animated: true, completion: {
                let processRes = processImage(inpImg: newImage)
                if processRes == nil {
                    let alertController = UIAlertController(title: "Error", message: imageTooBigMessage, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let processedImage = (processRes![0] as! UIImage)
                    let processResCompressed = processImageAndResize(inpImg: processedImage, resizeTo: CGSize(width: calCellSize, height: calCellSize), clip: true)
                    if self.bigImageViewTapped {
                        self.mainImageData = (processRes![1] as! Data)
                        self.mainImage = processedImage
                        self.calImageData = (processResCompressed![1] as! Data)
                        self.calImage = (processResCompressed![0] as! UIImage)
                        self.bigImageView.image = processedImage
                        self.bigImageViewRemoveButton.isHidden = false
                        self.bigImageViewText.isHidden = true
                        if (self.entryData["mainImageKey"] as? String ?? "") != "" {
                            self.mainImageKey = self.entryData["mainImageKey"] as! String
                            self.mainImageUpdated = true
                        } else {
                            self.mainImageKey = NSUUID().uuidString
                        }
                        self.calImageKey = (self.userData["calendarImages"] as! [String: String])[self.entryDate] ?? ""
                        if self.calImageKey == "" {self.calImageKey = NSUUID().uuidString}
                        self.bigImageViewTapped = false
                    } else {
                        self.imageDataList.append((processRes![1] as! Data))
                        self.imageKeyList.append(NSUUID().uuidString)
                        self.imageList.append(processedImage)
                        self.imageCollectionView.insertItems(at: [IndexPath(row: self.imageList.count - 1, section: 0)])
                        if self.imageList.count == 3 {
                            self.attachImageButton.isHidden = true
                        }
                    }
                }
            })
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
            popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
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
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
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
        mainImage = nil
        mainImageData = nil
        calImageKey = ""
        calImage = nil
        calImageData = nil
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
                    //check if card unlocked animation should show
                    var cardPurchased = true
                    let packsUnlocked = userData["packsUnlocked"]! as! [String: Bool]
                    if ((Pack1Targets.contains(t) && packsUnlocked["1"] == nil) || (Pack2Targets.contains(t) && packsUnlocked["2"] == nil) || (Pack3Targets.contains(t) && packsUnlocked["3"] == nil) || (Pack4Targets.contains(t) && packsUnlocked["4"] == nil)) {
                        cardPurchased = false
                    }
                    if cardPurchased && self.cvc?.cardUnlocked == "" && dateDictType == "photo" {
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
    func deleteIodData() {
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
        
        if isEarlierDate(dateToday, featuredDate) {
            //notify Antoine
            db.collection("iodDeletedNotifications").document(featuredDate).setData(["target": formattedTarget])
        }
    }
    func processDone() {
        attachImageButton.isHidden = true
        doneButton.isHidden = true
        deleteButton.isHidden = true
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
        loadingIcon.startAnimating()
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
            mainImageData = nil
            calImageKey = ""
            calImage = nil
            calImageData = nil
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
                dataToPut = ["data": [newEntryData], "formattedTargets": [formattedTarget], "userName": userName]
            } else {
                entryList.append(newEntryData)
                formattedTargetsList!.append(formattedTarget)
                dataToPut = ["data": entryList, "formattedTargets": formattedTargetsList!, "userName": userName]
            }
        } else {
            entryList[selectedEntryInd] = newEntryData
            dataToPut = ["data": entryList, "formattedTargets": formattedTargetsList!, "userName": userName]
        }
        db.collection("journalEntries").document(userKey + entryDate).setData(dataToPut, merge: false)
        
        var cardTargetDatesDict: Dictionary<String, Any> = userData["cardTargetDates"] as! Dictionary<String, [String]>
        var photoCardTargetDatesDict: Dictionary<String, Any> = userData["photoCardTargetDates"] as! Dictionary<String, [String]>
        var photoTargetNumDict: Dictionary<String, Any> = userData["photoTargetNum"] as! Dictionary<String, Int>
        var obsTargetNumDict: Dictionary<String, Any> = userData["obsTargetNum"] as! Dictionary<String, Int>
        let totalHours = userData["totalHours"] as! Int

        func cardListContainsTarget(_ target: String) -> Bool {
            for lst in [MessierTargets, NGCTargets, ICTargets, SharplessTargets, OthersTargets, PlanetTargets] {
                if lst.contains(target) {return true}
            }
            return false
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
                if date == featuredImageDate || isEarlierDate(dateToday, date) {
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
                cvc?.imageChangedDate = entryDate
                cvc?.newImage = UIImage(named: "Calendar/placeholder")
            }
            navigationController?.popToRootViewController(animated: true)
            return
        } else {
            var existingCalImageKey = calImageKey
            if existingCalImageKey == "" {
                existingCalImageKey = ((userData["calendarImages"] as! [String: String])[entryDate] ?? "")
            }
            let calImageDataRef: StorageReference = storage.child(existingCalImageKey)
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
                cvc?.imageChangedDate = entryDate
                func finishManageCalendarImages() {
                    //store image key as calendar image key and return to previous page
                    db.collection("userData").document(userKey).setData(["calendarImages": [entryDate: calImageKey]], merge: true)
                    self.navigationController?.popToRootViewController(animated: true)
                }
                //use current main image
                if mainImageKey != "" {
                    cvc?.newImage = calImage
                    calImageDataRef.putData(calImageData!, metadata: nil)
                    finishManageCalendarImages()
                    return
                }
                //check later entries in the same day for main image
                if entryList.count > selectedEntryInd + 1 {
                    var imageKey = ""
                    for i in selectedEntryInd + 1...entryList.count - 1 {
                        //main image found
                        if (entryList[i]["mainImageKey"] as! String) != "" {
                            imageKey = entryList[i]["mainImageKey"] as! String
                            break
                        }
                    }
                    if imageKey != "" {
                        //get image data from db
                        let imageRef = storage.child(imageKey)
                        imageRef.getData(maxSize: imgMaxByte) {data, Error in
                            if let Error = Error {
                                print(Error)
                                return
                            } else {
                                let processResCompressed = processImageAndResize(inpImg: (UIImage(data: data!)!), resizeTo: CGSize(width: calCellSize, height: calCellSize), clip: true)
                                calImageDataRef.putData(processResCompressed![1] as! Data, metadata: nil)
                                self.cvc?.newImage = (processResCompressed![0] as! UIImage)
                                self.calImageKey = ((self.userData["calendarImages"] as! [String: String])[self.entryDate]!)
                                finishManageCalendarImages()
                                return
                            }
                        }
                        //no main image in later entries
                    } else {
                        calImageDataRef.delete {error in}
                        cvc?.newImage = UIImage(named: "Calendar/placeholder")
                        finishManageCalendarImages()
                        return
                    }
                    //there are no later entries
                } else {
                    calImageDataRef.delete {error in}
                    cvc?.newImage = UIImage(named: "Calendar/placeholder")
                    finishManageCalendarImages()
                    return
                }
            }
            func storeImages(imagesRemoved: Bool) {
                for i in 0...addedImageKeyList.count - 1 {
                    let imageKey = addedImageKeyList[i]
                    var imageData: Data? = nil
                    if imageKeyList.index(of: imageKey) == nil {
                        imageData = mainImageData
                    } else {
                        imageData = imageDataList[imageKeyList.index(of: imageKey)!]
                    }
                    storage.child(imageKey).putData(imageData!, metadata: nil) {(metadata, error) in
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
                    storage.child(imageKey).delete {error in
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
                    deleteIodData()
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
        self.formattedTarget = formatTarget(target)
        //these targets appear together
        otherTarget = doubleTargets[formattedTarget] ?? ""
        for entry in entryList {
            if (entry["formattedTarget"] as! String) == formattedTarget || (entry["formattedTarget"] as! String) == otherTarget {
                duplicateTargets = true
            }
        }
        if entryData.count == 0 && duplicateTargets {
            let alertController = UIAlertController(title: "Error", message: "Entering the same target in a day is not allowed", preferredStyle: .alert)
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
    func processDelete(_ alertAction: UIAlertAction) {
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
        loadingIcon.startAnimating()
        formattedTarget = formatTarget(targetField.text!)
        //these targets appear together
        otherTarget = doubleTargets[formattedTarget] ?? ""
        let entryDoc = db.collection("journalEntries").document(userKey + entryDate)
        if entryList.count > 1 {
            //remove journal entry from list
            entryList.remove(at: selectedEntryInd)
            formattedTargetsList!.remove(at: formattedTargetsList!.index(of: formattedTarget)!)
            entryDoc.setData(["data": entryList, "formattedTargets": formattedTargetsList!], merge: true)
        } else {
            //delete journal entry list document
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
        var imageKeys = (entryData["imageKeys"] as! [String])
        let mainImageKey = (entryData["mainImageKey"] as! String)
        if mainImageKey != "" {imageKeys.append(mainImageKey)}
        //delete image data
        for imageKey in imageKeys {
            storage.child(imageKey).delete {error in
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
        var calImageKeys = userData["calendarImages"] as! Dictionary<String, String>
        var numEntriesInDate = userData["numEntriesInDate"] as! [String: Int]
        var cardTargetDatesDict: Dictionary<String, Any> = userData["cardTargetDates"] as! Dictionary<String, [String]>
        var photoCardTargetDatesDict: Dictionary<String, Any> = userData["photoCardTargetDates"] as! Dictionary<String, [String]>
        var photoTargetNumDict: Dictionary<String, Any> = userData["photoTargetNum"] as! Dictionary<String, Int>
        var obsTargetNumDict: Dictionary<String, Any> = userData["obsTargetNum"] as! Dictionary<String, Int>
        
        //update date of first journal entry if deleted entry was the first entry
        if firstEntryDate == entryDate && entryList.count == 0 {
            if (userData["calendarImages"] as! Dictionary<String, String>).count == 1 {
                firstEntryDate = ""
            } else {
                var earliestDate = "99999999"
                for (key, _) in (userData["calendarImages"] as! Dictionary<String, String>) {
                    if key == entryDate {
                        continue
                    }
                    if isEarlierDate(key, earliestDate) {
                        earliestDate = key
                    }
                }
                firstEntryDate = earliestDate
            }
        }
        var noCalImage = false
        let originalCalImageKey = ((userData["calendarImages"] as! [String: String])[entryDate]!)
        let calImageDataRef: StorageReference = storage.child(originalCalImageKey)
        func finishUserDataUpdate() {
            if noCalImage {
                calImageKeys[entryDate] = ""
                calImageDataRef.delete() {error in}
                cvc?.newImage = UIImage(named: "Calendar/placeholder")
            }
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
            userData["calendarImages"] = calImageKeys
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
                deleteIodData()
            }
            //if there is a featured entry on the same day as current entry, fix index in entry list in iod db
            for i in selectedEntryInd..<entryList.count {
                if entryList[i]["featuredDate"] as! String != "" {
                    db.collection("imageOfDayKeys").document(entryList[i]["featuredDate"] as! String).setData(["journalEntryInd": i], merge: true)
                }
            }
        }
        var changeCalendarImage = true
        if entryList.count == 0 {
            calImageKeys[entryDate] = nil
            calImageDataRef.delete {error in}
            cvc?.imageChangedDate = entryDate
            cvc?.newImage = nil
            changeCalendarImage = false
        }
        else if selectedEntryInd != 0 {
            for i in 0...selectedEntryInd - 1 {
                if (entryList[i]["mainImageKey"] as! String) != "" {
                    changeCalendarImage = false
                    break
                }
            }
        }
        if changeCalendarImage {
            cvc?.imageChangedDate = entryDate
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
                    imageRef.getData(maxSize: imgMaxByte) {data, Error in
                        if let Error = Error {
                            print(Error)
                            return
                        } else {
                            let newCalImageKey = NSUUID().uuidString
                            calImageKeys[self.entryDate] = newCalImageKey
                            let res = processImageAndResize(inpImg: UIImage(data: data!)!, resizeTo: CGSize(width: calCellSize, height: calCellSize), clip: true)
                            storage.child(newCalImageKey).putData(res![1] as! Data, metadata: nil)
                            self.cvc?.newImage = (res![0] as! UIImage)
                            finishUserDataUpdate()
                            return
                        }
                    }
                } else {
                    noCalImage = true
                    finishUserDataUpdate()
                    return
                }
            } else {
                noCalImage = true
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
        let action1 = UIAlertAction(title: "Yes", style: .destructive, handler: processDelete)
        let action2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }
}


