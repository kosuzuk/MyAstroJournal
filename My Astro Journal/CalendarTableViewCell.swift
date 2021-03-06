//
//  calendarTableViewCell.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 5/27/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import Foundation
import SwiftKeychainWrapper
import DropDown

class CalendarTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var calendarMonthYear: UILabel!
    @IBOutlet weak var calendarView: UICollectionView!
    @IBOutlet weak var sunLabel: UILabel!
    @IBOutlet weak var sunLabelLeadingC: NSLayoutConstraint!
    @IBOutlet weak var monLabelLeadingC: NSLayoutConstraint!
    @IBOutlet weak var tuesLabelLeadingC: NSLayoutConstraint!
    @IBOutlet weak var wedLabelLeadingC: NSLayoutConstraint!
    @IBOutlet weak var thursLabelLeadingC: NSLayoutConstraint!
    @IBOutlet weak var friLabelLeadingC: NSLayoutConstraint!
    @IBOutlet weak var satLabelLeadingC: NSLayoutConstraint!
    var calendarMonthString = ""
    var calendarYearString = ""
    var sunLabelW = CGFloat(0)
    var firstDayOffset = 0
    var numDays = 0
    var userKey = ""
    var curRow = -1 {
        didSet {
            if curRow != -1 {
                let calendar = Calendar.current
                let date = Date()
                let dateForCalendar = calendar.date(byAdding: .month,
                                                    value: -curRow,
                                                    to: date)!
                let dateForCalendarComps = calendar.dateComponents([.timeZone, .year, .month, .day, .weekday], from: dateForCalendar)
                //the number of days of offset from the first sunday so the 1st day of the month will line up to correct day of the week (sunday is 1, saturday is 7).
                calendarMonthString = String(dateForCalendarComps.month!)
                if calendarMonthString.count == 1 {
                    calendarMonthString = "0" + calendarMonthString
                }
                calendarYearString = String(dateForCalendarComps.year!)
                firstDayOffset = ((dateForCalendarComps.weekday! - dateForCalendarComps.day! + 1) % 7 + 6) % 7
                let range = calendar.range(of: .day, in: .month, for: dateForCalendar)!
                numDays = range.count
                let monthName = monthNames[dateForCalendarComps.month! - 1]
                calendarMonthYear.text = monthName + " " + calendarYearString
                calendarMonthYear.textColor = .lightGray
            }
        }
    }
    let dateFormatter = DateFormatter()
    var availableMoonPhases = [0, 3, 5, 7]
    var todayCellDateTextColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
    var newEntryGreenColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 0.3)
    var newEntryRedColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.3)
    var cvc: CalendarViewController? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(calendarTapped))
        calendarView.addGestureRecognizer(tap)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        calendarView.collectionViewLayout = layout
        let font = UIFont(name: sunLabel.font.fontName, size: sunLabel.font.pointSize)
        let fontAttributes = [NSAttributedString.Key.font: font]
        sunLabelW = (sunLabel.text! as NSString).size(withAttributes: fontAttributes as [NSAttributedString.Key : Any]).width
        userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if indexPath.row == 0 {
            let cellW = floor(calendarView.bounds.width / 7)
            sunLabelLeadingC.constant = cellW / 2 - sunLabelW / 2
            for c in [monLabelLeadingC, tuesLabelLeadingC, wedLabelLeadingC, thursLabelLeadingC, friLabelLeadingC] {
                c!.constant = cellW - sunLabelW
            }
            satLabelLeadingC.constant = cellW - sunLabelW + 7
        }
        return CGSize(width: floor(calendarView.bounds.width / 7), height: floor(calendarView.bounds.height / 6))
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //reset moon phases
        availableMoonPhases = [0, 3, 5, 7]
        if numDays + firstDayOffset < 36 {
            return 35
        } else {
            return 42
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        if curRow == -1 {
            return cell
        }
        let i = indexPath.row
        if ((i > 6 && i < 28) || (i <= 6 && i + 1 > firstDayOffset) || (i >= 28 && i < numDays + firstDayOffset)) {
            var cellDate = String(i - firstDayOffset + 1)
            if curRow == 0 && cellDate == String(Int(dateToday.prefix(4).suffix(2))!) {
                cell.layer.borderWidth = 1
                cell.layer.borderColor = todayCellDateTextColor.cgColor
                cell.cellLabel.textColor = todayCellDateTextColor
            } else {
                cell.layer.borderWidth = 0.5
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.cellLabel.textColor = .gray
            }
            cell.cellLabel.text = cellDate
            if cellDate.count == 1 {
                cellDate = "0" + cellDate
            }
            let date = dateFormatter.date(from: calendarYearString + "-" + calendarMonthString + "-" + cellDate)
            let moonPhase = suncalc.getMoonIllumination(date: date!)["phase"]!
            if (moonPhase < 0.03 || abs(moonPhase - 1) < 0.03) && availableMoonPhases.contains(0) {
                cell.moonPhaseImageView.image = UIImage(named: "Calendar/MoonPhases/0")
                availableMoonPhases.remove(at: availableMoonPhases.index(of: 0)!)
            } else if abs(moonPhase - 0.25) < 0.03 && availableMoonPhases.contains(3) {
                cell.moonPhaseImageView.image = UIImage(named: "Calendar/MoonPhases/3")
                availableMoonPhases.remove(at: availableMoonPhases.index(of: 3)!)
            } else if abs(moonPhase - 0.5) < 0.03 && availableMoonPhases.contains(5) {
               cell.moonPhaseImageView.image = UIImage(named: "Calendar/MoonPhases/5")
                availableMoonPhases.remove(at: availableMoonPhases.index(of: 5)!)
            } else if abs(moonPhase - 0.75) < 0.03 && availableMoonPhases.contains(7) {
               cell.moonPhaseImageView.image = UIImage(named: "Calendar/MoonPhases/7")
                availableMoonPhases.remove(at: availableMoonPhases.index(of: 7)!)
            } else {
                cell.moonPhaseImageView.image = nil
            }
            let dateString = calendarMonthString + cellDate + calendarYearString
            let numEntries = cvc!.numEntriesDict[dateString]
            if numEntries != nil && numEntries! > 1 {
                cell.numEntries.text = "x" + String(numEntries!)
            } else {
                cell.numEntries.text = ""
            }
            if let image = cvc!.imageDict[dateString] {
                cell.entryDate = dateString
                cell.imageView.image = image
            } else {
                cell.entryDate = ""
                cell.imageView.image = nil
            }
            if cvc?.newEntryMode ?? false {
                if curRow == 0 && Int(cellDate)! > Int(dateToday.prefix(4).suffix(2))! {
                    cell.newEntryColorView.backgroundColor = newEntryGreenColor
                } else {
                    cell.newEntryColorView.backgroundColor = newEntryRedColor
                }
            } else {
                cell.newEntryColorView.backgroundColor = .clear
            }
        } else {
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.cellLabel.text = ""
            cell.moonPhaseImageView.image = nil
            cell.numEntries.text = ""
            cell.entryDate = ""
            cell.imageView.image = nil
            cell.newEntryColorView.backgroundColor = .clear
        }
        return cell
    }
    func moveToEntryEdit(_ data: [String: Any]?) {
        var entryList: [[String: Any]]
        var formattedTargetsList: [String]
        if data == nil {
            entryList = []
            formattedTargetsList = []
        } else {
            entryList = data!["data"] as! [[String: Any]]
            formattedTargetsList = data!["formattedTargets"] as! [String]
        }
        self.cvc?.selectedEntryList = entryList
        self.cvc?.formattedTargetsList = formattedTargetsList
        self.cvc?.performSegue(withIdentifier: "calendarToEdit", sender: self)
        self.calendarView.isUserInteractionEnabled = true
    }
    @objc func calendarTapped(sender: UIGestureRecognizer) {
        let touch = sender.location(in: calendarView)
        let indexPath = calendarView.indexPathForItem(at: touch)
        if indexPath == nil {
            return
        }
        let cell = calendarView.cellForItem(at: indexPath!) as! CalendarCell
        if cvc!.newEntryMode && cell.cellLabel.text != "" {
            var cellDate = String(indexPath!.row - firstDayOffset + 1)
            if cellDate.count == 1 {
                cellDate = "0" + cellDate
            }
            if curRow == 0 {
                let isFuture = Int(cellDate)! > Int(dateToday.prefix(4).suffix(2))!
                if isFuture {
                    return
                }
            }
            cvc?.newEntryDate = calendarMonthString + cellDate + calendarYearString
            cvc?.newEntryIndexPathRow = curRow
            if cell.imageView.image == nil {
                moveToEntryEdit(nil)
                return
            }
            calendarView.isUserInteractionEnabled = false
            cvc!.view.addSubview(formatLoadingIcon(loadingIcon))
            loadingIcon.startAnimating()
            let docRef = db.collection("journalEntries").document(userKey + cell.entryDate)
            docRef.getDocument(completion: {(QuerySnapshot, Error) in
                if Error != nil {
                    //offline and entry not in cache
                    self.cvc?.preventOfflineOverwrite = true
                    self.cvc?.newEntryDate = ""
                    self.cvc?.newEntryIndexPathRow = 0
                } else {
                    self.moveToEntryEdit(QuerySnapshot!.data())
                }
                loadingIcon.stopAnimating()
                self.calendarView.isUserInteractionEnabled = true
            })
        } else if !cvc!.newEntryMode && cell.entryDate != "" && cell.imageView.image != nil {
            calendarView.isUserInteractionEnabled = false
            cvc!.view.addSubview(formatLoadingIcon(loadingIcon))
            loadingIcon.startAnimating()
            let docRef = db.collection("journalEntries").document(userKey + cell.entryDate)
            docRef.getDocument(completion: {(QuerySnapshot, Error) in
                if Error != nil {
                    //offline and entry not in cache
                    self.cvc?.cannotPullEntry = true
                    self.calendarView.isUserInteractionEnabled = true
                    return
                }
                let entryList = QuerySnapshot!.data()!["data"] as! [Dictionary<String, Any>]
                self.cvc?.selectedEntryList = entryList
                self.cvc?.formattedTargetsList = QuerySnapshot!.data()!["formattedTargets"] as! [String]
                self.cvc?.entryToShowDate = cell.entryDate
                if entryList.count > 1 {
                    let dd = DropDown()
                    self.cvc!.entryDropDown = dd
                    dd.backgroundColor = .darkGray
                    dd.textColor = .white
                    dd.textFont = UIFont(name: "Pacifica Condensed", size: 14)!
                    dd.cellHeight = 34
                    dd.cornerRadius = 10
                    dd.cornerRadius = 10
                    dd.anchorView = cell
                    let cellH = floor(self.calendarView.bounds.height / 6)
                    dd.bottomOffset = CGPoint(x: 1, y: cellH)
                    dd.dataSource = []
                    for entry in entryList {
                        dd.dataSource.append((entry["target"] as! String).uppercased())
                    }
                    dd.selectionAction = {(index: Int, item: String) in
                        self.cvc?.selectedEntryInd = dd.dataSource.firstIndex(of: dd.selectedItem!)!
                        self.cvc?.performSegue(withIdentifier: "calendarToEntry", sender: self)
                    }
                    dd.show()
                } else {
                    self.cvc?.selectedEntryInd = 0
                    self.cvc?.performSegue(withIdentifier: "calendarToEntry", sender: self)
                }
                loadingIcon.stopAnimating()
                self.calendarView.isUserInteractionEnabled = true
            })
        }
    }
}
