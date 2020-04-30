import UIKit
class CardUnlockedViewController: UIViewController {
    @IBOutlet weak var unlockedLabel: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var unlockedDateLabel: UILabel!
    @IBOutlet weak var imageViewWC: NSLayoutConstraint!
    @IBOutlet weak var imageViewHC: NSLayoutConstraint!
    @IBOutlet weak var imageViewWCipad: NSLayoutConstraint!
    @IBOutlet weak var imageViewHCipad: NSLayoutConstraint!
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
        imageView.layer.shadowOpacity = 0.8
        if screenH < 600 {//iphone SE, 5s
            imageViewWC.constant = 210
            imageViewHC.constant = 313
        }
        else if screenH > 800 && screenH < 1000 {//iphone 11, pro max
            imageViewWC.constant = 350
            imageViewHC.constant = 522
        }
        else if screenH > 700 {//ipads
            unlockedDateLabel.font = unlockedDateLabel.font.withSize(17)
            if screenW > 1000 {//ipad 12.9
                imageViewWCipad.constant = 616
                imageViewHCipad.constant = 920
            }
        }
        showAnimate()
    }
    override func viewDidLayoutSubviews() {
        unlockedDateLabelTrailingC.constant = -(imageView.frame.size.width * CGFloat(0.064))
        if screenH < 600 {//iphone SE, 5s
            unlockedDateLabelTrailingC.constant = 5
        }
        unlockedDateLabelBottomC.constant = -(imageView.frame.size.height * 0.11)
        unlockedDateLabelTrailingCipad.constant = -(imageView.frame.size.width * 0.064)
        if screenH > 1300 {
            unlockedDateLabelTrailingCipad.constant = -(imageView.frame.size.width * 0.1)
        }
        unlockedDateLabelBottomCipad.constant = -(imageView.frame.size.height * 0.122)
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
