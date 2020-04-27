import UIKit
class CongratsViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var seeButton: UIButton!
    @IBOutlet weak var buttonBottomC: NSLayoutConstraint!
    var keysData: [String: Any]? = nil
    var featuredDate = ""
    var imageData: UIImage? = nil
    var cvc: CalendarViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        imageView.layer.shadowOpacity = 0.8
        seeButton.isHidden = true
        showAnimate()
        db.collection("imageOfDayKeys").document(featuredDate).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                self.keysData = snapshot!.data()!
                storage.child(snapshot!.data()!["imageKey"] as! String).getData(maxSize: imgMaxByte) {imageData, Error in
                    if let Error = Error {
                        print("no image data for featured entry", Error)
                        return
                    } else {
                        self.imageData = UIImage(data: imageData!)!
                        self.seeButton.isHidden = false
                    }
                }
            }
        })
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ImageOfDayViewController
        vc?.entryKey = keysData!["journalEntryListKey"] as! String
        vc?.entryInd = keysData!["journalEntryInd"] as! Int
        vc?.iodUserKey = keysData!["userKey"] as! String
        vc?.imageData = imageData
        vc?.featuredDate = featuredDate
        //not currently featured
        if featuredDate != featuredImageDate {
            vc?.notEditable = true
        }
        vc?.cvc = cvc
        cvc?.iodvc = vc
    }
    
    @IBAction func seeEntryButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "congratsToIod", sender: self)
    }
    
    @IBAction func closePopup(sender: AnyObject) {
        removeAnimate()
    }
}
