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
    var packImageNumbers = ["1", "2", "3", "4"]
    var packShortDescriptions = ["Get your camouflage shirt on and jump into your cargo pants, it’s time to hunt some wild space animals!\n[No space animals were harmed in the making of this pack]", "A selection of very small and very large targets. How hungry is your camera tonight?", "Star clusters deserve some love, too! Don’t let them drift away all by themselves!", "It is midnight on October 31st. You are alone, far from home, and decide you want to image a scary looking object. What could go wrong?"]
    var packLongDescriptions = ["The \"Animal Lover\" pack will add the following unlockable cards to your collection:\n\nNGC 457 - The Owl Cluster\nNGC 1501 - The Oyster Nebula\nNGC 4567 and NGC 4568 - The Butterfly Galaxies\nNGC 4676 - The Mice Galaxies\nNGC 6334 - The Cat’s Paw Nebula\nIC 417 - The Spider Nebula\nIC 1795 - The Fishhead Nebula\nIC 2177 - The Seagull Nebula\nIC 2944 - The Running Chicken Nebula\nIC 4592 - The Blue Horsehead Nebula\nSh2-129 - The Flying Bat Nebula\nSh2-157 - The Lobster Claw Nebula\n\nSorry, there are no cute little puppies in space.", "The \"David meets Goliath\" pack will add the following unlockable cards to your collection:\n\nThe Milky Way\nThe Sun\nRho Ophiuchi\nNGC 2440 - The Bow Tie Nebula\nNGC 4656 - The Hockey Stick Galaxy\nNGC 5474 - A galaxy responsible for M101’s asymmetry\nNGC 7009 - The Saturn Nebula\nNGC 7662 - The Blue Snowball Nebula\nIC 1318 - The Sadr Region\nSh2-240 - The Spaghetti Nebula\nArp 188 - The Tadpole Galaxy\nJu1 - The Soap Bubble Nebula\n\nDon’t try to get all these in one session. The sun isn’t going to help.", "The \"Stars, Stars Everywhere\" pack will add the following unlockable cards to your collection:\n\nNGC 1502 - Kemble’s Cascade\nNGC 2360 - Caroline’s Cluster\nNGC 2362 - The Tau Canis Majoris Cluster\nNGC 3532 - The Football Cluster\nNGC 4755 - The Jewel Box Cluster\nNGC 5466 - Cluster in Boötes\nNGC 6388 - Cluster in Scorpius\nNGC 6541 - Cluster in Corona Australis\nNGC 6723 - Cluster in Sagittarius\nNGC 6752 - Cluster in Pavo\nIC 2391 - The Omicron Velorum Cluster\nIC 2602 - The Southern Pleiades\n\nYou know who else loves star clusters that much? No one.", "The \"Spooky Encounters\" pack will add the following unlockable cards to your collection:\n\nNGC 246 - The Skull Nebula\nNGC 1535 - Cleopatra’s Eye Nebula\nNGC 2080 - The Ghost Head Nebula\nNGC 3242 - The Ghost of Jupiter Nebula\nNGC 6369 - The Little Ghost Nebula\nNGC 5907 - The Knife Edge Galaxy\nNGC 6741 - The Phantom Streak Nebula\nNGC 6781 - The Ghost of the Moon Nebula\nNGC 6826 - The Blink Nebula\nSh2-68 - The Death Eater Nebula\nSh2-136 - The Ghost Nebula\nOu4 - The Giant Squid Nebula\n\nPsst: Try not to look behind you."]
    var cardBackImageNumbers = ["1", "2", "3", "4", "5", "6", "7", "8"]
    var cardBackImageNames = ["Foggy Dreams", "Colors of Space", "Canyon Nights", "Digital Space", "Starburst", "Into the Wormhole", "Dusty", "Sparklers"]
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH > 1000 {//ipads
            background.image = UIImage(named: "Info/background-ipad")!
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == packsCollectionView {
            return packImageNumbers.count
        } else {
            return cardBackImageNumbers.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let i = indexPath.row
        if collectionView == packsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PacksCollectionViewCell
            cell.ind = i
            cell.imageView.image = UIImage(named: "AddOns/" + "Packs/" + packImageNumbers[i])!
            cell.descriptionTextView.text = packShortDescriptions[i]
            cell.aovc = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardBacksCollectionViewCell
            cell.ind = i
            cell.imageView.image = UIImage(named: "AddOns/" + "CardBacks/" + "Backgrounds/" +  cardBackImageNumbers[i])!
            cell.imageNameLabel.text = cardBackImageNames[i]
            cell.aovc = self
            return cell
        }
    }
    func packShowMoreInfo(_ ind: Int) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PackDescriptionPopOverViewController") as! PackDescriptionPopOverViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.textView.text = packLongDescriptions[ind]
        popOverVC.didMove(toParent: self)
    }
    func cardBackShowMoreInfo(_ ind: Int) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardBackDescriptionPopOverViewController") as! CardBackDescriptionPopOverViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.imageView.image = UIImage(named: "AddOns/" + "CardBacks/" + "Previews/" +  cardBackImageNumbers[ind])!
        popOverVC.textView.text = "This add-on will add the \"" +  cardBackImageNames[ind] + "\" Card Back to your collection."
        popOverVC.didMove(toParent: self)
    }
}

