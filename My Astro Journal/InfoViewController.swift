//
//  SecondViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class InfoViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var expandLabel: UILabel!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var thankYouMessage: UILabel!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var contentViewHC: NSLayoutConstraint!
    @IBOutlet weak var contentViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var howItWorksTopCipad: NSLayoutConstraint!
    @IBOutlet weak var bigTextHCipad: NSLayoutConstraint!
    let application = UIApplication.shared
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH < 600 {//iphone SE, 5s
            contentViewHC.constant = 2330
            expandLabel.text = "expand catalog"
        } else if screenW < 400 {//iphone 8, 11
            contentViewHC.constant = 2220
        } else if screenH > 1000 {//ipads
            background.image = UIImage(named: "Info/background-ipad")
            border.image = UIImage(named: "border-ipad")
            if screenH > 1300 {//ipad 12.9
                howItWorksTopCipad.constant = 60
                bigTextHCipad.constant = 400
            }
        }
        messageField.layer.cornerRadius = 5
        messageField.layer.borderWidth = 1
        messageField.layer.borderColor = UIColor.white.cgColor
        messageField.delegate = (self as UITextViewDelegate)
        scrollView.delegate = (self as UIScrollViewDelegate)
        sendMessageButton.isHidden = true
        messageField.autocapitalizationType = .none
        messageField.autocorrectionType = .yes
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageField.resignFirstResponder()
        thankYouMessage.isHidden = true
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        messageField.resignFirstResponder()
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = toolbar
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        let yOffset = contentView.bounds.height - scrollView.bounds.height
        scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.text! != "" {
            if thankYouMessage.isHidden == false {
                thankYouMessage.isHidden = true
            }
            sendMessageButton.isHidden = false
        } else {
            sendMessageButton.isHidden = true
        }
    }
    func textViewShouldReturn(_ textView: UITextField) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    @IBAction func toolbarButtonTapped(_ sender: Any) {
        view.endEditing(true)
    }
    @IBAction func paypalButtonTapped(_ sender: Any) {
        let appURL = NSURL(string: "paypal://www.paypal.me/AntoineGrelin")!
        let webURL = NSURL(string: "https://www.paypal.me/AntoineGrelin")!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    @IBAction func patreonButtonTapped(_ sender: Any) {
        let appURL = NSURL(string: "patreon://www.patreon.com/Galactic_Hunter")!
        let webURL = NSURL(string: "https://www.patreon.com/Galactic_Hunter")!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    @IBAction func websiteButtonTapped(_ sender: Any) {
        let webURL = NSURL(string: "https://www.galactic-hunter.com/")!
        application.open(webURL as URL)
    }
    @IBAction func fbButtonTapped(_ sender: Any) {
        let appURL = NSURL(string: "facebook://www.facebook.com/galactichunter")!
        let webURL = NSURL(string: "https://www.facebook.com/galactichunter")!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    @IBAction func instaButtonTapped(_ sender: Any) {
        let appURL = NSURL(string: "instagram://www.instagram.com/galactic.hunter/?hl=en")!
        let webURL = NSURL(string: "https://www.instagram.com/galactic.hunter/?hl=en")!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    @IBAction func ytButtonTapped(_ sender: Any) {
        let appURL = NSURL(string: "youtube://www.youtube.com/channel/UC5okGNy061H18Qv4B8pKKhA")!
        let webURL = NSURL(string: "https://www.youtube.com/channel/UC5okGNy061H18Qv4B8pKKhA")!
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            // if Youtube app is not installed, open URL inside Safari
            application.open(webURL as URL)
        }
    }
    @IBAction func sendMessageTapped(_ sender: Any) {
        let userName = KeychainWrapper.standard.string(forKey: "userName")!
        let message = messageField.text!
        let messageData = ["userName": userName, "date": dateToday, "message": message]
        let newKey = NSUUID().uuidString
        db.collection("messagesFromUsers").document(newKey).setData(messageData, merge: false)
        messageField.text = ""
        sendMessageButton.isHidden = true
        thankYouMessage.isHidden = false
    }
}



