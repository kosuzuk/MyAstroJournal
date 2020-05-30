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
        cell.backgroundColor = .black
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.lightGray.cgColor
        let i = indexPath.row
        if ((i > 6 && i < 28) || (i <= 6 && i + 1 > firstDayOffset) || (i >= 28 && i < numDays + firstDayOffset)) {
            var cellDate = String(i - firstDayOffset + 1)
            cell.cellLabel.text = cellDate
            if cellDate.count == 1 {
                cellDate = "0" + cellDate
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
        } else {
            cell.cellLabel.text = ""
            cell.numEntries.text = ""
            cell.entryDate = ""
            cell.imageView.image = nil
        }
        return cell
    }
    @objc func calendarTapped(sender: UIGestureRecognizer) {
        let touch = sender.location(in: calendarView)
        let indexPath = calendarView.indexPathForItem(at: touch)
        if indexPath == nil {
            return
        }
        let cell = calendarView.cellForItem(at: indexPath!) as! CalendarCell
        let userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
        if cvc!.newEntryMode && cell.cellLabel.text != "" {
            calendarView.isUserInteractionEnabled = false
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
            let docRef = db.collection("journalEntries").document(userKey + cell.entryDate)
            docRef.getDocument(completion: {(QuerySnapshot, Error) in
                var data: [String: Any]?
                if Error == nil {
                    data = QuerySnapshot!.data()
                } else {
                    data = nil
                    if cell.imageView.image != nil {
                        self.cvc?.preventOfflineOverwrite = true
                        self.calendarView.isUserInteractionEnabled = true
                        return
                    }
                }
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
                return
            })
        } else if cell.entryDate != "" {
            calendarView.isUserInteractionEnabled = false
            let docRef = db.collection("journalEntries").document(userKey + cell.entryDate)
            docRef.getDocument(completion: {(QuerySnapshot, Error) in
                if Error != nil {
                    print(Error!)
                    self.calendarView.isUserInteractionEnabled = true
                } else {
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
                        self.calendarView.isUserInteractionEnabled = true
                        return
                    } else {
                        self.cvc?.selectedEntryInd = 0
                        self.cvc?.performSegue(withIdentifier: "calendarToEntry", sender: self)
                        self.calendarView.isUserInteractionEnabled = true
                        return
                    }
                }
            })
        }
    }
}
