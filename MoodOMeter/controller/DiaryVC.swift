//
//  DiaryVC.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/6/23.
//

import UIKit
import Combine
import CombineCocoa

class DiaryVC: UIViewController {
    
    @IBOutlet var tableView: UITableView?
    @IBOutlet var dateLabel: UILabel?
    
    let VM = DiaryVM()
    private var cancellables = Set<AnyCancellable>()
    let currentDateSubject = CurrentValueSubject<Date, Never>(Date())
    
    override func viewDidLoad() {
        bind()
        observe()
        setupTableView()
    }
    
    private func bind() {
        VM.$thisMonthData
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print("dairyVC - this month data bind")
                self.tableView?.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func observe() {
        currentDateSubject.sink { [unowned self] date in
            print("dairyVC - currentdatesubject observe")
            dateLabel?.text = date.toString(format: "yyyy.MM")
            
            //year
            let year = date.toString(format: "yyyy")
            if year < VM.currentYear {
                VM.currentYear = year
                if !MainVM.Shared.inTheData.contains(year){
                    MainVM.Shared.fetchCalendarData(for: date)
                }
            }
            VM.getThisMonthData(date: date.toString(format: "yyyy.MM"))
           
        }
        .store(in: &cancellables)
    }
    
    @IBAction func lastMonthTapped(_ sender: Any) {
        currentDateSubject.send(currentDateSubject.value.decreaseMonth(by: 1) ?? Date())
    }
    
    @IBAction func nextMonthTapped(_ sender: Any) {
        currentDateSubject.send(currentDateSubject.value.addMonth(by: 1) ?? Date())
    }
}

extension DiaryVC: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(UINib(nibName: "DiaryViewCell", bundle: nil), forCellReuseIdentifier: DiaryViewCell.cellID)
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VM.thisMonthData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryViewCell.cellID, for: indexPath) as! DiaryViewCell
        cell.configure(data: VM.thisMonthData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }
    
}
