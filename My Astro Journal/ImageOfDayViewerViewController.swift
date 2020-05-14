//
//  ImageOfDayViewerViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 4/16/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import FirebaseFirestore

infix operator ¡
//returns true if date1 is later than or equal to date2
func ¡(entry1: Dictionary<String, Any>, entry2: Dictionary<String, Any>) -> Bool {
    let date1 = String((entry1["featuredDate"] as! String).suffix(8))
    let date2 = String((entry2["featuredDate"] as! String).suffix(8))
    return isEarlierDate(date1, date2)
}

class ImageOfDayViewerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var entriesCollectionView: UICollectionView!
    var iodKeysList: [[String: Any]] = []
    var entryImageDataListTemp: [[String: Any]] = []
    var entryImageDataList: [UIImage] = []
    var numImages = 0
    var numImagesLoaded = 0 {
        didSet {
            if numImagesLoaded == numImages {
                entryImageDataListTemp.sort(by: ¡)
                for i in 0..<entryImageDataListTemp.endIndex {
                    entryImageDataList.append(entryImageDataListTemp[i]["imageData"] as! UIImage)
                }
                entriesCollectionView.reloadData()
            }
        }
    }
    var entryDateToShow = ""
    var entryListDataToShow: [[String: Any]] = []
    var entryListIndToShow = 0
    var profileKeyToShow = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db.collection("imageOfDayKeys").getDocuments (completion: {(QuerySnapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                for doc in QuerySnapshot!.documents {
                    if !isEarlierDate(doc.documentID, dateToday) {
                        var data = doc.data()
                        if data.count != 0 {
                            data["featuredDate"] = doc.documentID
                            self.iodKeysList.append(data)
                        }
                    }
                }
                //sort starting from today to future features
                self.iodKeysList.sort(by: ¡)
                self.numImages = self.iodKeysList.endIndex
                for entry in self.iodKeysList {
                    storage.child(entry["imageKey"] as! String).getData(maxSize: imgMaxByte) {data, Error in
                        if Error == nil {
                            self.entryImageDataListTemp.append(["featuredDate": entry["featuredDate"] as! String, "imageData": UIImage(data: data!)!])
                            self.numImagesLoaded += 1
                        }
                    }
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JournalEntryViewController
        if vc != nil {
            vc?.entryDate = entryDateToShow
            vc?.entryList = entryListDataToShow
            vc?.selectedEntryInd = entryListIndToShow
        }
        let vc2 = segue.destination as? ProfileViewController
        if vc2 != nil {
            vc2!.keyForDifferentProfile = profileKeyToShow
        }
    }
    
    @objc func showEntry(sender: UIGestureRecognizer) {
        let indexPath = entriesCollectionView.indexPathForItem(at: sender.location(in: entriesCollectionView))
        if indexPath != nil {
            let docRef = db.collection("journalEntries").document(iodKeysList[indexPath!.row]["journalEntryListKey"] as! String)
            docRef.getDocument(completion: {(QuerySnapshot, Error) in
                if Error != nil {
                    print(Error!)
                } else {
                    self.entryDateToShow = String(QuerySnapshot!.documentID.suffix(8))
                    let data = QuerySnapshot!.data()
                    if data != nil {
                        self.entryListDataToShow = (data!["data"] as! [[String: Any]])
                        self.entryListIndToShow = self.iodKeysList[indexPath!.row]["journalEntryInd"] as! Int
                        self.performSegue(withIdentifier: "viewerToJournalEntry", sender: self)
                    }
                }
            })
        }
    }
    
    @objc func showProfile(sender: UIGestureRecognizer) {
        let indexPath = entriesCollectionView.indexPathForItem(at: sender.location(in: entriesCollectionView))
        if indexPath != nil {
            let entryListKey = iodKeysList[indexPath!.row]["journalEntryListKey"] as! String
            profileKeyToShow = String(entryListKey.prefix(entryListKey.count - 8))
            performSegue(withIdentifier: "viewerToProfile", sender: self)
        }
    }
    
    @objc func unfeatureImage(sender: UIGestureRecognizer) {
        let indexPath = entriesCollectionView.indexPathForItem(at: sender.location(in: entriesCollectionView))
        if indexPath == nil {return}
        let alertController = UIAlertController(title: "Warning", message: "Really unfeature this entry?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "yes", style: .destructive, handler: {(alertAction) in deleteIodData(ind: indexPath!.row)})
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
        func deleteIodData(ind: Int) {
            let featuredDate = iodKeysList[ind]["featuredDate"] as! String
            let entryListKey = iodKeysList[ind]["journalEntryListKey"] as! String
            let entryInd = iodKeysList[ind]["journalEntryInd"] as! Int
            let userKey = String(entryListKey.prefix(entryListKey.count - 8))
            db.collection("userData").document(userKey).getDocument(completion: {(snapshot, Error) in
                if Error != nil {
                    print(Error!, "getting user data to undo feature")
                } else {
                    let userData = snapshot!.data()!
                    let userDataCopyKey = (userData["userDataCopyKeys"] as! [String: String])[featuredDate]!
                    db.collection("userData").document(userDataCopyKey).delete()
                    var featuredAlertDates = userData["featuredAlertDates"] as! [String]
                    if featuredAlertDates.index(of: featuredDate) != nil {
                        featuredAlertDates.remove(at: featuredAlertDates.index(of: featuredDate)!)
                    }
                    db.collection("userData").document(userKey).setData(["featuredAlertDates": featuredAlertDates, "userDataCopyKeys": [featuredDate: FieldValue.delete()]], merge: true)
                }
            })
            db.collection("journalEntries").document(entryListKey).getDocument(completion: {(snapshot, Error) in
                if Error != nil {
                    print(Error!, "getting journal entry to undo feature")
                } else {
                    var entryListData = snapshot!.data()!["data"] as! [[String: Any]]
                    entryListData[entryInd]["featuredDate"] = ""
                    db.collection("journalEntries").document(entryListKey).setData(["data": entryListData], merge: true)
                }
            })
            db.collection("imageOfDayKeys").document(featuredDate).setData([:], merge: false)
            db.collection("imageOfDayLikes").document(featuredDate).delete()
            db.collection("imageOfDayComments").document(featuredDate).delete()
            iodKeysList.remove(at: ind)
            entryImageDataList.remove(at: ind)
            entriesCollectionView.deleteItems(at: [IndexPath(row: ind, section: 0)])
        }
    }
    
    func addButton(cell: ImageOfDayViewerCollectionViewCell, xPos: Int, yPos: Int, str: String, f: Selector) {
        let buttonLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: 120, height: 20))
        buttonLabel.text = str
        buttonLabel.textColor = UIColor.white
        buttonLabel.font = UIFont(name: "Helvetica Neue", size: 13)
        buttonLabel.layer.borderWidth = 1
        buttonLabel.layer.borderColor = UIColor.orange.cgColor
        buttonLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: f))
        buttonLabel.isUserInteractionEnabled = true
        cell.entryImageView.addSubview(buttonLabel)
        cell.entryImageView.layer.borderWidth = 2
        cell.entryImageView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iodKeysList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageOfDayViewerCollectionViewCell
        cell.featuredDate.text = (iodKeysList[indexPath.row]["featuredDate"] as! String)
        cell.entryImageView.image = entryImageDataList[indexPath.row]
        var hasButtons = false
        print(cell.subviews)
        for view in cell.subviews {
            if view is UILabel {
                hasButtons = true
                break
            }
        }
        if !hasButtons {
            addButton(cell: cell, xPos: 10, yPos: Int(cell.bounds.height) - 110, str: " Show Entry", f: #selector(showEntry))
            addButton(cell: cell, xPos: 10, yPos: Int(cell.bounds.height) - 80, str: " Show Profile", f: #selector(showProfile))
            addButton(cell: cell, xPos: 10, yPos: Int(cell.bounds.height) - 50, str: " Unfeature image", f: #selector(unfeatureImage))
        }
        return cell
    }
    
}
