//
//  CardBackBackgroundsPopOverViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 5/9/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit

class CardBackBackgroundsPopOverViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var backgroundsCollectionView: UICollectionView!
    let backgroundNames = ["Earth & Moon", "Stars & Stripes", "Matrix", "Total Eclipse", "Voyage to the Stars"]
    var numCardBacks = 0
    var userKey = ""
    var cgvc: CardGroupsViewController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        if screenH < 1000 {//iphones
            layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 20
            layout.itemSize = CGSize(width: 118, height: 176)
        } else {
            layout.sectionInset = UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 30
            layout.itemSize = CGSize(width: 155, height: 231)
        }
        backgroundsCollectionView.collectionViewLayout = layout
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //numCardBacks = cgvc.
        numCardBacks = 6
        backgroundsCollectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numCardBacks
    }
    @objc func cardBackTapped(sender: UIGestureRecognizer) {
        let touch = sender.location(in: backgroundsCollectionView)
        let indexPath = backgroundsCollectionView.indexPathForItem(at: touch)
        if indexPath == nil {
            return
        }
        let selectedInd = indexPath!.row
        let cells = backgroundsCollectionView.visibleCells
        let startInd = backgroundsCollectionView.indexPath(for: cells[0])!.row
        for i in startInd..<startInd + cells.count {
            let cell = cells[i - startInd]
            if i == selectedInd {
                cell.layer.borderWidth = 3
                cell.layer.borderColor = (UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1).cgColor)
            } else {
                cell.layer.borderWidth = 1.3
                cell.layer.borderColor = UIColor.orange.cgColor
            }
        }
        var selectedCardBackNum = String(selectedInd + 1)
        if selectedInd == numCardBacks - 1 {
            selectedCardBackNum = "-1"
        }
        cgvc!.cardBackSelected = selectedCardBackNum
        db.collection("userData").document(userKey).setData(["cardBackSelected": selectedCardBackNum], merge: true)
        self.dismiss(animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = backgroundsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardBackBackgroundsCollectionViewCell
        let ind = indexPath.row
        if ind != numCardBacks - 1 {
            cell.imageView.image = UIImage(named: "Catalog/CardBacks/Backgrounds/" + String(ind + 1))!
            cell.backgroundNameLabel.text = backgroundNames[ind]
            if screenH > 1000 {
                cell.backgroundNameLabel.font = UIFont(name: "Pacifica Condensed", size: 18)
            }
        } else {
            cell.imageView.image = nil
            cell.backgroundNameLabel.text = ""
        }
        if ind == Int(cgvc!.cardBackSelected)! - 1 || (ind == numCardBacks - 1 && Int(cgvc!.cardBackSelected)! == -1) {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = (UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1).cgColor)
        } else {
            cell.layer.borderWidth = 1.3
            cell.layer.borderColor = UIColor.orange.cgColor
        }
        if cell.imageView.gestureRecognizers == nil {
            cell.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardBackTapped)))
        }
        return cell
    }
}
