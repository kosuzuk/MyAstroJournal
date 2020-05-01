//
//  EquipmentBrandsTableViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 4/30/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit

class EquipmentPopOverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var eqType = ""
    var popUpType = ""
    var brand = ""
    var brandList: [String] = []
    var nameList: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if eqType == "telescope" {
            if popUpType == "brand" {
                brandList = telescopeBrands
            } else if popUpType == "name" {
                nameList = telescopeNames[brand]!
            }
        } else if eqType == "mount" {
            if popUpType == "brand" {
                brandList = mountBrands
            } else if popUpType == "name" {
                nameList = mountNames[brand]!
            }
        } else if eqType == "camera" {
            if popUpType == "brand" {
                brandList = cameraBrands
            } else if popUpType == "name" {
                nameList = cameraNames[brand]!
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if popUpType == "brand" {
            return brandList.count
        } else if popUpType == "name" {
            return nameList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eqCell", for: indexPath) as! EquipmentPopOverTableViewCell
        if popUpType == "brand" {
            cell.eqButton.setTitle(brandList[indexPath.row], for: .normal)
        } else if popUpType == "name" {
            cell.eqButton.setTitle(nameList[indexPath.row], for: .normal)
        }
        return cell
    }
}

