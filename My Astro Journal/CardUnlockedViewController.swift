import UIKit
class CardUnlockedViewController: UIViewController {
    @IBOutlet weak var unlockedLabel: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var unlockedDateLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageViewWC: NSLayoutConstraint!
    @IBOutlet weak var imageViewWCipad: NSLayoutConstraint!
    @IBOutlet weak var unlockedLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelBottomC: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelTrailingC: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelBottomCipad: NSLayoutConstraint!
    @IBOutlet weak var unlockedDateLabelTrailingCipad: NSLayoutConstraint!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        if screenH < 600 {//iphone SE, 5s
            imageViewWC.constant = 250
        }
        else if screenH > 800 && screenH < 1000 {//iphone 11, pro max
            imageViewWC.constant = 350
        }
        else if screenH > 1000 {//ipads
            unlockedDateLabel.font = unlockedDateLabel.font.withSize(17)
            if screenH > 1300 {//ipad 12.9
                imageViewWCipad.constant = 616
            }
        }
        showAnimate()
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
    override func viewDidLayoutSubviews() {
        if screenH < 600 {//iphone SE, 5s
            unlockedLabelTopC.constant = 10
        }
        adjustUnlockedDateLabelPos()
    }
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        })
    }
    @IBAction func closePopup(sender: AnyObject) {
        self.removeAnimate()
    }
}
