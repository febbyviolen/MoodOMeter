//
//  ViewController.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/5/23.
//

import UIKit
import JTAppleCalendar
import Combine
import CombineCocoa

class MainVC: UIViewController {
    
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var lastMonthButton: UIButton!
    @IBOutlet weak var addButton: UIButton?
    @IBOutlet weak var calendar: JTAppleCalendarView!
    
    private var cancellables = Set<AnyCancellable>()
    private let currentDateSubject = CurrentValueSubject<Date, Never>(Date())
    private var VM = MainVM.Shared
    
    var addTodayButtonPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        VM.checkIsPasscodeActivated()
        VM.setupUser()
        VM.setNotification()
        
        VM.checkInterruptedReceipt()
        
        currentDateSubject.send(VM.selectedDate?.date ?? Date())
        calendarSetup()
        bind()
        observe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("MainVC - viewWillAppear called")
        currentDateSubject.send(VM.selectedDate?.date ?? Date())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWriteDiaryVC" {
            if let VC = segue.destination as? WriteDiaryVC {
                VC.writtenDataSubject.send((MainVM.Shared.selectedDate?.data, MainVM.Shared.selectedDate!.date))
                VC.addTodayButtonPressed = addTodayButtonPressed
                addTodayButtonPressed = false
            }
        }
    }
    
    private func bind() {
        MainVM.Shared.$calendarData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                print("calendar data \(data)")
                self?.calendar.reloadData()
            }
            .store(in: &cancellables)
        
        MainVM.Shared.$appIsLocked
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] bool in
                if bool {
                    performSegue(withIdentifier: "showPasswordPadVC", sender: self)
                }
            }
            .store(in: &cancellables)
        
    }
    
    private func observe() {
        currentDateSubject.sink { [unowned self] date in
            if let newDate = isMaybeFirstLineOfCalendar(date: date) {
                calendar.scrollToDate(newDate , animateScroll: true)
            } else {
                calendar.scrollToDate(Date(), animateScroll: true)
            }
            
            //month
            let month = date.toString(format: "MMMM").uppercased()
            monthLabel.text = month
            
            //year
            let year = date.toString(format: "yyyy")
            if year != MainVM.Shared.currentYear {
                MainVM.Shared.currentYear = year
//                if !MainVM.Shared.inTheData.contains(year){
                    MainVM.Shared.fetchCalendarData(for: date)
//                }
            }
            yearLabel.text = year
            
            //today button
            if date.toString(format:"yyyy.MMMM") != Date().toString(format: "yyyy.MMMM") {
                todayButton.alpha = 1
            } else {
                todayButton.alpha = 0
            }
        }
        .store(in: &cancellables)
    }
    
    //=== BUTTON ===
    @IBAction func addButtonTapped(_ sender: Any) {
        MainVM.Shared.selectedDate = (Date(), nil)
        MainVM.Shared.selectedDate?.data = MainVM.Shared.calendarData[Date().toString(format: "yyyy.MM.dd")]
        
        print("addButtonTapped with data = ")
        print(MainVM.Shared.selectedDate?.data)
        
        addTodayButtonPressed = true
        performSegue(withIdentifier: "showWriteDiaryVC", sender: self)
    }
    
    @IBAction 
    func todayButtonTapped(_ sender: Any) {
        currentDateSubject.send(Date())
    }
    
    @IBAction
    func lastMonthTapped(_ sender: Any) {
        currentDateSubject.send(currentDateSubject.value.decreaseMonth(by: 1) ?? Date())
    }
    
    @IBAction func nextMonthTapped(_ sender: Any) {
        currentDateSubject.send(currentDateSubject.value.addMonth(by: 1) ?? Date())
    }

}

//MARK: CALENDAR'S FUNCTIONS
extension MainVC {
    
    // REASON: library error! if the date is in the first line, the calendar showing last month
    func isMaybeFirstLineOfCalendar(date: Date) -> Date? {
        let dateStr = date.toString(format: "dd")
        if dateStr == "01" || dateStr == "02" || dateStr == "03" || dateStr == "04" || dateStr == "05" || dateStr == "06" {
            let month = date.toString(format: "MM")
            let year = date.toString(format: "yyyy")
            return ("\(String(describing: year)).\(String(describing: month)).\(15)").toDate(format: "yyyy.MM.dd")
        }
        else {return nil}
    }
}

//MARK: JTAPPLECALENDAR
extension MainVC: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    //MARK: CALENDAR SETUP
    private func calendarSetup() {
        calendar.ibCalendarDelegate = self
        calendar.ibCalendarDataSource = self
        
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.scrollDirection = .horizontal
        calendar.showsHorizontalScrollIndicator = false
        
        calendar.addCornerRadius(radius: 16)
        
        //DATE LABEL
        yearLabel.text = Date().toString(format: "yyyy")
        monthLabel.text = Date().toString(format: "MMMM")
        
        if let newDate = isMaybeFirstLineOfCalendar(date: Date()) {
            calendar.scrollToDate(newDate , animateScroll: false)
        } else {
            calendar.scrollToDate(Date(), animateScroll: false)
        }
        
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = "yyyy MM dd"
        let startDate = ("2010 01 01").toDate(format: formatter) ?? Date()
        let endDate = ("2050 01 01").toDate(format: formatter) ?? Date()
        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarDateView.cellID, for: indexPath) as! CalendarDateView
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? CalendarDateView  else { return }
        cell.configure(state: cellState)
        
    }

    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        MainVM.Shared.selectedDate = (Date(), nil)
        MainVM.Shared.selectedDate?.0 = cellState.date
        MainVM.Shared.selectedDate?.1 = MainVM.Shared.calendarData[cellState.date.toString(format: "yyyy.MM.dd")]
        performSegue(withIdentifier: "showWriteDiaryVC", sender: self)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        if cellState.date > Date() {
            return false
        } else {
            return true
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if let date = visibleDates.monthDates.first?.date {
            currentDateSubject.send(date)
        }
    }
}


