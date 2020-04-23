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

class ProfileCreationViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
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
        imageView.layer.borderColor = UIColor.orange.cgColor
        for field in [favObjField, bioField, websiteField, instaField, youtubeField, fbField, nameField, locationField, telescopeField, telescopeField2, telescopeField3, mountField, mountField2, mountField3, cameraField, cameraField2, cameraField3] {
            field!.layer.borderWidth = 1
            field!.layer.borderColor = UIColor.white.cgColor
            if field == bioField {
                (field as! UITextView).delegate = (self as UITextViewDelegate)
                (field as! UITextView).autocorrectionType = .yes
                bioField.autocapitalizationType = .none
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
    override func viewDidAppear(_ animated: Bool) {
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
            self.dismiss(animated: true, completion: nil)
            let resizeRes = resizeByByte(img: newImage, maxByte: 1024 * 1024 * 3)
            if resizeRes == nil {
                let alertController = UIAlertController(title: "Error", message: "The image size is too big. Please choose another image. Max size: 7 MB", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                imageData = resizeRes![0]
                compressedImageData = resizeRes![1]
                imageViewLabel.isHidden = true
                imageView.image = newImage
                removeImageButton.isHidden = false
            }
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
        if screenH < 1000 && eqFields.contains(textField) {
            let yOffset = contentView.bounds.height - scrollView.bounds.height
            scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
        }
        activeField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = toolbar
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        textView.text = ""
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
    @IBAction func profileDone(_ sender: Any) {
        //if name was left blank, show alert
        if nameField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Username must not be left blank. Please enter a username.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
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
        let newUserData = ["userName": nameField.text!, "userLocation": locationField.text!, "favoriteObject": favObjField.text!, "userBio": bioField.text!, "websiteName": websiteField.text!, "instaUsername": instaField.text!, "youtubeChannel": youtubeField.text!, "fbPage": fbField.text!, "userEquipment": eqDict, "profileImageKey": "", "compressedProfileImageKey": "", "locationsVisited": [], "firstJournalEntryDate": "", "calendarImages": Dictionary<String, String>(), "numEntriesInDate": Dictionary<String, Int>(), "photoCardTargetDates": Dictionary<String, [String]>(), "cardTargetDates": Dictionary<String, [String]>(), "photoTargetNum": Dictionary<String, Int>(), "obsTargetNum": Dictionary<String, Int>(), "totalHours": 0, "featuredAlertDates": [], "userDataCopyKeys": Dictionary<String, String>()] as [String : Any]
        KeychainWrapper.standard.set(nameField.text!, forKey: "userName")
        let docKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        db.collection("userData").document(docKey).setData(newUserData, merge: true)
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
                    firstTime = true
                    self.performSegue(withIdentifier: "profileCreationToCalendar", sender: self)
                }
            }
            db.collection("basicUserData").document(docKey).setData(["compressedProfileImageKey": compressedImageKey], merge: true)
            compressedDataRef.putData(compressedImageData!, metadata: nil) {(metadata, error) in
                if error != nil {
                    print(error as Any)
                    return
                } else {
                    print("done storing compressed profile image")
                }
            }
        } else {
            firstTime = true
            performSegue(withIdentifier: "profileCreationToCalendar", sender: self)
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

