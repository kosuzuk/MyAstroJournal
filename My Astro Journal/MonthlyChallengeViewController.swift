//
//  MonthlyChallengeViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 5/13/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit

class MonthlyChallengeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var entriesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        endNoInput()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MonthlyChallengeEntryCell
        return cell
    }
}

