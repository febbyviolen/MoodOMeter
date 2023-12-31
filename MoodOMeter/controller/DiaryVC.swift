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
    @IBOutlet var noData: UIView?
    
    let VM = DiaryVM()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        bind()
        observe()
        setupTableView()
        setupUI()
    }
    
    private func bind() {
        VM.$thisMonthData
            .receive(on: DispatchQueue.main)
            .sink { data in
                print("dairyVC - thisMonthData bind")
                self.noData?.isHidden = data.count == 0 ? false : true
                self.tableView?.isHidden = data.count == 0 ? true : false
                self.tableView?.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func observe() {
        VM.currentDateSubject.sink { [unowned self] date in
            print("dairyVC - currentdatesubject observe")
            dateLabel?.text = date.toString(format: "yyyy.MM")
            
            //year
            let year = date.toString(format: "yyyy")
            if year != MainVM.Shared.currentYear {
                MainVM.Shared.currentYear = year
                //                if !MainVM.Shared.inTheData.contains(year){
                MainVM.Shared.fetchCalendarData(for: date)
                //                }
            }
            VM.getThisMonthData(date: date.toString(format: "yyyy.MM"))
            
        }
        .store(in: &cancellables)
    }
    
    @IBAction func lastMonthTapped(_ sender: Any) {
        VM.currentDateSubject.send(VM.currentDateSubject.value.decreaseMonth(by: 1) ?? Date())
    }
    
    @IBAction func nextMonthTapped(_ sender: Any) {
        VM.currentDateSubject.send(VM.currentDateSubject.value.addMonth(by: 1) ?? Date())
    }
    
    private func setupUI() {
        noData?.addShadow(
            offset: CGSize(width: 0, height: 0),
            color: UIColor(named: "black")!,
            radius: 1,
            opacity: 0.2)
        noData?.addCornerRadius(radius: 16)
        if !MainVM.Shared.checkSubscription() {
            GoogleMobsFactory.build(at: self)
        }
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
        MainVM.Shared.selectedDate = (Date(), nil)
               MainVM.Shared.selectedDate?.date = VM.thisMonthData[indexPath.row].date.toDate(format: "yyyy.MM.dd")!
               MainVM.Shared.selectedDate?.data = VM.thisMonthData[indexPath.row]
               performSegue(withIdentifier: "showWriteDiaryVC", sender: self)
    }
    
}
