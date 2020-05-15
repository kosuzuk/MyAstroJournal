//
//  FirstViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import Foundation
import SwiftKeychainWrapper

class JournalEntryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gearImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var targetField: UILabel!
    @IBOutlet weak var constellationField: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var timeField: UILabel!
    @IBOutlet weak var locationField: UILabel!
    @IBOutlet weak var observedCheckImage: UIImageView!
    @IBOutlet weak var photographedCheckImage: UIImageView!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var featuredButton: UIButton!
    @IBOutlet weak var memoriesLabel: UILabel!
    @IBOutlet weak var memoriesField: UITextView!
    @IBOutlet weak var telescopeField: UILabel!
    @IBOutlet weak var mountField: UILabel!
    @IBOutlet weak var cameraField: UILabel!
    @IBOutlet weak var acquisitionField: UITextView!
    @IBOutlet weak var extraPhotosLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var contentViewHC: NSLayoutConstraint!
    @IBOutlet weak var contentViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var imageViewHCipad: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomC: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomCipad: NSLayoutConstraint!
    @IBOutlet weak var targetFieldWC: NSLayoutConstraint!
    @IBOutlet weak var arrowWC: NSLayoutConstraint!
    @IBOutlet weak var mountFieldWC: NSLayoutConstraint!
    var entryList: [Dictionary<String, Any>] = []
    var selectedEntryInd = 0
    var entryData: Dictionary<String, Any> = [:]
    var entryDate = ""
    var imageSelected: UIImage? = nil
    var featuredDate = ""
    var keysData: [String: Any]? = nil
    var cvc: CalendarViewController? = nil
    var jeevc: JournalEntryEditViewController? = nil
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(formatLoadingIcon(icon: loadingIcon))
        loadingIcon.startAnimating()
        if screenH > 1000 {//ipads
            background.image = UIImage(named: "ViewEntry/background-ipad")
            border.image = UIImage(named: "border-ipad")
            bigImageView.isHidden = true
        }
        bigImageView.layer.borderWidth = 2
        bigImageView.layer.borderColor = UIColor.orange.cgColor
        memoriesField.layer.borderWidth = 1
        memoriesField.layer.borderColor = UIColor.gray.cgColor
        acquisitionField.layer.borderWidth = 1
        acquisitionField.layer.borderColor = UIColor.gray.cgColor
        editButton.isHidden = true
        gearImage.isHidden = true
        imageCollectionView.isHidden = true
        featuredButton.isHidden = true
        
        entryData = entryList[selectedEntryInd]
        targetField.text = (entryData["target"]! as! String)
        constellationField.text = (entryData["constellation"]! as! String)
        let monthInt = Int(entryDate.prefix(2))!
        let monthStr = monthNames[monthInt - 1]
        dateField.text = monthStr + " " + String(Int(entryDate.prefix(4).suffix(2))!) + " " + String(entryDate.suffix(4))
        timeField.text = (entryData["timeStart"] as! String) + " to " + (entryData["timeEnd"] as! String)
        locationField.text = (entryData["locations"]! as! [String]).joined(separator: ", ")
        if let data = entryData["observed"] {
            if (data as! Bool) {
                observedCheckImage.image = UIImage(named: "ViewEntry/checkmark")
            }
        }
        if let data = entryData["photographed"] {
            if (data as! Bool) {
                photographedCheckImage.image = UIImage(named: "ViewEntry/checkmark")
            }
        }
        memoriesField.text = (entryData["memories"] as! String)
        telescopeField.text = (entryData["telescope"] as! String)
        mountField.text = (entryData["mount"] as! String)
        cameraField.text = (entryData["camera"] as! String)
        acquisitionField.text = (entryData["acquisition"] as! String)
        var mainImagePulled = false
        var imagesPulled = false
        func checkFinishedPullingImages() {
            if mainImagePulled && imagesPulled {
                if cvc != nil {//moved from calendar view controller
                    editButton.isHidden = false
                    gearImage.isHidden = false
                }
                loadingIcon.stopAnimating()
                endNoInput()
            }
        }
        let mainImageKey = entryData["mainImageKey"] as! String
        if mainImageKey != "" {
            let imageRef = storage.child(mainImageKey)
            imageRef.getData(maxSize: imgMaxByte) {data, Error in
                if let Error = Error {
                    print(Error)
                    mainImagePulled = true
                    checkFinishedPullingImages()
                } else {
                    self.bigImageView.image = UIImage(data: data!)
                    self.entryData["mainImage"] = UIImage(data: data!)
                    mainImagePulled = true
                    checkFinishedPullingImages()
                }
            }
        } else {
            bigImageView.isHidden = true
            mainImagePulled = true
            imageViewBottomC.constant = -140
            contentViewHC.constant = 910
            imageViewBottomCipad.constant = -140
            contentViewHCipad.constant = 910
        }
        let imageKeyList = entryData["imageKeys"] as! [String]
        var imageList = Dictionary<Int, UIImage>()
        if imageKeyList != [] {
            for (i, imageKey) in imageKeyList.enumerated() {
                let imageRef = storage.child(imageKey)
                imageRef.getData(maxSize: imgMaxByte) {data, Error in
                    if let Error = Error {
                        print(Error)
                        return
                    } else {
                        let image = UIImage(data: data!)
                        let cell = self.imageCollectionView.cellForItem(at: NSIndexPath(row: i, section: 0) as IndexPath) as! JournalEntryImageCell
                        cell.imageView.image = image
                        imageList[i] = image!
                        if imageList.count == imageKeyList.count {
                            self.entryData["imageList"] = imageList
                            imagesPulled = true
                            checkFinishedPullingImages()
                        }
                    }
                }
            }
        } else {
            extraPhotosLabel.isHidden = true
            contentViewHC.constant -= 157
            contentViewHCipad.constant -= 227
            imagesPulled = true
            checkFinishedPullingImages()
        }
        featuredDate = entryData["featuredDate"] as! String
        if featuredDate != "" && isEarlierDate(featuredDate, dateToday) {
            db.collection("imageOfDayKeys").document(featuredDate).getDocument(completion: {(snapshot, Error) in
                if Error != nil {
                    print(Error!)
                } else {
                    self.keysData = snapshot!.data()!
                    self.featuredButton.isHidden = false
                }
            })
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if screenH < 600 {//iphone SE, 5s
            targetFieldWC.constant = 145
            arrowWC.constant = 135
            mountFieldWC.constant = 98
        }
        else if screenH > 1000 {//ipads
            imageViewHCipad.constant = bigImageView.bounds.width * 0.6
            contentViewHCipad.constant = imageCollectionView.frame.origin.y + imageViewHCipad.constant
            if entryData["mainImageKey"] as! String != "" {
                self.bigImageView.isHidden = false
            } else {
                imageViewBottomCipad.constant = -imageViewHCipad.constant + 20
                contentViewHCipad.constant = contentViewHCipad.constant - imageViewHCipad.constant * 0.6
            }
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: imageCollectionView.bounds.height, height: imageCollectionView.bounds.height)
            imageCollectionView.collectionViewLayout = layout
        }
        jeevc = nil
        imageCollectionView.isHidden = false
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! JournalEntryImageCell
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JournalEntryEditViewController
        if vc != nil {
            vc!.entryDate = entryDate
            vc!.entryList = entryList
            vc!.selectedEntryInd = selectedEntryInd
            vc!.entryData = entryData
            vc!.featuredDate = featuredDate
            vc!.cvc = cvc
            jeevc = vc!
            return
        }
        let vc2 = segue.destination as? ImageOfDayViewController
        if vc2 != nil {
            vc2!.entryKey = keysData!["journalEntryListKey"] as! String
            vc2!.entryInd = selectedEntryInd
            vc2!.iodUserKey = keysData!["userKey"] as! String
            vc2!.imageData = bigImageView.image
            vc2!.featuredDate = featuredDate
            vc2!.cvc = cvc
            //not currently featured
            if featuredDate != featuredImageDate {
                vc2!.notEditable = true
            }
            cvc?.iodvc = vc2
            return
        }
    }
    @IBAction func featuredButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "journalEntryToImageOfDay", sender: self)
    }
    @IBAction func bigImageTapped(_ sender: Any) {
        imageSelected = bigImageView.image
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.imageView.image = imageSelected
        popOverVC.didMove(toParent: self)
    }
    @IBAction func imageCollectionViewTapped(_ sender: Any) {
        let touch = (sender as AnyObject).location(in: imageCollectionView)
        let indexPath = imageCollectionView.indexPathForItem(at: touch)
        if indexPath == nil {
            return
        }
        imageSelected = (imageCollectionView.cellForItem(at: indexPath!) as! JournalEntryImageCell).imageView.image
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullImageViewController") as! FullImageViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(popOverVC.view)
        popOverVC.imageView.image = imageSelected
        popOverVC.didMove(toParent: self)
    }
}

