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
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var winnerNameLabel: UILabel!
    @IBOutlet weak var seeWinningEntryButton: UIButton!
    @IBOutlet weak var timerDay1: UILabel!
    @IBOutlet weak var timerDay2: UILabel!
    @IBOutlet weak var timerHr1: UILabel!
    @IBOutlet weak var timerHr2: UILabel!
    @IBOutlet weak var timerMin1: UILabel!
    @IBOutlet weak var timerMin2: UILabel!
    @IBOutlet weak var timerColon1: UILabel!
    @IBOutlet weak var timerColon2: UILabel!
    @IBOutlet weak var challengeTargetImageView: UIImageView!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var entriesTableView: UITableView!
    @IBOutlet weak var trophyWC: NSLayoutConstraint!
    @IBOutlet weak var trophyTopC: NSLayoutConstraint!
    @IBOutlet weak var textViewWC: NSLayoutConstraint!
    @IBOutlet weak var OPTLeadingC: NSLayoutConstraint!
    var challengeData: [String: Any]? = nil
    var formattedChallengeTarget = ""
    var basicEntryDataList: [[String: String]] = []
    var entryImageList: [Int: UIImage] = [:]
    var entryListToShowData: [[String: Any]]? = nil
    var entryToShowInd = 0
    var entryToShowDate = ""
    var curMonth = 0
    var userNameBackground = UIColor(patternImage: UIImage(named: "Calendar/light")!)
    var loadImageTimer: Timer = Timer.scheduledTimer(withTimeInterval: 0, repeats: false) {_ in}
    let maxNumImages = 40
    override func viewDidLoad() {
        super.viewDidLoad()
        if screenH < 600 {
            banner.isHidden = true
            trophyWC.constant = 30
            trophyTopC.constant = -50
            textViewWC.constant = 320
            OPTLeadingC.constant = -290
            
        } else if screenH > 1000 {
            border.image = UIImage(named: "border-ipad")
        }
        challengeTargetImageView.layer.borderColor = astroOrange
        challengeTargetImageView.layer.borderWidth = 1
        targetLabel.backgroundColor = UIColor(patternImage: UIImage(named: "Calendar/light")!)
        winnerNameLabel.isHidden = true
        targetLabel.isHidden = true
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
                self.winnerNameLabel.text = (self.challengeData!["lastMonthWinnerName"] as! String)
                self.targetLabel.text = (self.challengeData!["target"] as! String)
                self.targetLabel.backgroundColor = self.userNameBackground
                self.winnerNameLabel.isHidden = false
                self.targetLabel.isHidden = false
                self.formattedChallengeTarget = formatTarget(self.challengeData!["target"] as! String)
                db.collection("journalEntries").whereField("formattedTargets", arrayContains: self.formattedChallengeTarget).getDocuments(completion: {(snapshot, Error) in
                    if Error != nil {
                        print(Error!)
                        return
                    }
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
                    for i in 0..<5 {
                        if i == self.basicEntryDataList.count {
                            break
                        }
                        storage.child(self.basicEntryDataList[i]["imageKey"]!).getData(maxSize: imgMaxByte) {data, Error in
                            if let Error = Error {
                                print(Error)
                                return
                            } else {
                                let img = UIImage(data: data!)!
                                let cell = self.entriesTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? MonthlyChallengeEntryCell
                                if cell != nil {
                                    cell!.targetImageView!.image = img
                                }
                                self.entryImageList[i] = img
                            }
                        }
                    }
                })
            }
        })
        func displayTimer() {
            let timeNow = Date()
            let timeNowDateComps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: timeNow)
            //first run of this function
            if curMonth == 0 {
                curMonth = timeNowDateComps.month!
            //month changed
            } else {
                if curMonth != timeNowDateComps.month! {
                    navigationController?.popToRootViewController(animated: true)
                    return
                }
            }
            var nextMonthDateComps = DateComponents()
            nextMonthDateComps.timeZone = TimeZone(abbreviation: "PDT")
            if timeNowDateComps.month! != 12 {
                nextMonthDateComps.year = timeNowDateComps.year!
                nextMonthDateComps.month = timeNowDateComps.month! + 1
            } else {
                nextMonthDateComps.year = timeNowDateComps.year! + 1
                nextMonthDateComps.month = 1
            }
            nextMonthDateComps.day = 1
            nextMonthDateComps.hour = 0
            nextMonthDateComps.minute = 1
            let nextMonthTime = Calendar.current.date(from: nextMonthDateComps)!
            let difference = Calendar.current.dateComponents([.day, .hour, .minute], from: timeNow, to: nextMonthTime)
            let timeLeftList = Array(String(format: "%02ld%02ld%02ld", difference.day!, difference.hour!, difference.minute!))
            let timerLabelList = [timerDay1, timerDay2, timerHr1, timerHr2, timerMin1, timerMin2]
            for i in 0..<timerLabelList.count {
                timerLabelList[i]!.text = String(timeLeftList[i])
            }
        }
        displayTimer()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) {_ in
            displayTimer()
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            UIView.animate(withDuration: 0.5, animations: {
                self.timerColon1.alpha = 0
                self.timerColon2.alpha = 0
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.timerColon1.alpha = 1
                    self.timerColon2.alpha = 1
                }, completion: nil)
            })
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basicEntryDataList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MonthlyChallengeEntryCell
        cell.targetImageView.image = entryImageList[indexPath.row]
        cell.usernameLabel.text = basicEntryDataList[indexPath.row]["userName"]
        cell.usernameLabel.backgroundColor = userNameBackground
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return challengeTargetImageView.bounds.height - 10
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadImageTimer.invalidate()
        loadImageTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {_ in
            var indAdded = 0
            for case let cell as MonthlyChallengeEntryCell in self.entriesTableView.visibleCells {
                let ind = self.entriesTableView.indexPath(for: cell)!.row
                if self.entryImageList[ind] == nil {
                    storage.child(self.basicEntryDataList[ind]["imageKey"]!).getData(maxSize: imgMaxByte) {data, Error in
                        if let Error = Error {
                            print(Error)
                            return
                        } else {
                            let img = UIImage(data: data!)
                            cell.targetImageView.image = img
                            self.entryImageList[ind] = img
                            indAdded = ind
                        }
                    }
                }
            }
            //check if too many images saved
            let listLen = self.entryImageList.count
            if listLen > self.maxNumImages {
                let indListSorted = Array(self.entryImageList.keys).sorted()
                var startInd = 0
                if indListSorted.index(of: indAdded)! > listLen / 2 {
                    startInd = listLen - 5
                }
                for i in 0..<5 {
                    if i + startInd == listLen {
                        break
                    }
                    self.entryImageList[indListSorted[i + startInd]] = nil
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JournalEntryViewController
        if vc != nil {
            vc!.entryDate = entryToShowDate
            vc!.entryList = entryListToShowData!
            vc!.selectedEntryInd = entryToShowInd
            vc!.segueFromMonthlyChallenge = true
            return
        }
        let vc2 = segue.destination as? ProfileViewController
        if vc2 != nil {
            let winnerEntryKey = challengeData!["lastMonthJournalEntryListKey"] as! String
            vc2!.keyForDifferentProfile = String(winnerEntryKey.prefix(winnerEntryKey.count - 8))
            return
        }
    }
    @IBAction func winnerLabelTapped(_ sender: Any) {
        performSegue(withIdentifier: "monthlyChallengeToProfile", sender: self)
    }
    func manageMoveToEntry(key: String, data: [String: Any]?, targetToLookFor: String) {
        if data != nil {
            let entryListData = data!["data"] as! [[String: Any]]
            for i in 0..<entryListData.endIndex {
                if entryListData[i]["formattedTarget"] as! String == targetToLookFor && entryListData[i]["mainImageKey"] as! String != "" {
                    self.entryListToShowData = (data!["data"] as! [[String : Any]])
                    self.entryToShowInd = i
                    self.entryToShowDate = String(key.suffix(8))
                    self.performSegue(withIdentifier: "MonthlyChallengeToEntry", sender: self)
                    self.seeWinningEntryButton.isUserInteractionEnabled = true
                    self.entriesTableView.isUserInteractionEnabled = true
                    return
                }
            }
        }
        let alertController = UIAlertController(title: "Entry deleted", message: "User has deleted that entry.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
            self.seeWinningEntryButton.isUserInteractionEnabled = true
            self.entriesTableView.isUserInteractionEnabled = true
        })
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func seeWinningEntryButtonTapped(_ sender: Any) {
        seeWinningEntryButton.isUserInteractionEnabled = false
        let key = challengeData!["lastMonthJournalEntryListKey"] as! String
        db.collection("journalEntries").document(key).getDocument(completion: {(snapshot, Error) in
            if Error != nil {
                print(Error!)
            } else {
                self.manageMoveToEntry(key: key, data: snapshot!.data(), targetToLookFor: formatTarget(self.challengeData!["lastMonthTarget"] as! String))
            }
        })
    }
    @IBAction func tableViewEntryTapped(_ sender: Any) {
        let indexPath = entriesTableView.indexPathForRow(at: (sender as AnyObject).location(in: entriesTableView))
        if indexPath == nil {return}
        entriesTableView.isUserInteractionEnabled = false
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

