//
//  EquipmentBrandsTableViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 4/30/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit

class EquipmentPopOverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var eqTableView: UITableView!
    let viewW = CGFloat(245)
    let viewH = CGFloat(170)
    var displayingBrands = true
    var eqType = ""
    var brandList: [String] = []
    var selectedBrand = ""
    var nameList: [String] = []
    var pcvc: ProfileCreationViewController? = nil
    var pevc: ProfileEditViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if eqType == "telescope" {
            brandList = telescopeBrands
        } else if eqType == "mount" {
            brandList = mountBrands
        } else if eqType == "camera" {
            brandList = cameraBrands
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayingBrands {
            return brandList.count
        } else  {
            return nameList.count
        }
    }
    @objc func cellButtonTapped(_ sender: UIButton) {
        let ind = sender.tag
        if displayingBrands {
            if eqType == "telescope" {
                selectedBrand = brandList[ind]
                nameList = telescopeNames[selectedBrand]!
            } else if eqType == "mount" {
                selectedBrand = brandList[ind]
                nameList = mountNames[selectedBrand]!
            } else if eqType == "camera" {
                selectedBrand = brandList[ind]
                nameList = cameraNames[selectedBrand]!
            }
            nameList.insert("    back", at: 0)
            displayingBrands = false
            for view in self.view.subviews {view.frame.origin.x += self.viewW}
            self.eqTableView.reloadData()
            UIView.animate(withDuration: 0.4, animations: {for view in self.view.subviews {view.frame.origin.x -= self.viewW}}, completion: nil)
        } else {
            //first ind is back button
            if ind == 0 {
                nameList = []
                displayingBrands = true
                for view in self.view.subviews {view.frame.origin.x -= self.viewW}
                self.eqTableView.reloadData()
                UIView.animate(withDuration: 0.4, animations: {for view in self.view.subviews {view.frame.origin.x += self.viewW}}, completion: nil)
            } else {
                pevc?.selectedEqName = selectedBrand + " " + nameList[ind]
                pcvc?.selectedEqName = selectedBrand + " " + nameList[ind]
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eqCell", for: indexPath) as! EquipmentPopOverTableViewCell
        if !displayingBrands && indexPath.row == 0 {
            cell.prevArrowImageView.isHidden = false
        } else {
            cell.prevArrowImageView.isHidden = true
        }
        var btn = UIButton()
        var hasButton = false
        for view in cell.subviews {
            if view is UIButton {
                btn = view as! UIButton
                hasButton = true
            }
        }
        btn.tag = indexPath.row
        if displayingBrands {
            btn.setTitle(brandList[indexPath.row], for: .normal)
            cell.nextArrowImageView.isHidden = false
        } else {
            btn.setTitle(nameList[indexPath.row], for: .normal)
            cell.nextArrowImageView.isHidden = true
        }
        if !hasButton {
            btn.titleLabel!.font =  UIFont(name: "Pacifica Condensed", size: 17)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.contentHorizontalAlignment = .left
            btn.frame = CGRect(x: 7, y: 0, width: cell.bounds.width, height: cell.bounds.height)
            btn.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
            cell.addSubview(btn)
        }
        return cell
    }
}

