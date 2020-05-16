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
import DropDown

class ProfileEditViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate {
    var profileViewController: ProfileViewController?
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewLabel: UILabel!
    @IBOutlet weak var removeImageButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var favObjField: UITextField!
    @IBOutlet weak var bioField: UITextView!
    @IBOutlet weak var websiteField: UITextField!
    @IBOutlet weak var instaField: UITextField!
    @IBOutlet weak var youtubeField: UITextField!
    @IBOutlet weak var fbField: UITextField!
    @IBOutlet weak var telescopeField: UITextField!
    @IBOutlet weak var telescopeField2: UITextField!
    @IBOutlet weak var telescopeField3: UITextField!
    @IBOutlet weak var mountField: UITextField!
    @IBOutlet weak var mountField2: UITextField!
    @IBOutlet weak var mountField3: UITextField!
    @IBOutlet weak var cameraField: UITextField!
    @IBOutlet weak var cameraField2: UITextField!
    @IBOutlet weak var cameraField3: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var userImageTopCipad: NSLayoutConstraint!
    @IBOutlet weak var userImageLeadingCipad: NSLayoutConstraint!
    @IBOutlet weak var userImageWCipad: NSLayoutConstraint!
    @IBOutlet weak var favObjTopCipad: NSLayoutConstraint!
    @IBOutlet weak var favObjTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var dividerTopCipad: NSLayoutConstraint!
    @IBOutlet weak var mountFieldWC: NSLayoutConstraint!
    var userKey = ""
    var userData: Dictionary<String, Any>! = nil
    var image: UIImage! = nil
    var imageAdded = false
    var imageWasPresent = false
    var locationsVisited: [String] = []
    var activeField: UIView? = nil
    var eqFields: [UITextField] = []
    var popOverController: EquipmentPopOverViewController? = nil
    var selectedEqName = "" {
        didSet {
            let eqField = (activeField as! UITextField)
            eqField.text = selectedEqName
            selectedEqName = ""
            popOverController!.dismiss(animated: true, completion: {})
            popOverController = nil
            eqField.resignFirstResponder()
        }
    }
    var imageData: Data? = nil
    var compressedImageData: Data? = nil
    var userDataCopyToChangeKeys: [String] = []
    var moreOptionsDD: DropDown? = nil
    var pvc: ProfileViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        removeImageButton.isHidden = true
        if screenH < 600 {//iphone SE, 5s
            imageViewLabel.font = UIFont(name: imageViewLabel.font!.fontName, size: 75)
            mountFieldWC.constant = 98
        }
        else if screenH > 1000 {//ipads
            background.image = UIImage(named: "Profile/background-ipad")
            border.image = UIImage(named: "border-ipad")
            if screenH < 1100 {//9.7
                dividerTopCipad.constant = 5
            }
            else if screenH > 1150 {//11 and 12.9
                userImageTopCipad.constant = 90
                if screenH > 1300 {//12.9
                    userImageWCipad.constant = 250
                    userImageLeadingCipad.constant = 140
                    favObjTopCipad.constant = 40
                    favObjTrailingCipad.constant = 140
                    dividerTopCipad.constant = 100
                }
            }
        }
        scrollView.delegate = (self as UIScrollViewDelegate)
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = astroOrange
        for field in [favObjField, bioField, websiteField, instaField, youtubeField, fbField, nameField, locationField, telescopeField, telescopeField2, telescopeField3, mountField, mountField2, mountField3, cameraField, cameraField2, cameraField3] {
            field!.layer.borderWidth = 1
            field!.layer.borderColor = UIColor.white.cgColor
            if field == bioField {
                (field as! UITextView).delegate = (self as UITextViewDelegate)
                (field as! UITextView).autocorrectionType = .yes
                bioField.autocapitalizationType = .none
                bioField.textContainerInset.top = 2
            } else {
                (field as! UITextField).delegate = (self as UITextFieldDelegate)
                (field as! UITextField).autocorrectionType = .no
            }
        }
        let linkFields = [websiteField, instaField, youtubeField, fbField]
        let linkDomains = ["www.", "instagram.com/", "youtube.com/", "facebook.com/"]
        for i in 0..<4 {
            let font = UIFont(name: websiteField.font!.fontName, size: websiteField.font!.pointSize)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = (linkDomains[i] as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: websiteField.bounds.height))
            linkFields[i]!.leftView = paddingView
            linkFields[i]!.leftViewMode = UITextField.ViewMode.always
        }
        moreOptionsDD = DropDown()
        moreOptionsDD!.backgroundColor = .darkGray
        moreOptionsDD!.textColor = .white
        moreOptionsDD!.selectionBackgroundColor = .darkGray
        moreOptionsDD!.selectedTextColor = .white
        moreOptionsDD!.textFont = UIFont(name: "Pacifica Condensed", size: 15)!
        moreOptionsDD!.cellHeight = 34
        moreOptionsDD!.cornerRadius = 10
        moreOptionsDD!.anchorView = moreButton
        moreOptionsDD!.bottomOffset = CGPoint(x: 0, y: -61)
        moreOptionsDD!.dataSource = ["change email", "update password"]
        moreOptionsDD!.selectionAction = {(index: Int, item: String) in
            if index == 0 {
                let alertController = UIAlertController(title: "Update Email", message: "Enter a new email address:", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "confirm", style: .destructive, handler: {(alertAction) in
                    let currentUser = Auth.auth().currentUser
                    currentUser!.updateEmail(to: alertController.textFields![0].text!) {error in
                        if error != nil {
                            let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            db.collection("userData").document(self.userKey).setData(["email": alertController.textFields![0].text!], merge: true)
                            print("email changed")
                            let alertController = UIAlertController(title: "Success", message: "Your email has been successfully updated.", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                })
                let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                alertController.addTextField {(textField) in}
                self.present(alertController, animated: true, completion: nil)
            } else {
                let userEmail = self.userData["email"] as! String
                Auth.auth().sendPasswordReset(withEmail: userEmail) {_ in
                    let alertController = UIAlertController(title: "Email Sent", message: "A password reset email has been sent to: " + userEmail, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        nameField.text = (userData["userName"] as! String)
        locationField.text = (userData["userLocation"] as! String)
        locationsVisited = (userData["locationsVisited"] as! [String])
        favObjField.text = (userData["favoriteObject"] as! String)
        bioField.text = (userData["userBio"] as! String)
        websiteField.text = (userData["websiteName"] as! String)
        instaField.text = (userData["instaUsername"] as! String)
        youtubeField.text = (userData["youtubeChannel"] as! String)
        fbField.text = (userData["fbPage"] as! String)
        
        eqFields = [telescopeField, telescopeField2, telescopeField3, mountField, mountField2, mountField3, cameraField, cameraField2, cameraField3]
        let eqData = userData["userEquipment"] as! Dictionary<String, [String]>
        for (i, field) in eqFields.enumerated() {
            if i / 3 == 0 {
                if i < eqData["telescopes"]!.count {
                    field.text = eqData["telescopes"]![i]
                }
            } else if i / 3 == 1 {
                if i - 3 < eqData["mounts"]!.count {
                    field.text = eqData["mounts"]![i - 3]
                }
            } else {
                if i - 6 < eqData["cameras"]!.count {
                    field.text = eqData["cameras"]![i - 6]
                }
            }
        }
        if image != nil {
            imageViewLabel.isHidden = true
            imageView.image = image
            removeImageButton.isHidden = false
            imageWasPresent = true
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        activeField?.resignFirstResponder()
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = toolbar
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if eqFields.contains(textField) {
            let yOffset = contentView.bounds.height - scrollView.bounds.height
            scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
            
            popOverController = self.storyboard!.instantiateViewController(withIdentifier: "EquipmentPopOverViewController") as? EquipmentPopOverViewController
            popOverController!.eqType = textField.accessibilityIdentifier!
            popOverController!.pevc = self
            popOverController!.modalPresentationStyle = .popover
            popOverController!.preferredContentSize = CGSize(width: popOverController!.viewW, height: popOverController!.viewH)
            let popOverPresentationController = popOverController!.popoverPresentationController!
            popOverPresentationController.permittedArrowDirections = .down
            popOverPresentationController.sourceView = self.view
            let popOverPos = CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y - yOffset - 3, width: textField.bounds.width, height: textField.bounds.height)
            popOverPresentationController.sourceRect = popOverPos
            popOverPresentationController.delegate = self as UIPopoverPresentationControllerDelegate
            present(popOverController!, animated: true, completion: nil)
        }
        activeField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        popOverController?.dismiss(animated: true, completion: {})
    }
    func textViewShouldReturn(_ textView: UITextField) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeField = textView
    }
    @IBAction func toolbarButtonTapped(_ sender: Any) {
        view.endEditing(true)
    }
    @IBAction func imageTapped(_ sender: Any) {
        activeField?.resignFirstResponder()
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
                    let processResCompressed = processImageAndResize(inpImg: processedImage, resizeTo: CGSize(width: iodUserIconSize, height: iodUserIconSize), clip: true)
                    self.imageData = (processRes![1] as! Data)
                    self.compressedImageData = (processResCompressed![1] as! Data)
                    self.imageView.image = processedImage
                    self.removeImageButton.isHidden = false
                    self.imageViewLabel.isHidden = true
                    self.imageAdded = true
                }
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func removeImage(_ sender: Any) {
        if doneButton.isHidden {return}
        imageView.image = nil
        removeImageButton.isHidden = true
        imageViewLabel.isHidden = false
        imageAdded = false
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    @IBAction func moreButtonTapped(_ sender: Any) {
        moreOptionsDD!.show()
    }
    @IBAction func cancel(_ sender: Any) {
        pvc!.pevc = nil
        navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func submit(_ sender: Any) {
        //if name was left blank, show alert
        if nameField.text! == "" {
            let alertController = UIAlertController(title: "Error", message: "Username must not be left blank. Please enter a username.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
        loadingIcon.startAnimating()
        doneButton.isHidden = true
        cancelButton.isHidden = true
        doneButton.isUserInteractionEnabled = false
        pvc!.profileChanged = true
        
        //check if there are any profile copies to update if user is currently or will be featured
        if (userData["userDataCopyKeys"] as! [String: String]).count != 0 {
            for (date, userDataKey) in (userData["userDataCopyKeys"] as! [String: String]) {
                if date == featuredImageDate || isEarlierDate(dateToday, date) {
                    userDataCopyToChangeKeys.append(userDataKey)
                }
            }
        }

        if locationField.text! != "" && !locationsVisited.contains(locationField.text!) {
            locationsVisited.append(locationField.text!)
        }
        var telescopes: [String] = []
        var mounts: [String] = []
        var cameras: [String] = []
        for (i, field) in eqFields.enumerated() {
            let text = field.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if text != "" {
                if i / 3 == 0 {
                    telescopes.append(text)
                } else if i / 3 == 1 {
                    mounts.append(text)
                } else {
                    cameras.append(text)
                }
            }
        }
        let newUserName = nameField.text!
        let eqDict = ["telescopes": telescopes, "mounts": mounts, "cameras": cameras]
        let newKeyValues = ["profileImageKey": userData["profileImageKey"]!, "compressedProfileImageKey": userData["compressedProfileImageKey"]!, "userName": newUserName, "userLocation": locationField.text!, "favoriteObject": favObjField.text!, "websiteName": websiteField.text!, "instaUsername": instaField.text!, "youtubeChannel": youtubeField.text!, "fbPage": fbField.text!, "userBio": bioField.text!, "locationsVisited": locationsVisited, "userEquipment": eqDict] as [String : Any]
        var newUserData = userData.merging(newKeyValues) { (_, new) in new }
        var imageState : String
        if ((!imageWasPresent && !imageAdded) || (imageWasPresent && !imageAdded && imageView.image != nil)) {
            imageState = "no change"
        } else if (!imageWasPresent && imageAdded) {
            imageState = "image added"
        } else if (imageWasPresent && imageView.image == nil) {
            imageState = "image removed"
        } else if (imageWasPresent && imageAdded) {
            imageState = "image updated"
        } else {
            print("Error! should not reach this clause!")
            return
        }
        if (userData["userName"] as! String) != newUserName {
            KeychainWrapper.standard.set(newUserName, forKey: "userName")
            db.collection("basicUserData").document(userKey).setData(["userName": newUserName], merge: true)
            //update userName field in their journal entries so that Antoine can find entries by userName in db
            db.collection("journalEntries").whereField("userName", isEqualTo: (userData["userName"] as! String)).getDocuments(completion: {(QuerySnapshot, Error) in
                if Error != nil {
                    print(Error!)
                } else {
                    let entryList = QuerySnapshot!.documents
                    if entryList != [] {
                        for entry in entryList {
                            db.collection("journalEntries").document(entry.documentID).setData(["userName": newUserName], merge: true)
                        }
                    }
                }
            })
            //user is currently featured. Change username in iod banner in calendar view
            if (userData["userDataCopyKeys"] as! [String: String])[featuredImageDate] != nil {
                newIodUserName = newUserName
            }
        }
        if userDataCopyToChangeKeys.count != 0 {
            for key in userDataCopyToChangeKeys {
                db.collection("userData").document(key).setData(["userName": newUserName, "websiteName": websiteField.text!, "instaUsername": instaField.text!, "youtubeChannel": youtubeField.text!, "fbPage": fbField.text!, "userBio": bioField.text!], merge: true)
            }
        }
        db.collection("userData").document(userKey).setData(newUserData, merge: true) {err in
            if let err = err {
                print("Error updating user Data: \(err)")
            } else {
                if imageState == "no change" {
                    self.pvc!.userData = newUserData
                    if self.imageView.image == nil {
                        self.pvc!.newImage = UIImage(named: "ImageOfTheDay/placeholderProfileImage")
                    } else {
                        self.pvc!.newImage = self.imageView.image
                    }
                    self.pvc!.pevc = nil
                    loadingIcon.stopAnimating()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        if imageState == "no change" {
            return
        }
        
        //continue on if change in image view
        var imageKey = userData["profileImageKey"] as! String
        if imageKey == "" {
            imageKey = NSUUID().uuidString
            newUserData["profileImageKey"] = imageKey
        }
        var compressedImageKey = userData["compressedProfileImageKey"] as! String
        if compressedImageKey == "" {
            compressedImageKey = NSUUID().uuidString
            newUserData["compressedProfileImageKey"] = compressedImageKey
        }
        let dataRef = storage.child(imageKey)
        let compressedDataRef = storage.child(compressedImageKey)
        if (imageState != "image removed") {
            pvc!.userData = newUserData
            pvc!.newImage = imageView.image
            if (imageState == "image added") {
                db.collection("userData").document(userKey).setData(["profileImageKey": imageKey, "compressedProfileImageKey": compressedImageKey], merge: true)
                db.collection("basicUserData").document(userKey).setData(["compressedProfileImageKey": compressedImageKey], merge: true)
                if userDataCopyToChangeKeys.count != 0 {
                    for key in userDataCopyToChangeKeys {
                        db.collection("userData").document(key).setData(["profileImageKey": imageKey], merge: true)
                    }
                }
            }
            dataRef.putData(self.imageData!, metadata: nil) {(metadata, error) in
                if error != nil {
                    print(error as Any)
                    return
                } else {
                    print("done storing profile image")
                    self.pvc!.pevc = nil
                    loadingIcon.stopAnimating()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            compressedDataRef.putData(self.compressedImageData!, metadata: nil) {(metadata, error) in
                if error != nil {
                    print(error as Any)
                    return
                } else {
                    print("done storing compressed profile image")
                }
            }
            return
        } else {
            newUserData["profileImageKey"] = ""
            newUserData["compressedProfileImageKey"] = ""
            pvc!.userData = newUserData
            pvc!.newImage = UIImage(named: "ImageOfTheDay/placeholderProfileImage")
            db.collection("userData").document(userKey).setData(["profileImageKey": "", "compressedProfileImageKey": ""], merge: true)
            db.collection("basicUserData").document(userKey).setData(["compressedProfileImageKey": ""], merge: true)
            if userDataCopyToChangeKeys.count != 0 {
                for key in userDataCopyToChangeKeys {
                    db.collection("userData").document(key).setData(["profileImageKey": ""], merge: true)
                }
            }
            dataRef.delete { (error) in
                if error != nil {
                    print(error as Any)
                    return
                } else {
                    print("done deleting image")
                    self.pvc!.pevc = nil
                    loadingIcon.stopAnimating()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            compressedDataRef.delete {error in}
        }
    }
}

