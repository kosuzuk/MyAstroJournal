//
//  MonthlyChallengePicker.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 5/14/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit
import DropDown

class MonthlyChallengePicker: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var seeChallengesButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var targetField: UITextField!
    @IBOutlet weak var monthYearField: UITextField!
    var challengesData: [[String: String]] = []
    var challengesDD: DropDown? = nil
    var newImageKey = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        db.collection("monthlyChallenge").getDocuments(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                var lst = self.challengesData
                var DDList: [String] = []
                for doc in snapshot!.documents {
                    let data = doc.data()
                    let listItem = ["docID": doc.documentID, "imageKey": data["imageKey"] as! String, "target": data["target"] as! String]
                    if lst.isEmpty {
                        lst = [listItem]
                        DDList = [monthNames[Int(listItem["docID"]!.prefix(2))! - 1]]
                    } else {
                        for i in 0..<lst.count {
                            if isEarlierMonth(lst[i]["docID"]!, doc.documentID) {
                                lst.insert(listItem, at: i)
                                DDList.insert(monthNames[Int(listItem["docID"]!.prefix(2))! - 1], at: i)
                                break
                            } else if i == lst.endIndex - 1 {
                                lst.insert(listItem, at: i + 1)
                                DDList.insert(monthNames[Int(listItem["docID"]!.prefix(2))! - 1], at: i)
                            }
                        }
                    }
                }
                self.challengesDD = DropDown()
                self.challengesDD!.backgroundColor = .darkGray
                self.challengesDD!.textColor = .white
                self.challengesDD!.textFont = UIFont(name: "Pacifica Condensed", size: 14)!
                self.challengesDD!.separatorColor = .white
                self.challengesDD!.cellHeight = 34
                self.challengesDD!.cornerRadius = 10
                self.challengesDD!.anchorView = self.seeChallengesButton
                self.challengesDD!.bottomOffset = CGPoint(x: 0, y: 25)
                self.challengesDD!.dataSource = DDList
                self.challengesDD!.selectionAction = {(index: Int, item: String) in
                    storage.child(lst[index]["imageKey"]!).getData(maxSize: imgMaxByte) {data, Error in
                        if let Error = Error {
                            print(Error)
                            return
                        } else {
                            self.imageView.image = UIImage(data: data!)
                        }
                    }
                    self.targetField.text = lst[index]["target"]!
                    self.monthYearField.text = lst[index]["docID"]!
                }
                loadingIcon.stopAnimating()
                endNoInput()
            }
        })
    }
    func seeChallengesTapped(_ sender: Any) {
        challengesDD!.show()
    }
    func imageViewTapped() {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        present(image, animated: true) {
            //after completion
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: true, completion: {
                self.imageView.image = newImage
                self.newImageKey = NSUUID().uuidString
            }
        )}
    }
    func setButtonTapped() {
        db.collection("monthlyChallenge").document(monthYearField.text!).setData(["imageKey": newImageKey, "target": formatTarget(targetField.text!)], merge: true)
    }
}
