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
    @IBOutlet weak var trophyTopC: NSLayoutConstraint!
    @IBOutlet weak var textViewWC: NSLayoutConstraint!
    @IBOutlet weak var OPTLeadingC: NSLayoutConstraint!
    var challengeData: [String: Any]? = nil
    var formattedChallengeTarget = ""
    var winningEntryData: [[String: Any]]? = nil
    var entriesList: [[String: String]]? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH < 600 {
            banner.isHidden = true
            trophyTopC.constant = -64
            textViewWC.constant = 320
            OPTLeadingC.constant = -290
        }
        challengeTargetImageView.layer.borderColor = UIColor.orange.cgColor
        challengeTargetImageView.layer.borderWidth = 1
        targetLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Calendar/light")!)
        db.collection("monthlyChallenge").document(String(dateToday.prefix(2) + dateToday.suffix(4))).getDocument(completion: {(snapshot, Error) in
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
                                    let listItem = ["key": doc.documentID, "imageKey": entryListData[i]["imageKey"], "userName": doc.data()["userName"]]
                                    self.entriesList!.append(listItem as! [String : String])
                                    break
                                }
                            }
                        }
                        //sort from most recent to oldest entries
                        self.entriesList!.sort(by: ¬)
                    }
                })
            }
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entriesList!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MonthlyChallengeEntryCell
        cell.usernameLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Calendar/light")!)
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JournalEntryViewController
        if vc != nil {
            vc!.entryDate = String((challengeData!["lastMonthJournalEntryListKey"] as! String).suffix(8))
            vc!.entryList = winningEntryData!
            vc!.selectedEntryInd = 0
            vc!.editButton.isHidden = true
            vc!.featuredButton.isUserInteractionEnabled = false
            vc!.memoriesLabel.isHidden = true
            vc!.memoriesField.isHidden = true
            vc!.contentViewHC.constant -= 177
            vc!.contentViewHCipad.constant -= 444
            return
        }
    }
    @IBAction func seeButtonTapped(_ sender: Any) {
        db.collection("journalEntries").document(challengeData!["lastMonthJournalEntryListKey"] as! String).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                if snapshot!.data() == nil {
                    return
                } else {
                    self.winningEntryData = (snapshot!.data()!["data"] as! [[String : Any]])
                    self.performSegue(withIdentifier: "MonthlyChallengeToEntry", sender: self)
                }
            }
        })
    }
}

