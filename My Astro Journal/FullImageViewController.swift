import UIKit
import AVFoundation;

class FullImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var removeButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var removeButtonTrailingC: NSLayoutConstraint!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        imageView.layer.shadowOpacity = 0.8
        showAnimate()
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
        let imageFrame = AVMakeRect(aspectRatio: imageView.image!.size, insideRect: imageView.bounds)
        removeButtonTopC.constant = imageFrame.origin.y
        removeButtonTrailingC.constant = imageFrame.origin.x
        removeButton.isHidden = false
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
        self.removeAnimate()
    }
}
