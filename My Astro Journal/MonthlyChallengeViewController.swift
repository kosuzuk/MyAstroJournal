//
//  MonthlyChallengeViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 5/13/20.
//  Copyright © 2020 Koso Suzuki. All rights reserved.
//

import UIKit

class MonthlyChallengeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var winnerNameLabel: UILabel!
    @IBOutlet weak var timerDay1: UILabel!
    @IBOutlet weak var timerDay2: UILabel!
    @IBOutlet weak var timerHr1: UILabel!
    @IBOutlet weak var timerHr2: UILabel!
    @IBOutlet weak var timerMin1: UILabel!
    @IBOutlet weak var timerMin2: UILabel!
    @IBOutlet weak var challengeTargetImageView: UIImageView!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var entriesTableView: UITableView!
    @IBOutlet weak var trophyWC: NSLayoutConstraint!
    @IBOutlet weak var trophyTopC: NSLayoutConstraint!
    @IBOutlet weak var textViewWC: NSLayoutConstraint!
    @IBOutlet weak var OPTLeadingC: NSLayoutConstraint!
    var challengeData: [String: Any]? = nil
    var formattedChallengeTarget = ""
    var entryListToShowData: [[String: Any]]? = nil
    var entryToShowInd = 0
    var entryToShowDate = ""
    var basicEntryDataList: [[String: String]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH < 600 {
            banner.isHidden = true
            trophyWC.constant = 30
            trophyTopC.constant = -50
            textViewWC.constant = 320
            OPTLeadingC.constant = -290
            
        }
        challengeTargetImageView.layer.borderColor = astroOrange
        challengeTargetImageView.layer.borderWidth = 1
        targetLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Calendar/light")!)
        db.collection("monthlyChallenges").document(String(dateToday.prefix(2) + dateToday.suffix(4))).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                if snapshot!.data() == nil {return}
                self.challengeData = snapshot!.data()
                storage.child(self.challengeData!["imageKey"] as! String).getData(maxSize: imgMaxByte) {data, Error in
                    if let Error = Error {
                        print(Error)
                        return
                    } else {
                        self.challengeTargetImageView.image = UIImage(data: data!)
                    }
                }
                self.targetLabel.text = (self.challengeData!["target"] as! String)
                self.winnerNameLabel.text = (self.challengeData!["lastMonthWinnerName"] as! String)
                
                self.formattedChallengeTarget = formatTarget(self.challengeData!["target"] as! String)
                db.collection("journalEntries").whereField("formattedTargets", arrayContains: self.formattedChallengeTarget).getDocuments(completion: {(snapshot, Error) in
                    if Error != nil {
                        print(Error!)
                    } else {
                        for doc in snapshot!.documents {
                            let entryListData = (doc.data()["data"] as! [[String: Any]])
                            for i in 0..<entryListData.endIndex {
                                if entryListData[i]["formattedTarget"] as! String == self.formattedChallengeTarget && entryListData[i]["mainImageKey"] as! String != "" {
                                    let listItem = ["key": doc.documentID, "imageKey": entryListData[i]["mainImageKey"] as! String, "userName": doc.data()["userName"] as! String]
                                    self.basicEntryDataList.append(listItem)
                                    break
                                }
                            }
                        }
                        //sort from most recent to oldest entries
                        self.basicEntryDataList.sort(by: ¬)
                        self.entriesTableView.reloadData()
                        endNoInput()
                    }
                })
            }
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basicEntryDataList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MonthlyChallengeEntryCell
        cell.usernameLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Calendar/light")!)
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JournalEntryViewController
        if vc != nil {
            vc!.entryDate = entryToShowDate
            vc!.entryList = entryListToShowData!
            vc!.selectedEntryInd = entryToShowInd
            vc!.editButton.isHidden = true
            vc!.featuredButton.isUserInteractionEnabled = false
            vc!.memoriesLabel.isHidden = true
            vc!.memoriesField.isHidden = true
            vc!.contentViewHC.constant -= 177
            vc!.contentViewHCipad.constant -= 444
            return
        }
    }
    func manageMoveToEntry(key: String, data: [String: Any]?, targetToLookFor: String) {
        if data != nil {
            let entryListData = data!["data"] as! [[String: Any]]
            for i in 0..<entryListData.endIndex - 1 {
                if entryListData[i]["formattedTarget"] as! String == self.formattedChallengeTarget && entryListData[i]["mainImageKey"] as! String != "" {
                    self.entryListToShowData = (data!["data"] as! [[String : Any]])
                    self.entryToShowInd = i
                    self.entryToShowDate = String(key.suffix(8))
                    self.performSegue(withIdentifier: "MonthlyChallengeToEntry", sender: self)
                    return
                }
            }
        }
        let alertController = UIAlertController(title: "Entry deleted", message: "User has deleted that entry.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func seeWinningEntryButtonTapped(_ sender: Any) {
        let key = challengeData!["lastMonthJournalEntryListKey"] as! String
        db.collection("journalEntries").document(key).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                self.manageMoveToEntry(key: key, data: snapshot!.data(), targetToLookFor: self.challengeData!["lastMonthTarget"] as! String)
            }
        })
    }
    @IBAction func tableViewEntryTapped(_ sender: Any) {
        let indexPath = entriesTableView.indexPathForRow(at: (sender as AnyObject).location(in: entriesTableView))
        if indexPath == nil {return}
        let key = self.basicEntryDataList[indexPath!.row]["key"]!
        db.collection("journalEntries").document(key).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                self.manageMoveToEntry(key: key, data: snapshot!.data(), targetToLookFor: self.formattedChallengeTarget)
            }
        })
    }
}

