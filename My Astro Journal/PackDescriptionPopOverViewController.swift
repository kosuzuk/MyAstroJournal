//
//  packDescriptionPopOverViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 4/16/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit

class PackDescriptionPopOverViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var textViewHC: NSLayoutConstraint!
    @IBOutlet weak var closeButtonWC: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH < 600 {//iphpone SE, 5s
            textViewHC.constant = 300
        } else if screenH > 1000 {//ipads
            closeButtonWC.constant = 50
            closeButton.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 35)
        }
        if #available(iOS 13.3, *) {
        } else {
            closeButton.setTitle("X", for: .normal)
            closeButton.setTitleColor(.white, for: .normal)
        }

        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        showAnimate()
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
}



