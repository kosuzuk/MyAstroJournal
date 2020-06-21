//
//  MoonForecastPopOverViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 6/18/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit

class MoonForecastPopOverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var forecastsTableView: UITableView!
    let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MoonForecastTableViewCell
        let date = Calendar.current.date(byAdding: .day, value: indexPath.row + 1, to: Date())!
        let moonIllumination = suncalc.getMoonIllumination(date: date)
        let moonPhase = moonIllumination["phase"]!
        let ilumPerc = moonIllumination["fraction"]!
        cell.moonImageView.image = moonPhaseValueToImg(moonPhase)
        let dateComps = Calendar.current.dateComponents([.weekday, .month, .day], from: date)
        cell.forecastLabel.text = weekDays[dateComps.weekday! - 1] + ", " + monthNames[dateComps.month! - 1] + " " + String(dateComps.day!) + ": " + String(Int(ilumPerc * 100.0)) + "%"
        return cell
    }
}
