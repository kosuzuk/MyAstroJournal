import UIKit
import DropDown

class CardViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var entryDatesButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var unlockedDateLabel: UILabel!
    @IBOutlet weak var imageViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelTrailingC: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelBottomC: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelTrailingCipad: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelBottomCipad: NSLayoutConstraint!
    var target = ""
    var unlockedDate: String = "" {
        didSet {
            if unlockedDate != "" {
                unlockedDateLabel.isHidden = false
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
                entryDatesButton.isHidden = false
                journalEntryDateFormattedList = []
                for date in journalEntryDateList {
                    let formattedDate = monthNames[Int(date.prefix(2))! - 1] + " " + String(Int(date.prefix(4).suffix(2))!) + " " + String(date.suffix(4))
                    journalEntryDateFormattedList.append(formattedDate)
                }
                entryDatesDropDown.anchorView = entryDatesButton
                entryDatesDropDown.backgroundColor = .gray
                entryDatesDropDown.textColor = .white
                entryDatesDropDown.textFont = UIFont(name: "Pacifica Condensed", size: 16)!
                entryDatesDropDown.separatorColor = .white
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
    var selectedDate = ""
    var entryListData: [Dictionary<String, Any>]? = nil
    var views: [UIView] = []
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
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.right:
                    entryDatesDropDown.hide()
                    cardSwiped(swipeGesture)
                case UISwipeGestureRecognizer.Direction.left:
                    entryDatesDropDown.hide()
                    cardSwiped(swipeGesture)
                default:
                    break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.imageView.layer.shadowOpacity = 0.8
        self.showAnimate()
        unlockedDateLabel.isHidden = true
        entryDatesButton.isHidden = true
        if screenW > 700 {//ipads
            entryDatesButton.titleLabel?.font =  entryDatesButton.titleLabel?.font.withSize(22)
            unlockedDateLabel.font = unlockedDateLabel.font.withSize(18)
            if screenW > 1000 {//ipad 12.9
                imageViewHCipad.constant = 970
            }
        }
        views = [imageView, entryDatesButton, closeButton, unlockedDateLabel]
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeWhileDDShowing))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        entryDatesDropDown.plainView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeWhileDDShowing))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        entryDatesDropDown.plainView.addGestureRecognizer(swipeLeft)
    }
    override func viewDidAppear(_ animated: Bool) {
        let imageViewW = imageView.frame.size.width
        let imageViewH = imageView.frame.size.height
        unlockedDateLabelTrailingC.constant = -(imageViewW * 0.05)
        if screenH < 600 {//iphone SE, 5s
            unlockedDateLabelTrailingC.constant = 5
        }
        else if screenH < 700 {//8
            unlockedDateLabelTrailingC.constant = -(imageViewW * 0.03)
        }
        else if screenH > 800 && screenH < 1000 {//
            unlockedDateLabelTrailingC.constant = -(imageViewW * 0.067)
        }
        unlockedDateLabelBottomC.constant = -(imageViewH * 0.11)
        unlockedDateLabelTrailingCipad.constant = -(imageViewW * 0.07)
        if screenH > 1300 {
            unlockedDateLabelTrailingCipad.constant = -(imageView.frame.size.width * 0.1)
        }
        unlockedDateLabelBottomCipad.constant = -(imageViewH * 0.11)
    }
    
    @IBAction func showEntryDates(_ sender: Any) {
        entryDatesDropDown.show()
    }
    func moveR(_: Bool) {
        for view in views{view.frame.origin.x -= screenW * 2}
        catalogVC!.swipeDir = "right"
        UIView.animate(withDuration: 0.2, animations: {for view in self.views{view.frame.origin.x += screenW}}, completion: nil)
    }
    func moveL(_: Bool) {
        for view in views{view.frame.origin.x += screenW * 2}
        catalogVC!.swipeDir = "left"
        UIView.animate(withDuration: 0.2, animations: {for view in self.views{view.frame.origin.x -= screenW}}, completion: nil)
    }
    @IBAction func cardSwiped(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.right:
                    if catalogVC!.curCardInd == 0 {break}
                    UIView.animate(withDuration: 0.2, animations: {for view in self.views{view.frame.origin.x += screenW}}, completion: moveR)
                case UISwipeGestureRecognizer.Direction.left:
                    if catalogVC!.curCardInd == catalogVC!.cardLastInd {break}
                    UIView.animate(withDuration: 0.2, animations: {for view in self.views{view.frame.origin.x -= screenW}}, completion: moveL)
                default:
                    break
            }
        }
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.catalogVC?.cardJustClosed = true
                self.catalogVC?.showingCard = false
                self.view.removeFromSuperview()
            }
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
    }
}
