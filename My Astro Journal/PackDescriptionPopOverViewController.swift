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
    override func viewDidLoad() {
        super.viewDidLoad()
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



