//
//  DateView.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/5/23.
//

import Foundation
import JTAppleCalendar
import UIKit

class CalendarDateView: JTAppleCell {
    static let cellID = "CalendarDateView"
    let dataDateFormat = "yyyy.MM.dd"
    let vm = MainVM()
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var stickerImage: UIImageView!
    
    func configure(state: CellState) {
        dateLabel.text = state.text
        handleInOutDates(cellState: state)
        handleDateColor(cellState: state)
        handleEvents(cellState: state)
    }
    
    //handle date belongs to this month or not
    private func handleInOutDates(cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            self.isHidden = false
        } else {
            self.isHidden = true
        }
    }
    
    private func handleDateColor(cellState: CellState) {
        if cellState.day == .sunday {
            dateLabel.textColor = UIColor(named: "red")
        } else {
            dateLabel.textColor = UIColor(named: "black")
        }
        dateLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)

        if cellState.date > Date() {
            dateLabel.textColor = .gray
            dateLabel.font = UIFont.systemFont(ofSize: 10)
        }
    }
    
    private func handleEvents(cellState: CellState) {
        let dateString = cellState.date.toString(format: dataDateFormat)
        if vm.calendarData[dateString] == nil {
            stickerImage.isHidden = true
            dateLabel.isHidden = false
        } else {
            if !(vm.calendarData[dateString]?.sticker.isEmpty)! {
                stickerImage.image = UIImage(named: (vm.calendarData[dateString]?.sticker.first)!)
                stickerImage.isHidden = false
            } else {
                stickerImage.isHidden = false
            }
        }
    }
    
}
