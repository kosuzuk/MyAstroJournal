//
//  MoonForecastPopOverViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 6/18/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit

class MoonForecastPopOverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
           
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }


}
