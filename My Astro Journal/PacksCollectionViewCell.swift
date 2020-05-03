//
//  PacksCollectionViewCell.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 4/16/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit

class PacksCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBAction func moreInfoButtonTapped(_ sender: Any) {
        print(1)
    }
    @IBAction func priceButtonTapped(_ sender: Any) {
        print(2)
    }
}
