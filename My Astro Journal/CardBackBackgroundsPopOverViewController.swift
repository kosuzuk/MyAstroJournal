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
    let backgroundNames = ["Earth & Moon", "Stars & Stripes", "Matrix", "Total Eclipse", "Voyage to the Stars", "Foggy Dreams", "Colors of Space", "Canyon Nights", "Digital Space", "Starburst", "Into the Wormhole", "Dusty", "Sparklers"]
    var cardBacksUnlocked: [String] = []
    var numCardBacks = 0
    var iphoneCellSize = CGSize(width: 75, height: 112)
    var ipadCellSize = CGSize(width: 90, height: 134)
    var bigIpadCellSize = CGSize(width: 112, height: 167)
    var cgvc: CardGroupsViewController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        if screenH < 1000 {//iphones
            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 15
            layout.itemSize = iphoneCellSize
        } else {
            if screenH < 1300 {
                layout.sectionInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
                layout.minimumInteritemSpacing = 0
                layout.minimumLineSpacing = 24
                layout.itemSize = ipadCellSize
            } else {
                layout.sectionInset = UIEdgeInsets(top: 10, left: 25, bottom: 5, right: 20)
                layout.minimumInteritemSpacing = 0
                layout.minimumLineSpacing = 24
                layout.itemSize = bigIpadCellSize
            }
        }
        backgroundsCollectionView.collectionViewLayout = layout
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        numCardBacks = 6 + cardBacksUnlocked.count
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
        for i in 0..<cells.count {
            let cell = cells[i]
            if backgroundsCollectionView.indexPath(for: cell)!.row == selectedInd {
                cell.layer.borderWidth = 2
                cell.layer.borderColor = (UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1).cgColor)
            } else {
                cell.layer.borderWidth = 1.3
                cell.layer.borderColor = astroOrange
            }
        }
        var selectedCardBackNum = String(selectedInd + 1)
        if selectedInd == numCardBacks - 1 {
            selectedCardBackNum = "-1"
        } else if selectedInd >= 5 {
            selectedCardBackNum = cardBacksUnlocked[selectedInd - 5]
        }
        cgvc!.cardBackSelected = selectedCardBackNum
        db.collection("userData").document(cgvc!.userKey).setData(["cardBackSelected": selectedCardBackNum], merge: true)
        self.dismiss(animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = backgroundsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardBackBackgroundsCollectionViewCell
        let ind = indexPath.row
        var selected = false
        if ind != numCardBacks - 1 {
            if ind < 5 {
                cell.imageView.image = UIImage(named: "Catalog/CardBacks/Backgrounds/" + String(ind + 1))
                cell.backgroundNameLabel.text = backgroundNames[ind]
                if String(ind + 1) == cgvc!.cardBackSelected {
                    selected = true
                }
            } else {
                cell.imageView.image = UIImage(named: "AddOns/CardBacks/Backgrounds/" + cardBacksUnlocked[ind - 5])
                cell.backgroundNameLabel.text = backgroundNames[Int(cardBacksUnlocked[ind - 5])! - 1]
                if ind - 5 == cardBacksUnlocked.index(of: cgvc!.cardBackSelected) {
                    selected = true
                }
            }
            cell.backgroundNameLabel.preferredMaxLayoutWidth = iphoneCellSize.width - 5
            if screenH > 1000 {
                cell.backgroundNameLabel.font = cell.backgroundNameLabel.font.withSize(16)
                cell.backgroundNameLabel.preferredMaxLayoutWidth = ipadCellSize.width - 8
            }
        } else {
            cell.imageView.image = nil
            cell.backgroundNameLabel.text = "None"
            if cgvc!.cardBackSelected == "-1" {
                selected = true
            }
        }
        if selected {
            cell.layer.borderWidth = 2
            cell.layer.borderColor = (UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1).cgColor)
        } else {
            cell.layer.borderWidth = 1.3
            cell.layer.borderColor = astroOrange
        }
        if cell.imageView.gestureRecognizers == nil {
            cell.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardBackTapped)))
        }
        return cell
    }
}
