//
//  AddOnsViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 5/2/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit
class AddOnsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var packsCollectionView: UICollectionView!
    @IBOutlet weak var cardBacksCollectionView: UICollectionView!
    var packImageNames = ["pack1", "pack2", "pack3", "pack4"]
    var packDescriptions = ["Get your camouflage shirt on and jump into your cargo pants, it’s time to hunt some wild space animals!\n[No space animals were harmed in the making of this pack]", "A selection of very small and very large targets. How hungry is your camera tonight?", "The “Stars, Stars Everywhere” pack will add the following cards to your collection:", "It is midnight on October 31st. You are alone, far from home, and decide you want to image a scary looking object. What could go wrong?\nPsst: Try not to look behind you."]
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH > 1000 {//ipads
            background.image = UIImage(named: "Info/background-ipad")!
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == packsCollectionView {
            return packImageNames.count
        } else {
            return 4
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let i = indexPath.row
        if collectionView == packsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PacksCollectionViewCell
            cell.imageView.image = UIImage(named: "AddOns/" + packImageNames[i])!
            cell.descriptionTextView.text = packDescriptions[i]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardBacksCollectionViewCell
            return cell
        }
    }
}

