import UIKit
import AVFoundation;

class FullImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var removeButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var removeButtonTrailingC: NSLayoutConstraint!
    var cardVC: CardViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        removeButton.isHidden = true
    }

    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if cardVC == nil {
            let imageW = imageView.image!.size.width
            let imageH = imageView.image!.size.height
            let imageViewW = imageView.bounds.width
            let imageViewH = imageView.bounds.height
            var xOffset = CGFloat(0)
            var yOffset = CGFloat(0)
            if (imageViewH / imageViewW) > (imageH / imageW) {
                yOffset = (imageViewH - imageH * (imageViewW / imageW)) / 2
            } else {
                xOffset = -(imageViewW - imageW * (imageViewH / imageH)) / 2
            }
            removeButtonTrailingC.constant = xOffset
            removeButtonTopC.constant = yOffset
            removeButton.isHidden = false
            showAnimate()
        }
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
    @IBAction func closePopup(sender: AnyObject) {
        removeAnimate()
    }
    @IBAction func imageViewTapped(_ sender: Any) {
        if cardVC != nil {
            self.view.removeFromSuperview()
            cardVC!.didDismissFullImage = true
        }
    }
}
