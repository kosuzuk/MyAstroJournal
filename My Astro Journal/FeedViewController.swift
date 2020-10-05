//
//  FeedViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 7/13/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchTargetField: UITextField!
    @IBOutlet weak var entryTableView: UITableView!
    var entriesData: [[String: Any]] = [[:]]
    var userImageDict: [String: UIImage] = [:]
    var numberOfRows = 100
    override func viewDidLoad() {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedEntryCell
        return cell
    }

    @IBAction func friendsOnlyButton(_ sender: Any) {
    }
}
