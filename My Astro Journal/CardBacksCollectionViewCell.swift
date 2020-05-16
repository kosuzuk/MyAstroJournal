//
//  CardBacksCollectionViewCell.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 4/16/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit

class CardBacksCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageNameLabel: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var priceButton: UIButton!
    var ind = 0
    var aovc: AddOnsViewController? = nil
    
    @IBAction func moreInfoButtonTapped(_ sender: Any) {
        aovc!.cardBackShowMoreInfo(ind)
    }
    @IBAction func priceButtonTapped(_ sender: Any) {
        aovc!.cardBackPurchase(ind)
    }
}


