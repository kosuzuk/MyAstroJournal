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
        brandList.append("custom")
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
        //custom eq that's not in list
        if displayingBrands {
            if ind == brandList.count - 1 {
                pevc?.popOverController = nil
                self.dismiss(animated: true, completion: nil)
                return
            }
            selectedBrand = brandList[ind]
            if eqType == "telescope" {
                nameList = telescopeNames[selectedBrand]!
            } else if eqType == "mount" {
                nameList = mountNames[selectedBrand]!
            } else if eqType == "camera" {
                nameList = cameraNames[selectedBrand]!
            }
            nameList.insert("    back", at: 0)
            nameList.append("custom")
            displayingBrands = false
            for view in self.view.subviews {view.frame.origin.x += self.viewW}
            self.eqTableView.reloadData()
            self.eqTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
            UIView.animate(withDuration: 0.4, animations: {
                for view in self.view.subviews {view.frame.origin.x -= self.viewW}
            }, completion: nil)
        } else {
            //custom eq that's not in list
            if ind == nameList.count - 1 {
                pevc?.popOverController = nil
                self.dismiss(animated: true, completion: nil)
                return
            }
            //first ind is back button
            if ind == 0 {
                nameList = []
                displayingBrands = true
                for view in self.view.subviews {view.frame.origin.x -= self.viewW}
                self.eqTableView.reloadData()
                UIView.animate(withDuration: 0.4, animations: {
                    for view in self.view.subviews {view.frame.origin.x += self.viewW}
                }, completion: nil)
            } else {
                pevc?.selectedEqName = selectedBrand + " " + nameList[ind]
                pcvc?.selectedEqName = selectedBrand + " " + nameList[ind]
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eqCell", for: indexPath) as! EquipmentPopOverTableViewCell
        if (!displayingBrands && indexPath.row == 0) {
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
            if indexPath.row != brandList.count - 1 {
                cell.nextArrowImageView.isHidden = false
            } else {
                cell.nextArrowImageView.isHidden = true
            }
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

