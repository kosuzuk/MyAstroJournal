//
//  MonthlyChallengePicker.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 5/14/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit
import DropDown

class MonthlyChallengePicker: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var seeChallengesButton: UIButton!
    @IBOutlet weak var seeEntriesButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var targetToDisplayField: UITextField!
    @IBOutlet weak var formattedTargetField: UITextField!
    @IBOutlet weak var monthYearField: UITextField!
    var challengesData: [[String: String]] = []
    var challengesDD: DropDown? = nil
    var imageKey = ""
    var imageData: Data? = nil
    var activeField: UITextField? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = astroOrange
        targetToDisplayField.delegate = (self as UITextFieldDelegate)
        formattedTargetField.delegate = (self as UITextFieldDelegate)
        monthYearField.delegate = (self as UITextFieldDelegate)
        formattedTargetField.autocorrectionType = .no
        monthYearField.autocorrectionType = .no
        db.collection("monthlyChallenges").getDocuments(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                var lst: [[String: String]] = []
                var DDList: [String] = []
                for doc in snapshot!.documents {
                    let data = doc.data()
                    if data["imageKey"] == nil || data["target"] == nil {
                        continue
                    }
                    var listItem = data as! [String: String]
                    listItem["docID"] = doc.documentID
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
                                DDList.insert(monthNames[Int(listItem["docID"]!.prefix(2))! - 1], at: i + 1)
                            }
                        }
                    }
                }
                self.challengesData = lst
                self.challengesDD = DropDown()
                self.challengesDD!.backgroundColor = .darkGray
                self.challengesDD!.textColor = .white
                self.challengesDD!.textFont = UIFont(name: "Pacifica Condensed", size: 14)!
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
                            self.imageKey = lst[index]["imageKey"]!
                            self.imageView.image = UIImage(data: data!)
                            self.imageData = data
                        }
                    }
                    print(lst, index)
                    self.targetToDisplayField.text = lst[index]["target"]!
                    self.formattedTargetField.text = lst[index]["formattedTarget"]!
                    self.monthYearField.text = lst[index]["docID"]!
                }
                loadingIcon.stopAnimating()
                endNoInput()
            }
        })
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func seeChallengesTapped(_ sender: Any) {
        activeField?.resignFirstResponder()
        challengesDD!.show()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? MonthlyChallengeViewController
        if vc != nil {
            vc!.challengeMonthToShow = monthYearField.text!
            return
        }
    }
    @IBAction func seeEntriesTapped(_ sender: Any) {
        performSegue(withIdentifier: "monthlyPickerToChallenge", sender: self)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: true, completion: {
                let processRes = processImage(inpImg: newImage)
                if processRes == nil {
                    let alertController = UIAlertController(title: "Error", message: imageTooBigMessage, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.imageKey = NSUUID().uuidString
                    self.imageView.image = (processRes![0] as! UIImage)
                    self.imageData = (processRes![1] as! Data)
                }
            }
        )}
    }
    @IBAction func imageViewTapped() {
        activeField?.resignFirstResponder()
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        present(image, animated: true) {
            //after completion
        }
    }
    @IBAction func removeImageTapped(_ sender: Any) {
        activeField?.resignFirstResponder()
        imageView.image = nil
    }
    @IBAction func setButtonTapped() {
        if imageView.image == nil || targetToDisplayField.text! == "" || formattedTargetField.text! == "" || monthYearField .text! == "" {
            let alertController = UIAlertController(title: "Error", message: "Please fill out all of the text fields.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let formattedTarget = formatTarget(formattedTargetField.text!)
        var isCardTarget = false
        for lst in [MessierTargets, NGCTargets, ICTargets, SharplessTargets, OthersTargets, PlanetTargets] {
            if lst.contains(formattedTarget) {
                isCardTarget = true
            }
        }
        if !isCardTarget {
            let alertController = UIAlertController(title: "Error", message: "Not a valid target (or there's no card associated with it)", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        db.collection("monthlyChallenges").document(monthYearField.text!).setData(["imageKey": imageKey, "target": targetToDisplayField.text!, "formattedTarget": formattedTarget], merge: true)
        storage.child(imageKey).putData(imageData!, metadata: nil) {(metadata, error) in
            if error != nil {
                print(error as Any)
                return
            } else {
                self.navigationController!.popToRootViewController(animated: true)
            }
        }
        var nextMonth = ""
        if monthYearField.text!.prefix(2) == "12" {
            nextMonth = "01" + String(Int(monthYearField.text!.suffix(4))! + 1)
        } else {
            nextMonth = String(Int(monthYearField.text!.prefix(2))! + 1) + monthYearField.text!.suffix(4)
            if nextMonth.count == 5 {
                nextMonth = "0" + nextMonth
            }
        }
        db.collection("monthlyChallenges").document(nextMonth).setData(["lastMonthFormattedTarget": formattedTarget], merge: true)
    }
}
