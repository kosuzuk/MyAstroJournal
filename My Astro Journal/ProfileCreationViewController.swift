//
//  File.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 4/11/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class ProfileCreationViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewLabel: UILabel!
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
    @IBOutlet weak var removeImageButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var userImageLeadingC: NSLayoutConstraint!
    @IBOutlet weak var userImageTopCipad: NSLayoutConstraint!
    @IBOutlet weak var userImageLeadingCipad: NSLayoutConstraint!
    @IBOutlet weak var userNameWC: NSLayoutConstraint!
    @IBOutlet weak var favObjTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var mountFieldWC: NSLayoutConstraint!
    var activeField: UIView? = nil
    var eqFields: [UITextField] = []
    var imageData: Data?
    var compressedImageData: Data?
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
    var email = ""
    var newUserData: [String: Any]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH > 1000 {//ipads
            background.image = UIImage(named: "Profile/background-ipad")
            border.image = UIImage(named: "border-ipad")
            if screenH > 1200 {//12.9
                userImageTopCipad.constant = 110
                userImageLeadingCipad.constant = 100
                favObjTrailingCipad.constant = 100
            }
        }
        scrollView.delegate = (self as UIScrollViewDelegate)
        removeImageButton.isHidden = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = astroOrange
        for field in [favObjField, bioField, websiteField, instaField, youtubeField, fbField, nameField, locationField, telescopeField, telescopeField2, telescopeField3, mountField, mountField2, mountField3, cameraField, cameraField2, cameraField3] {
            field!.layer.borderWidth = 1
            field!.layer.borderColor = UIColor.white.cgColor
            if field == bioField {
                (field as! UITextView).delegate = (self as UITextViewDelegate)
                (field as! UITextView).autocorrectionType = .yes
                bioField.text = "Bio"
                bioField.textContainerInset.top = 2
            } else {
                (field as! UITextField).delegate = (self as UITextFieldDelegate)
                (field as! UITextField).autocorrectionType = .no
            }
        }
        let linkFields = [websiteField, instaField, youtubeField, fbField]
        let linkStarters = ["www.", "instagram.com/", "youtube.com/", "facebook.com/"]
        for i in 0..<4 {
            let font = UIFont(name: websiteField.font!.fontName, size: websiteField.font!.pointSize)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = (linkStarters[i] as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: websiteField.bounds.height))
            linkFields[i]!.leftView = paddingView
            linkFields[i]!.leftViewMode = UITextField.ViewMode.always
        }
        eqFields = [telescopeField, telescopeField2, telescopeField3, mountField, mountField2, mountField3, cameraField, cameraField2, cameraField3]
        endNoInput()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if screenH < 600 {//iphone SE, 5s
            userImageLeadingC.constant = 20
            userNameWC.constant = 110
            imageViewLabel.font = UIFont(name: imageViewLabel.font!.fontName, size: 70)
            mountFieldWC.constant = 98
        }
    }
    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
      viewControllerToPresent.modalPresentationStyle = .fullScreen
      super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    @IBAction func pickImage(_ sender: Any) {
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
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        activeField?.resignFirstResponder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if eqFields.contains(textField) {
            let yOffset = contentView.bounds.height - scrollView.bounds.height
            scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
            
            popOverController = self.storyboard!.instantiateViewController(withIdentifier: "EquipmentPopOverViewController") as? EquipmentPopOverViewController
            popOverController!.eqType = textField.accessibilityIdentifier!
            popOverController!.pcvc = self
            popOverController!.modalPresentationStyle = .popover
            popOverController!.preferredContentSize = CGSize(width: popOverController!.viewW, height: popOverController!.viewH)
            let popOverPresentationController = popOverController!.popoverPresentationController!
            popOverPresentationController.permittedArrowDirections = .down
            popOverPresentationController.sourceView = self.view
            let popOverPos = CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y - yOffset + 20, width: textField.bounds.width, height: textField.bounds.height)
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
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = toolbar
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text == "Bio" {
            textView.text = ""
        }
        activeField = textView
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Bio"
        }
    }
    func textViewShouldReturn(_ textView: UITextField) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    @IBAction func toolbarButtonTapped(_ sender: Any) {
        view.endEditing(true)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    @IBAction func profileDone(_ sender: Any) {
        //if name was left blank, show alert
        if nameField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Username must not be left blank. Please enter a username.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        view.addSubview(formatLoadingIcon(loadingIcon))
        loadingIcon.startAnimating()
        startNoInput()
        doneButton.isHidden = true
        logoutButton.isHidden = true
        if bioField.text! == "Bio" {
            bioField.text = ""
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
        let eqDict = ["telescopes": telescopes, "mounts": mounts, "cameras": cameras]
        newUserData = ["email": email, "userName": nameField.text!, "userLocation": locationField.text!, "favoriteObject": favObjField.text!, "userBio": bioField.text!, "websiteName": websiteField.text!, "instaUsername": instaField.text!, "youtubeChannel": youtubeField.text!, "fbPage": fbField.text!, "userEquipment": eqDict, "profileImageKey": "", "compressedProfileImageKey": "", "locationsVisited": [], "firstJournalEntryDate": "", "calendarImages": Dictionary<String, String>(), "numEntriesInDate": Dictionary<String, Int>(), "photoCardTargetDates": Dictionary<String, [String]>(), "cardTargetDates": Dictionary<String, [String]>(), "photoTargetNum": Dictionary<String, Int>(), "obsTargetNum": Dictionary<String, Int>(), "totalHours": 0, "cardBackSelected": "1", "packsUnlocked": Dictionary<String, Bool>(), "cardBacksUnlocked": Dictionary<String, Bool>(), "featuredAlertDates": [], "userDataCopyKeys": Dictionary<String, String>(), "isMonthlyWinner": false] as [String : Any]
        KeychainWrapper.standard.set(nameField.text!, forKey: "userName")
        let docKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        db.collection("userData").document(docKey).setData(newUserData!, merge: true)
        db.collection("basicUserData").document(docKey).setData(["userName": nameField.text!, "compressedProfileImageKey": ""], merge: true)
        if (imageView.image != nil) {
            let imageKey = NSUUID().uuidString
            let dataRef = storage.child(imageKey)
            let compressedImageKey = NSUUID().uuidString
            let compressedDataRef = storage.child(compressedImageKey)
            db.collection("userData").document(docKey).setData(["profileImageKey": imageKey, "compressedProfileImageKey": compressedImageKey], merge: true)
            dataRef.putData(imageData!, metadata: nil) {(metadata, error) in
                if error != nil {
                    print(error as Any)
                    return
                } else {
                    print("done storing profile image")
                    self.performSegue(withIdentifier: "profileCreationToCalendar", sender: self)
                }
            }
            db.collection("basicUserData").document(docKey).setData(["compressedProfileImageKey": compressedImageKey], merge: true)
            compressedDataRef.putData(compressedImageData!, metadata: nil)
        } else {
            performSegue(withIdentifier: "profileCreationToCalendar", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tvc = segue.destination as? UITabBarController
        if tvc != nil {
            firstTime = true
            entryEditFirstTime = true
            let cvc = tvc!.viewControllers![0].children[0] as! CalendarViewController
            cvc.userData = newUserData
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
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
}

