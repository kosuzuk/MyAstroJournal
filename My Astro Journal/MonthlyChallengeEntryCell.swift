//
//  MonthlyChallengeEntryCell.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 5/13/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit

class MonthlyChallengeEntryCell: UITableViewCell {
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var usernameBackground: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameLabelWC: NSLayoutConstraint!
    var mcvc: MonthlyChallengeViewController? = nil
    @IBAction func profileButtonTapped(_ sender: Any) {
        let entryKey = mcvc!.basicEntryDataList[mcvc!.entriesTableView.indexPath(for: self)!.row]["key"]!
        mcvc!.profileToShowKey = String(entryKey.prefix(entryKey.count - 8))
        mcvc!.performSegue(withIdentifier: "monthlyChallengeToProfile", sender: mcvc!)
    }
}
