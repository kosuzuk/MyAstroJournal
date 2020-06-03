//
//  CardCell.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 4/16/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var numEntries: UILabel!
    @IBOutlet weak var newEntryColorView: UIView!
    var entryDate = ""
}
