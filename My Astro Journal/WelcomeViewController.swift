//
//  FirstViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftKeychainWrapper
import MessageUI

let MessierTargets = ["M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10", "M11", "M12", "M13", "M14", "M15", "M16", "M17", "M18", "M19", "M20", "M21", "M22", "M23", "M24", "M25", "M26", "M27", "M28", "M29", "M30", "M31", "M32", "M33", "M34", "M35", "M36", "M37", "M38", "M39", "M40", "M41", "M42", "M43", "M44", "M45", "M46", "M47", "M48", "M49", "M50", "M51", "M52", "M53", "M54", "M55", "M56", "M57", "M58", "M59", "M60", "M61", "M62", "M63", "M64", "M65", "M66", "M67", "M68", "M69", "M70", "M71", "M72", "M73", "M74", "M75", "M76", "M77", "M78", "M79", "M80", "M81", "M82", "M83", "M84",  "M85", "M86", "M87", "M88", "M89", "M90", "M91", "M92", "M93", "M94", "M95", "M96", "M97", "M98", "M99", "M100", "M101", "M102", "M103", "M104", "M105", "M106", "M107", "M108", "M109", "M110"]
let NGCTargets = ["NGC104", "NGC281", "NGC292", "NGC869", "NGC884", "NGC1499", "NGC1977", "NGC2024", "NGC2070", "NGC2237", "NGC2244", "NGC2264", "NGC2359", "NGC2392", "NGC3372", "NGC3628", "NGC4565", "NGC4631", "NGC5128", "NGC5139", "NGC6543", "NGC6888", "NGC6946", "NGC6960", "NGC6974", "NGC6992", "NGC7000", "NGC7023", "NGC7293", "NGC7380", "NGC7635"]
let ICTargets = ["IC59", "IC63", "IC405", "IC434", "IC443", "IC1396", "IC1805", "IC1848", "IC2118", "IC5067", "IC5070", "IC5146"]
let GalaxyTargets = ["M31", "M32", "M33", "M49", "M51", "M58", "M59", "M60", "M61", "M63", "M64", "M65", "M66", "M74", "M77", "M81", "M82", "M83", "M84", "M85", "M86", "M87", "M88", "M89", "M90", "M91", "M94", "M95", "M96", "M98", "M99", "M100", "M101", "M102", "M104", "M105", "M106", "M108", "M109", "M110", "NGC292", "NGC3628", "NGC4565", "NGC4631", "NGC5128", "NGC6946"]
let NebulaTargets = ["M1", "M8", "M16", "M17", "M20", "M27", "M42", "M43", "M57", "M76", "M78", "M97", "NGC281", "NGC1499", "NGC1977", "NGC2024", "NGC2237", "NGC2244", "NGC2264", "NGC2359", "NGC2392", "NGC3372", "NGC6543", "NGC6888", "NGC6960", "NGC6974", "NGC6992", "NGC7000", "NGC7023", "NGC7293", "NGC7380", "NGC7635", "IC59", "IC63", "IC405", "IC434", "IC443", "IC1396", "IC1805", "IC1848", "IC2118", "IC5067", "IC5070", "IC5146"]
let ClusterTargets = ["M2", "M3", "M4", "M5", "M6", "M7", "M9", "M10", "M11", "M12", "M13", "M14", "M15", "M18", "M19", "M21", "M22", "M23", "M24", "M25", "M26", "M28", "M29", "M30", "M34", "M35", "M36", "M37", "M38", "M39", "M41", "M44", "M45", "M46", "M47", "M48", "M50", "M52", "M53", "M54", "M55", "M56", "M62", "M67", "M68", "M69", "M70", "M71", "M72", "M75", "M79", "M80", "M92", "M93", "M103", "M107", "NGC104", "NGC869", "NGC884", "NGC5139"]
let PlanetTargets = ["Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

let doubleTargets = ["IC5067": "IC5070", "IC5070": "IC5067", "NGC869": "NGC884", "NGC884": "NGC869", "NGC2237": "NGC2244", "NGC2244": "NGC2237"]

let nicknames = ["crab": "M1", "butterfly": "M6", "ptolemy's": "M7", "lagoon": "M8", "wild duck": "M11", "hercules": "M13", "great pegasus": "M15", "eagle": "M16", "omega": "M17", "trifid": "M20", "sagittarius star cloud": "M24", "dumbbell": "M27", "andromeda": "M31", "le gentil": "M32", "triangulum": "M33", "pinwheel cluster": "M36", "starfish": "M38", "double": "M40", "orion": "M42", "de mairan's": "M43", "beehive": "M44", "pleiades": "M45", "whirlpool": "M51", "summer rose": "M55", "ring": "M57", "sunflower": "M63", "black eye": "M64", "king cobra": "M67", "phantom": "M74", "little dumbbell": "M76", "cetus a": "M77", "bode's": "M81", "cigar": "M82", "southern pinwheel": "M83", "virgo a": "M87", "cat's eye galaxy": "M94", "owl": "M97", "coma pinwheel": "M99", "pinwheel galaxy": "M101", "sombrero": "M104", "surfboard": "M108", "edward's young": "M110", "ghost of cassiopeia": "IC63", "flaming": "IC405", "horsehead": "IC434", "jellyfish": "IC443", "elephant's trunk": "IC1396", "heart": "IC1805", "soul": "IC1848", "witch head": "IC2118", "pelican": "IC5067", "cocoon": "IC5146", "47 tucanae": "NGC104", "pacman": "NGC281", "small magellanic cloud": "NGC292", "double cluster in perseus": "NGC869", "california":"NGC1499", "runningman": "NGC1977", "flame": "NGC2024", "tarantula": "NGC2070", "rosette": "NGC2237", "cone": "NGC2264", "thor's helmet": "NGC2359", "eskimo": "NGC2392", "carina": "NGC3372", "hamburger": "NGC3628", "needle": "NGC4565", "whale": "NGC4631", "centaurus a": "NGC5128", "omega centauri": "NGC5139", "cat's eye nebula": "NGC6543", "crescent": "NGC6888", "fireworks": "NGC6946", "western veil": "NGC6960", "pickering's triangle": "NGC6974", "eastern veil": "NGC6992", "north america": "NGC7000", "iris": "NGC7023", "helix": "NGC7293", "wizard": "NGC7380", "bubble": "NGC7635"]

let MessierConst = [1: "Taurus", 2: "Aquarius", 3: "Canes Venatici", 4: "Scorpius", 5: "Serpens", 6: "Scorpius", 7: "Scorpius", 8: "Sagittarius", 9: "Ophiuchus", 10: "Ophiuchus", 11: "Scutum", 12: "Ophiuchus", 13: "Hercules", 14: "Ophiuchus", 15: "Pegasus", 16: "Serpens", 17: "Sagittarius", 18: "Sagittarius", 19: "Ophiuchus", 20: "Sagittarius", 21: "Sagittarius", 22: "Sagittarius", 23: "Sagittarius", 24: "Sagittarius", 25: "Sagittarius", 26: "Scutum", 27: "Vulpecula", 28: "Sagittarius", 29: "Cygnus", 30: "Capricornus", 31: "Andromeda", 32: "Andromeda", 33: "Triangulum", 34: "Perseus", 35: "Gemini", 36: "Auriga", 37: "Auriga", 38: "Auriga", 39: "Cygnus", 40: "Ursa Major", 41: "Canis Major", 42: "Orion", 43: "Orion", 44: "Cancer", 45: "Taurus", 46: "Puppis", 47: "Puppis", 48: "Hydra", 49: "Virgo", 50: "Monoceros", 51: "Canes Venatici", 52: "Cassiopeia", 53: "Coma Berenices", 54: "Sagittarius", 55: "Sagittarius", 56: "Lyra", 57: "Lyra", 58: "Virgo", 59: "Virgo", 60: "Virgo", 61: "Virgo", 62: "Ophiuchus", 63: "Canes Venatici", 64: "Coma Berenices", 65: "Leo", 66: "Leo", 67: "Cancer", 68: "Hydra", 69: "Sagittarius", 70: "Sagittarius", 71: "Sagitta", 72: "Aquarius", 73: "Aquarius", 74: "Pisces", 75: "Sagittarius", 76: "Perseus", 77: "Cetus", 78: "Orion", 79: "Lepus", 80: "Scorpius", 81: "Ursa Major", 82: "Ursa Major", 83: "Hydra", 84: "Virgo",  85: "ComaBerenices", 86: "Virgo", 87: "Virgo", 88: "Coma Berenices", 89: "Virgo", 90: "Virgo", 91: "Coma Berenices", 92: "Hercules", 93: "Puppis", 94: "Canes Venatici", 95: "Leo", 96: "Leo", 97: "Ursa Major", 98: "ComaBerenices", 99: "Coma Berenices", 100: "Coma Berenices", 101: "Ursa Major", 102: "Draco", 103: "Cassiopeia", 104: "Virgo", 105: "Leo", 106: "Canes Venatici", 107: "Ophiuchus", 108: "Ursa Major", 109: "Ursa Major", 110: "Andromeda"]
let NGCConst = [104: "Tucana", 281: "Cassiopeia", 292: "Tucana", 869: "Perseus", 884: "Perseus", 1499: "Perseus", 1977: "Orion", 2024: "Orion", 2237: "Monoceros", 2244: "Monoceros", 2264: "Monoceros", 2359: "Canis Major", 2392: "Gemini", 3372: "Carina", 3628: "Leo", 4565: "Coma Berenices", 4631: "Canes Venatici", 5128: "Centaurus", 5139: "Centaurus", 6543: "Draco", 6888: "Cygnus", 6946: "Cygnus", 6960: "Cygnus", 6974: "Cygnus", 6992: "Cygnus", 7000: "Cygnus", 7023: "Cepheus", 7293: "Aquarius", 7380: "Cepheus", 7635: "Cassiopeia"]
let ICConst = [59: "Cassiopeia", 443: "Gemini", 63: "Cassiopeia", 405: "Auriga", 434: "Orion", 1396: "Cepheus", 1805: "Cassiopeia", 1848: "Cassiopeia", 2118: "Eridanus", 5067: "Cygnus", 5070: "Cygnus", 5146: "Cygnus"]

let loadingIcon = UIActivityIndicatorView()
let startNoInput = UIApplication.shared.beginIgnoringInteractionEvents
let endNoInput = UIApplication.shared.endIgnoringInteractionEvents
let storage = Storage.storage().reference()
let db = Firestore.firestore()
let settings = FirestoreSettings()
let screenW = UIScreen.main.bounds.width
let screenH = UIScreen.main.bounds.height
let monthNames = ["January", "Feburary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
var firstTime = false
var dateToday = ""
var featuredImageDate = ""
//communicate between profile and calendar view if featured user changes username
var newIodUserName = ""
//max image size to push and pull from db is 3MB
let imgMaxByte: Int64 = 1024 * 1024 * 3
let calCellSize = 50
let iodUserIconSize = 30
let maxSize = 700
let imageTooBigMessage = "The image size is too big. Please choose another image."

func formatLoadingIcon(icon: UIActivityIndicatorView) -> UIActivityIndicatorView {
    icon.center = CGPoint(x: screenW / 2, y: screenH / 2 - 75)
    icon.color = UIColor.lightGray
    if #available(iOS 13.0, *) {
        icon.style = UIActivityIndicatorView.Style.large
    }
    return icon
}

infix operator ^^
extension Bool {
    static func ^^(a:Bool, b:Bool) -> Bool {
        return a != b
    }
}

func processImageAndResize(inpImg: UIImage, resizeTo: CGSize, clip: Bool) -> [Any]? {
    var img = inpImg
    var factor = CGFloat(0.0)
    if clip ^^ (img.size.width / resizeTo.width > img.size.height / resizeTo.height) {
        factor = resizeTo.width / img.size.width
    } else {
        factor = resizeTo.height / img.size.height
    }
    let newSize = CGSize(width: img.size.width * factor, height: img.size.height * factor)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    img = renderer.image { (context) in
        img.draw(in: CGRect(origin: .zero, size: newSize))
    }
    let imgData = img.jpegData(compressionQuality: 0.4)!
    return [img, imgData]
}

func processImage(inpImg: UIImage) -> [Any]? {
    var img = inpImg
    if Int(img.size.width) > maxSize || Int(img.size.height) > maxSize {
        let res = processImageAndResize(inpImg: img, resizeTo: CGSize(width: maxSize, height: maxSize), clip: false)
        img = res![0] as! UIImage
    }
    var quality: CGFloat = 1
    var imgData = img.jpegData(compressionQuality: 1)!
    var imgByte = imgData.count
    while imgByte > Int(1024 * 1024 * 0.7) && quality > 0 {
        quality -= 0.2
        imgData = img.jpegData(compressionQuality: quality)!
        imgByte = imgData.count
    }
    if imgByte > imgMaxByte {
        return nil
    }
    return [img, imgData]
}

func isEarlierDate(date1: String, date2: String) -> Bool {
    let year1 = Int(String(date1.suffix(4)))!
    let year2 = Int(String(date2.suffix(4)))!
    if year1 != year2 {
        return year1 < year2
    }
    let month1 = Int(String(date1.prefix(2)))!
    let month2 = Int(String(date2.prefix(2)))!
    if month1 != month2 {
        return month1 < month2
    }
    let day1 = Int(date1.prefix(4).suffix(2))!
    let day2 = Int(date2.prefix(4).suffix(2))!
    if day1 != day2 {
        return day1 < day2
    }
    return true
}

func formatTarget(inputTarget: String) -> String {
    //remove special chars and make it lowercased
    let target = inputTarget.replacingOccurrences(of: "’", with: "'").replacingOccurrences(of: "”", with: "\"").lowercased()
    var res = target
    //check if a target nickname was inputted
    if res.count > 3 {
        if res.prefix(4) == "the " {
            res = String(res.suffix(res.count - 4))
        }
    }
    if res.count > 4 {
        if res.suffix(5) == " star" {
            res = String(res.prefix(res.count - 5))
        }
    }
    if res.count > 6 {
        if res.suffix(7) == " nebula" && res != "cat's eye nebula" {
            res = String(res.prefix(res.count - 7))
        }
    }
    if res.count > 6 {
        if res.suffix(7) == " galaxy" && res != "cat's eye galaxy" && res != "pinwheel galaxy" {
            res = String(res.prefix(res.count - 7))
        }
    }
    if res.count > 7 {
        if res.suffix(8) == " cluster" && res != "pinwheel cluster" {
            res = String(res.prefix(res.count - 8))
        }
    }
    if res == "double" && target.count > 6 && target.suffix(7) == "cluster" {
        res = "double cluster in perseus"
    }
    let nicknameRes = nicknames[res]
    if nicknameRes != nil {
        return nicknameRes!
    }
    //not a nickname, check if it's a valid target name
    res = ""
    var ascVal: UInt8 = 0
    for c in target {
        if c.asciiValue == nil {continue}
        ascVal = c.asciiValue!
        //include alphanumerics only
        if (ascVal > 96 && ascVal < 123) || (ascVal > 47 && ascVal < 58) {
            res.append(c)
        }
    }
    if res == "" {return inputTarget}
    res = res.uppercased()
    if res.prefix(7) == "MESSIER" {
        res = "M" + res.suffix(res.count - 7)
    } else if !res.last!.isNumber {//a planet target
        res = res.prefix(1).uppercased() + res.dropFirst().lowercased()
    }
    return res
}

func formattedTargetToTargetName(target: String) -> String {
    var res = target
    if target.count > 1 && target.prefix(1) == "M" && MessierConst[Int(String(target.suffix(target.count - 1))) ?? -1] != nil {
        res = "Messier " + String(target.suffix(target.count - 1))
    } else if target.count > 3 && target.prefix(3) == "NGC" && NGCConst[Int(String(target.suffix(target.count - 3))) ?? -1] != nil {
        res = "NGC " + String(target.suffix(target.count - 3))
    } else if target.count > 2 && target.prefix(2) == "IC" && ICConst[Int(String(target.suffix(target.count - 2))) ?? -1] != nil {
        res = "IC " + String(target.suffix(target.count - 2))
    }
    return res
}

class WelcomeViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signUpEmailField: UITextField!
    @IBOutlet weak var signUpPasswordField: UITextField!
    @IBOutlet weak var signUpPasswordConfirmField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInEmailField: UITextField!
    @IBOutlet weak var logInPasswordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var  welcomeLabelLeadingC: NSLayoutConstraint!
    @IBOutlet weak var welcomeLabelTopCipad: NSLayoutConstraint!
    @IBOutlet weak var paragraphTopCipad: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonTrailingC: NSLayoutConstraint!
    @IBOutlet weak var loginButtonTrailingC: NSLayoutConstraint!
    @IBOutlet weak var forgotEmailTopC: NSLayoutConstraint!
    var activeField: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for subview in welcomeView.subviews {
            subview.isHidden = true
        }
        if screenH < 600 {//iphone SE, 5s
            welcomeLabelLeadingC.constant = 15
            signUpButtonTrailingC.constant = 4
            loginButtonTrailingC.constant = 4
        } else if screenW < 400 {//iphone 8, 11
            welcomeLabelLeadingC.constant = 43
        } else if screenH > 1000 {//ipads
            background.image = UIImage(named: "Welcome/background-ipad")
            border.image = UIImage(named: "border-ipad")
            forgotEmailTopC.constant = 50
            if screenH > 1050 {//10.5, 11, 12,9
                paragraphTopCipad.constant = screenH * 0.05
            }
            if screenH > 1200 {//12.9
                welcomeLabelTopCipad.constant = 200
            }
        }
        for field in [signUpEmailField, signUpPasswordField, signUpPasswordConfirmField, logInEmailField, logInPasswordField] {
            field!.layer.borderColor = UIColor.white.cgColor
            field!.layer.borderWidth = 1.0
            field!.delegate = (self as UITextFieldDelegate)
            field!.autocorrectionType = .no
        }
        scrollView.delegate = (self as UIScrollViewDelegate)
    }
    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
      viewControllerToPresent.modalPresentationStyle = .fullScreen
      super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    override func viewDidAppear(_ animated: Bool) {
        activeField?.resignFirstResponder()


//        db.collection("imageOfDayKeys").document(todayDate).setData(["imageKey": imageKey, "journalEntryInd": 0, "journalEntryListKey": journalEntryKey,"userKey": userKey], merge: false)
//        db.collection("imageOfDayLikes").document(todayDate).setData(["01JodwczOB4930pEfG3e": ""], merge: false)
//        db.collection("imageOfDayComments").document(todayDate).setData(["01JodwczOB4930pEfG3e29-08:37:00": "hi I'm Koso", "dCoSGcE9VEzij6An1wl829-11:37:00": "Hello this is Antoine"], merge: false)
        
        if Auth.auth().currentUser != nil {
            db.collection("userData").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments(completion: { (QuerySnapshot, Error) in
                if Error != nil {
                    print(Error!)
                } else {
                    if QuerySnapshot!.documents == [] {
                        do {
                            try Auth.auth().signOut()
                        }
                        catch let signOutError as NSError {
                            print ("Error signing out: %@", signOutError)
                        }
                        for subview in self.welcomeView.subviews {
                            subview.isHidden = false
                        }
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let initial = storyboard.instantiateInitialViewController()
                        UIApplication.shared.keyWindow?.rootViewController = initial
                    } else {
//                        do {
//                            try Auth.auth().signOut()
//                        }
//                        catch let signOutError as NSError {
//                            print ("Error signing out: %@", signOutError)
//                        }
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let initial = storyboard.instantiateInitialViewController()
//                        UIApplication.shared.keyWindow?.rootViewController = initial
                        
                        let data = QuerySnapshot!.documents[0]
                        KeychainWrapper.standard.set(data.documentID, forKey: "dbKey")
                        let userName = data["userName"]
                        if userName == nil {
                            self.performSegue(withIdentifier: "welcomeToProfileCreation", sender: self)
                        } else {
                            KeychainWrapper.standard.set(userName as! String, forKey: "userName")
                            self.performSegue(withIdentifier: "welcomeToCalendar", sender: nil)
                        }
                    }
                }
            })
        } else {
            for subview in welcomeView.subviews {
                subview.isHidden = false
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        activeField?.resignFirstResponder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if screenH < 1000 {
            if textField == signUpEmailField || textField == signUpPasswordField || textField == signUpPasswordConfirmField {
                scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - (screenH * 0.45)), animated: true)
            } else {
                let yOffset = contentView.bounds.height - scrollView.bounds.height
                scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
            }
        }
        activeField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func signUpButtonTapped(_ sender: Any) {
        startNoInput()
        if signUpPasswordField.text != signUpPasswordConfirmField.text {
            let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            endNoInput()
        } else {
            Auth.auth().createUser(withEmail: signUpEmailField.text!.lowercased(), password: signUpPasswordField.text!) { (user, error) in
                if error != nil {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.signUpButton.isHidden = true
                    self.loginButton.isHidden = true
                    var newDataRef: DocumentReference? = nil
                    newDataRef = db.collection("userData").addDocument(data: ["email": self.signUpEmailField.text!.lowercased()]) {err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            let docKey = newDataRef!.documentID
                            KeychainWrapper.standard.set(docKey, forKey: "dbKey")
                        }
                    }
                    self.performSegue(withIdentifier: "welcomeToProfileCreation", sender: self)
                }
                endNoInput()
            }
        }
    }
    @IBAction func logInButtonTapped(_ sender: Any) {
        startNoInput()
        Auth.auth().signIn(withEmail: logInEmailField.text!, password: logInPasswordField.text!) {(user, error) in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.signUpButton.isHidden = true
                self.loginButton.isHidden = true
                db.collection("userData").whereField("email", isEqualTo: self.logInEmailField.text!.lowercased()).limit(to: 1).getDocuments(completion: {(QuerySnapshot, Error) in
                    if Error != nil {
                        print(Error!)
                    } else {
                        let data = QuerySnapshot!.documents[0]
                        KeychainWrapper.standard.set(data.documentID, forKey: "dbKey")
                        if data["userName"] == nil {
                            self.performSegue(withIdentifier: "welcomeToProfileCreation", sender: self)
                        } else {
                            KeychainWrapper.standard.set(data["userName"] as! String, forKey: "userName")
                            print("sign-in successful")
                            self.performSegue(withIdentifier: "welcomeToCalendar", sender: self)
                        }
                    }
                })
            }
            endNoInput()
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    @IBAction func forgotEmailButtonTapped(_ sender: Any) {
        func composeEmail() {
            if MFMailComposeViewController.canSendMail() {
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = (self as MFMailComposeViewControllerDelegate)
                mailComposerVC.setToRecipients(["nevadaastrophotography@gmail.com"])
                mailComposerVC.setSubject("Forgot Email")
                mailComposerVC.setMessageBody("", isHTML: false)
                self.present(mailComposerVC, animated: true, completion: nil)
            }
        }
        let alertController = UIAlertController(title: "Forgot Email", message: "Please send an email to: nevadaastrophotography@gmail.com to recover your email. Please give us information such as username, description of profile image, etc. or contact Antoine the STUD", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {(alertAction) in composeEmail()})
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: logInEmailField.text!) {error in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: error!.localizedDescription + " Please fix it in the email field.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Email Sent", message: "A password reset email has been sent to your inbox.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

