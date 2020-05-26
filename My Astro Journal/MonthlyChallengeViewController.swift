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
    @IBOutlet weak var trophyLogo: UIImageView!
    @IBOutlet weak var congratsToLabel: UILabel!
    @IBOutlet weak var forWinningLabel: UILabel!
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
    @IBOutlet weak var bannerHCipad: NSLayoutConstraint!
    @IBOutlet weak var trophyWC: NSLayoutConstraint!
    @IBOutlet weak var trophyTopC: NSLayoutConstraint!
    @IBOutlet weak var targetImageViewLeadingCipad: NSLayoutConstraint!
    @IBOutlet weak var targetLabelWC: NSLayoutConstraint!
    @IBOutlet weak var textViewWC: NSLayoutConstraint!
    @IBOutlet weak var OPTLeadingC: NSLayoutConstraint!
    var challengeData: [String: Any]? = nil
    var formattedChallengeTarget = ""
    var basicEntryDataList: [[String: String]] = []
    var entryImageList: [Int: UIImage] = [:]
    var entryToShowKey = ""
    var entryListToShowData: [[String: Any]]? = nil
    var entryToShowInd = 0
    var entryToShowUserName = ""
    var profileToShowKey = ""
    var curMonth = 0
    var loadImageTimer: Timer = Timer.scheduledTimer(withTimeInterval: 0, repeats: false) {_ in}
    let maxNumImages = 60
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
            if screenH > 1120 {//ipad 11, 12.9
                bannerHCipad.constant = 75
                if screenH == 1366 {//ipad 12.9
                    targetImageViewLeadingCipad.constant = 100
                }
            }
        }
        challengeTargetImageView.layer.borderColor = astroOrange
        challengeTargetImageView.layer.borderWidth = 1
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
                if (self.challengeData!["lastMonthWinnerName"] as? String ?? "") == "" {
                    self.trophyLogo.alpha = 0.6
                    self.congratsToLabel.alpha = 0.6
                    self.forWinningLabel.alpha = 0.6
                    self.seeWinningEntryButton.alpha = 0.6
                    self.winnerNameLabel.isUserInteractionEnabled = false
                    self.seeWinningEntryButton.isUserInteractionEnabled = false
                } else {
                    self.winnerNameLabel.text = (self.challengeData!["lastMonthWinnerName"] as! String)
                }
                self.targetLabel.text = (self.challengeData!["target"] as! String)
                let font = UIFont(name: self.targetLabel.font.fontName, size: self.targetLabel.font.pointSize)
                let fontAttributes = [NSAttributedString.Key.font: font]
                let size = (self.targetLabel.text! as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
                self.targetLabelWC.constant = size.width + 4
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
                    for i in 0..<10 {
                        if i == self.basicEntryDataList.count {
                            break
                        }
                        let cell = self.entriesTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? MonthlyChallengeEntryCell
                        self.entryImageList[i] = UIImage(named: "placeholer")
                        if cell != nil {
                            let loadingIcon = UIActivityIndicatorView()
                            cell!.backgroundView = formatLoadingIcon(loadingIcon)
                            loadingIcon.startAnimating()
                        }
                        storage.child(self.basicEntryDataList[i]["imageKey"]!).getData(maxSize: imgMaxByte) {data, Error in
                            if let Error = Error {
                                print(Error)
                                return
                            } else {
                                let img = UIImage(data: data!)!
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
        cell.targetImageView.layer.borderWidth = 1
        cell.targetImageView.layer.borderColor = astroOrange
        cell.targetImageView.image = entryImageList[indexPath.row]
        cell.usernameLabel.text = basicEntryDataList[indexPath.row]["userName"]
        let font = UIFont(name: cell.usernameLabel.font.fontName, size: cell.usernameLabel.font.pointSize)
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (cell.usernameLabel.text! as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
        cell.usernameLabelWC.constant = size.width + 6
        cell.usernameLabel.layer.zPosition = 3
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return challengeTargetImageView.bounds.height * 0.9
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadImageTimer.invalidate()
        loadImageTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) {_ in
            var resultingNumImages = self.entryImageList.count
            var rowAdded = 0
            var imageIndeces = Array(self.entryImageList.keys)
            for i in 0..<self.entriesTableView.visibleCells.count {
                let cell = self.entriesTableView.visibleCells[i] as! MonthlyChallengeEntryCell
                let row = self.entriesTableView.indexPath(for: cell)!.row
                if self.entryImageList[row] == nil {
                    resultingNumImages += 1
                    rowAdded = row
                    imageIndeces.append(row)
                    self.entryImageList[row] = UIImage(named: "placeholer")
                    let loadingIcon = UIActivityIndicatorView()
                    cell.backgroundView = formatLoadingIcon(loadingIcon)
                    loadingIcon.startAnimating()
                    storage.child(self.basicEntryDataList[row]["imageKey"]!).getData(maxSize: imgMaxByte) {data, Error in
                        if let Error = Error {
                            print(Error)
                            return
                        } else {
                            let img = UIImage(data: data!)
                            cell.targetImageView.image = img
                            cell.backgroundView = nil
                            self.entryImageList[row] = img
                            loadingIcon.stopAnimating()
                        }
                    }
                }
            }
            imageIndeces.sort()
            //check if too many images saved
            let numImagesToRemove = resultingNumImages - self.maxNumImages
            if numImagesToRemove > 0 {
                var startInd = 0
                //remove image near bottom of table view
                if imageIndeces.index(of: rowAdded)! < resultingNumImages / 2 {
                    startInd = resultingNumImages - numImagesToRemove
                }
                for i in startInd..<startInd + numImagesToRemove {
                    self.entryImageList[imageIndeces[i]] = nil
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? JournalEntryViewController
        if vc != nil {
            vc!.entryDate = String(entryToShowKey.suffix(8))
            vc!.entryList = entryListToShowData!
            vc!.selectedEntryInd = entryToShowInd
            vc!.segueFromMonthlyChallenge = true
            vc!.keyForDifferentProfile = String(entryToShowKey.prefix(entryToShowKey.count - 8))
            vc!.entryUserName = entryToShowUserName
            return
        }
        let vc2 = segue.destination as? ProfileViewController
        if vc2 != nil {
            vc2!.keyForDifferentProfile = profileToShowKey
            return
        }
    }
    @IBAction func winnerLabelTapped(_ sender: Any) {
        let winningEntryKey = (challengeData!["lastMonthJournalEntryListKey"] as! String)
        profileToShowKey = String(winningEntryKey.prefix(winningEntryKey.count - 8))
        performSegue(withIdentifier: "monthlyChallengeToProfile", sender: self)
    }
    func manageMoveToEntry(key: String, data: [String: Any]?, targetToLookFor: String) {
        if data != nil {
            let entryListData = data!["data"] as! [[String: Any]]
            for i in 0..<entryListData.endIndex {
                if entryListData[i]["formattedTarget"] as! String == targetToLookFor && entryListData[i]["mainImageKey"] as! String != "" {
                    self.entryToShowKey = key
                    self.entryListToShowData = (data!["data"] as! [[String : Any]])
                    self.entryToShowInd = i
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
                self.entryToShowUserName = self.winnerNameLabel.text!
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
                self.entryToShowUserName = self.basicEntryDataList[indexPath!.row]["userName"]!
                self.manageMoveToEntry(key: key, data: snapshot!.data(), targetToLookFor: self.formattedChallengeTarget)
            }
        })
    }
}

