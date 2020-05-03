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
    @IBOutlet weak var weekdays: UILabel!
    @IBOutlet weak var calendarView: UICollectionView!
    var calendarMonthString = ""
    var calendarYearString = ""
    var firstDayOffset = 0
    var numDays = 0
    var cvc: CalendarViewController? = nil
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
    let userKey = KeychainWrapper.standard.string(forKey: "dbKey")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let weekdayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let numSpaces = Int((screenW - (50000 / screenW)) / 45)
        var spaces = ""
        for _ in 0...numSpaces - 1 {
            spaces += " "
        }
        var weekdaysText = ""
        for weekday in weekdayNames {
            weekdaysText += weekday + spaces
        }
        weekdays.text = weekdaysText
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(calendarTapped))
        calendarView.addGestureRecognizer(tap)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        calendarView.collectionViewLayout = layout
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
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
            let docRef = db.collection("journalEntries").document(userKey + cell.entryDate)
            docRef.getDocument(completion: {(QuerySnapshot, Error) in
                if Error != nil {
                    print(Error!)
                } else {
                    let data = QuerySnapshot!.data()
                    var entryList: [[String: Any]]
                    if data == nil {
                        entryList = []
                    } else {
                        entryList = data!["data"] as! [[String: Any]]
                    }
                    self.cvc?.selectedEntryList = entryList
                    self.cvc?.performSegue(withIdentifier: "calendarToEdit", sender: self)
                    return
                }
            })
        } else if cell.entryDate != "" {
            let docRef = db.collection("journalEntries").document(userKey + cell.entryDate)
            docRef.getDocument(completion: {(QuerySnapshot, Error) in
                if Error != nil {
                    print(Error!)
                } else {
                    let entryList = QuerySnapshot!.data()!["data"] as! [Dictionary<String, Any>]
                    self.cvc?.entryToShowDate = cell.entryDate
                    self.cvc?.selectedEntryList = entryList
                    if entryList.count > 1 {
                        let dd = DropDown()
                        self.cvc!.entryDropDown = dd
                        dd.backgroundColor = .darkGray
                        dd.textColor = .white
                        dd.textFont = UIFont(name: "Pacifica Condensed", size: 14)!
                        dd.separatorColor = .white
                        dd.cellHeight = 34
                        dd.cornerRadius = 10
                        dd.cornerRadius = 10
                        dd.anchorView = cell
                        dd.bottomOffset = CGPoint(x: 1, y: 41)
                        dd.dataSource = []
                        for entry in entryList {
                            dd.dataSource.append((entry["target"] as! String).uppercased())
                        }
                        dd.selectionAction = {(index: Int, item: String) in
                            self.cvc?.selectedEntryInd = dd.dataSource.firstIndex(of: dd.selectedItem!)!
                            self.cvc?.performSegue(withIdentifier: "calendarToEntry", sender: self)
                        }
                        dd.show()
                        return
                    } else {
                        self.cvc?.selectedEntryInd = 0
                        self.cvc?.performSegue(withIdentifier: "calendarToEntry", sender: self)
                        return
                    }
                }
            })
        }
    }
}
