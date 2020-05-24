import UIKit
import DropDown

class CardViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var entryDatesButton: UIButton!
    @IBOutlet weak var featuredIcon: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var unlockedDateLabel: UILabel!
    @IBOutlet weak var flipCardButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nasaButton: UIButton!
    @IBOutlet weak var mapAreaImageView: UIImageView!
    @IBOutlet weak var imageViewCenterYC: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopC: NSLayoutConstraint!
    @IBOutlet weak var imageViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelTrailingC: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelBottomC: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelBottomCipad: NSLayoutConstraint!
    @IBOutlet weak var nasaButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var nasaButtonTrailingC: NSLayoutConstraint!
    var target = ""
    var cardImage: UIImage? = nil
    var unlockedDate: String = "" {
        didSet {
            if unlockedDate != "" {
                unlockedDateLabel.text = monthNames[Int(unlockedDate.prefix(2))! - 1] + " " + String(Int(unlockedDate.prefix(4).suffix(2))!) + " " + String(unlockedDate.suffix(4))
            }
        }
    }
    var userKey = ""
    let entryDatesDropDown = DropDown()
    var journalEntryDateFormattedList: [String] = []
    var journalEntryDateList: [String] = [] {
        didSet {
            if journalEntryDateList != [] {
                journalEntryDateFormattedList = []
                for date in journalEntryDateList {
                    let formattedDate = monthNames[Int(date.prefix(2))! - 1] + " " + String(Int(date.prefix(4).suffix(2))!) + " " + String(date.suffix(4))
                    journalEntryDateFormattedList.append(formattedDate)
                }
                entryDatesDropDown.anchorView = entryDatesButton
                entryDatesDropDown.backgroundColor = .darkGray
                entryDatesDropDown.textColor = .white
                entryDatesDropDown.textFont = UIFont(name: "Pacifica Condensed", size: 16)!
                entryDatesDropDown.selectionBackgroundColor = .darkGray
                entryDatesDropDown.selectedTextColor = .white
                entryDatesDropDown.cellHeight = 34
                entryDatesDropDown.cornerRadius = 10
                entryDatesDropDown.bottomOffset = CGPoint(x: -5, y: 28)
                entryDatesDropDown.dataSource = journalEntryDateFormattedList
                entryDatesDropDown.selectionAction = {(index: Int, item: String) in
                    let date = self.journalEntryDateList[self.journalEntryDateFormattedList.index(of: item)!]
                    self.selectedDate = date
                    let docRef = db.collection("journalEntries").document(self.userKey + date)
                    docRef.getDocument(completion: {(QuerySnapshot, Error) in
                        if Error != nil {
                            print(Error!)
                        } else {
                            let dbdata = QuerySnapshot!.data()
                            if dbdata != nil {
                                self.entryListData = (dbdata!["data"] as! [Dictionary<String, Any>])
                                self.performSegue(withIdentifier: "cardToJournalEntry", sender: self)
                            }
                        }
                    })
                }
            }
        }
    }
    var featuredDate = ""
    var iodKeysData: [String: Any]? = nil
    var iodImageData: UIImage? = nil
    var selectedDate = ""
    var entryListData: [Dictionary<String, Any>]? = nil
    var frontDisplayed = true
    var cardInfoImage: UIImage? = nil
    var backgroundImage: UIImage? = nil
    var items: [UIView] = []
    var photographerProfileKeys = ["a": "a"]
    var didDismissFullImage = false {
        didSet {
            imageView.isHidden = false
            closeButton.isHidden = false
            flipCardButton.isHidden = false
        }
    }
    var catalogVC: CardCatalogViewController? = nil
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @objc func swipeWhileDDShowing(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == UISwipeGestureRecognizer.Direction.left || swipeGesture.direction == UISwipeGestureRecognizer.Direction.right {
                entryDatesDropDown.hide()
                cardSwiped(swipeGesture)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH < 600 {
            imageViewCenterYC.constant = -20
            imageViewTopC.constant = 17
        }
        else if screenH > 1000 {//ipads
            entryDatesButton.titleLabel?.font =  entryDatesButton.titleLabel?.font.withSize(22)
            unlockedDateLabel.font = unlockedDateLabel.font.withSize(18)
            if screenW > 1000 {//ipad 12.9
                imageViewHCipad.constant = 970
            }
        }
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        items = [imageView, backgroundImageView, entryDatesButton, unlockedDateLabel, featuredIcon, nasaButton, closeButton]
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeWhileDDShowing))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeWhileDDShowing))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        entryDatesDropDown.plainView.addGestureRecognizer(swipeRight)
        entryDatesDropDown.plainView.addGestureRecognizer(swipeLeft)
        nasaButton.isHidden = true
        if photographerProfileKeys[target] != nil {
            nasaButton.setImage(UIImage(named: "Profile/placeholderProfileImage"), for: .normal)
        }
        nasaButton.imageView?.contentMode = .scaleAspectFill
        mapAreaImageView.isUserInteractionEnabled = false
        self.showAnimate()
    }
    func adjustUnlockedDateLabelPos() {
        let imageViewH = imageView.frame.size.height
        let font = UIFont(name: unlockedDateLabel.font.fontName, size: unlockedDateLabel.font.pointSize)
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (unlockedDateLabel.text! as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
        unlockedDateLabelTrailingC.constant = -(imageViewH * 0.14) + size.width / 2
        unlockedDateLabelBottomC.constant = -(imageViewH * 0.125) + size.height / 2
        unlockedDateLabelTrailingCipad.constant = -(imageViewH * 0.14) + size.width / 2
        unlockedDateLabelBottomCipad.constant = -(imageViewH * 0.13) + size.height / 2
    }
    override func viewDidAppear(_ animated: Bool) {
        adjustUnlockedDateLabelPos()
        nasaButtonTopC.constant = imageView.bounds.height * 0.465
        if screenH < 670 {
            nasaButtonTopC.constant -= 10
        }
        nasaButtonTrailingC.constant = -imageView.bounds.width * 0.06
        entryDatesButton.isHidden = journalEntryDateList == []
        unlockedDateLabel.isHidden = unlockedDate == ""
        featuredIcon.isHidden = featuredDate == ""
    }
    
    @IBAction func showEntryDates(_ sender: Any) {
        entryDatesDropDown.show()
    }
    @IBAction func featuredIconTapped(_ sender: Any) {
        startNoInput()
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
        loadingIcon.startAnimating()
        db.collection("imageOfDayKeys").document(featuredDate).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                self.iodKeysData = snapshot!.data()!
                let imageRef = storage.child(self.iodKeysData!["imageKey"] as! String)
                imageRef.getData(maxSize: imgMaxByte) {data, Error in
                    if let Error = Error {
                        print(Error)
                        return
                    } else {
                        self.iodImageData = UIImage(data: data!)
                        self.performSegue(withIdentifier: "cardToImageOfDay", sender: self)
                        loadingIcon.stopAnimating()
                    }
                }
            }
        })
    }
    @IBAction func flipCardButtonTapped(_ sender: Any) {
        startNoInput()
        closeButton.isHidden = true
        if frontDisplayed {
            entryDatesButton.isHidden = true
            featuredIcon.isHidden = true
            unlockedDateLabel.isHidden = true
            UIView.animate(withDuration: 0.25, animations: {
                self.imageView.transform = CGAffineTransform(scaleX: 0.001, y: 1)
                self.backgroundImageView.transform = CGAffineTransform(scaleX: 0.001, y: 1)
            }, completion: {_ in
                self.imageView.image = self.cardInfoImage
                self.backgroundImageView.image = self.backgroundImage
                UIView.animate(withDuration: 0.25, animations: {
                    self.imageView.transform = CGAffineTransform.identity
                    self.backgroundImageView.transform = CGAffineTransform.identity
                }, completion: {_ in
                    self.closeButton.isHidden = false
                    self.nasaButton.isHidden = false
                    self.mapAreaImageView.isUserInteractionEnabled = true
                    endNoInput()
                })
            })
        } else {
            nasaButton.isHidden = true
            mapAreaImageView.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.25, animations: {
                self.imageView.transform = CGAffineTransform(scaleX: 0.001, y: 1)
                self.backgroundImageView.transform = CGAffineTransform(scaleX: 0.001, y: 1)
            }, completion: {_ in
                self.imageView.image = self.cardImage
                self.backgroundImageView.image = nil
                UIView.animate(withDuration: 0.25, animations: {
                    self.imageView.transform = CGAffineTransform.identity
                    self.backgroundImageView.transform = CGAffineTransform.identity
                }, completion: {_ in
                    self.entryDatesButton.isHidden = self.journalEntryDateList == []
                    self.featuredIcon.isHidden = self.featuredDate == ""
                    self.unlockedDateLabel.isHidden = self.unlockedDate == ""
                    self.closeButton.isHidden = false
                    endNoInput()
                })
            })
        }
        frontDisplayed = !frontDisplayed
    }
    @IBAction func nasaButtonTapped(_ sender: Any) {
        if photographerProfileKeys[target] != nil {
            performSegue(withIdentifier: "cardToProfile", sender: self)
        } else {
            var link = ""
            if catalogVC!.group == "Messier" {
                link = "https://www.nasa.gov/content/goddard/hubble-s-messier-catalog#images"
            } else if catalogVC!.group == "Planets" {
                link = "https://solarsystem.nasa.gov/planets/overview"
            } else {
                link = "https://www.spacetelescope.org/images"
            }
            let webURL = NSURL(string: link)!
            application.open(webURL as URL)
        }
    }
    @IBAction func mapButtonTapped(_ sender: Any) {
        if !frontDisplayed {
            let imageName = formattedTargetToImageName(target: target)
            //planets and milky way don't have constellation maps
            if imageName.prefix(1) == "P" || target == "Milkyway" {
                return
            }
            imageView.isHidden = true
            closeButton.isHidden = true
            flipCardButton.isHidden = true
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
            popOverVC.cardVC = self
            self.addChild(popOverVC)
            popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            self.view.addSubview(popOverVC.view)
            popOverVC.imageView.image = UIImage(named: "Catalog/CardBacks/ConstMaps/" + imageName)
            popOverVC.didMove(toParent: self)
        }
    }
    func moveL(_: Bool) {
        for item in items {item.frame.origin.x -= screenW * 2}
        nasaButton.isHidden = true
        mapAreaImageView.isUserInteractionEnabled = false
        catalogVC!.swipeDir = "right"
        UIView.animate(withDuration: 0.2, animations: {
            for item in self.items {item.frame.origin.x += screenW}
        }, completion: {_ in
            self.frontDisplayed = true
            self.adjustUnlockedDateLabelPos()
        })
    }
    func moveR(_: Bool) {
        for item in items {item.frame.origin.x += screenW * 2}
        nasaButton.isHidden = true
        mapAreaImageView.isUserInteractionEnabled = false
        catalogVC!.swipeDir = "left"
        UIView.animate(withDuration: 0.2, animations: {
            for item in self.items {item.frame.origin.x -= screenW}
        }, completion: {_ in
            self.frontDisplayed = true
            self.adjustUnlockedDateLabelPos()
        })
    }
    @IBAction func cardSwiped(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.right:
                    if catalogVC!.curCardInd == 0 {break}
                    UIView.animate(withDuration: 0.2, animations: {
                        for item in self.items {item.frame.origin.x += screenW}
                    }, completion: moveL)
                case UISwipeGestureRecognizer.Direction.left:
                    if catalogVC!.curCardInd == catalogVC!.cardLastInd {break}
                    UIView.animate(withDuration: 0.2, animations: {
                        for item in self.items {item.frame.origin.x -= screenW}
                    }, completion: moveR)
                default:
                    break
            }
        }
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {_ in
            self.catalogVC?.cardJustClosed = true
            self.catalogVC?.showingCard = false
            self.view.removeFromSuperview()
        })
    }

    @IBAction func closePopup(sender: AnyObject) {
        self.removeAnimate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JournalEntryViewController
        if vc != nil {
            vc?.entryDate = selectedDate
            vc?.entryList = entryListData!
            var selectedEntryInd = 0
            for i in 0...entryListData!.count - 1 {
                if entryListData![i]["formattedTarget"] as! String == self.target {
                    selectedEntryInd = i
                    break
                }
            }
            vc?.selectedEntryInd = selectedEntryInd
            return
        }
        let vc2 = segue.destination as? ImageOfDayViewController
        if vc2 != nil {
            vc2!.entryKey = iodKeysData!["journalEntryListKey"] as! String
            vc2!.entryInd = iodKeysData!["journalEntryInd"] as! Int
            vc2!.iodUserKey = iodKeysData!["userKey"] as! String
            vc2!.imageData = iodImageData
            vc2!.featuredDate = featuredDate
            let cvc = tabBarController!.viewControllers![0].children[0] as! CalendarViewController
            vc2!.cvc = cvc
            //not currently featured
            if featuredDate != featuredImageDate {
                vc2!.notEditable = true
            }
            cvc.iodvc = vc2
            return
        }
        let vc3 = segue.destination as? ProfileViewController
        if vc3 != nil {
            vc3?.keyForDifferentProfile = photographerProfileKeys[target]!
        }
    }
}
