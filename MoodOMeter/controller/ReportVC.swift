//
//  reportVC.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/7/23.
//
/*
 todo :
 
 */

import UIKit
import Combine
import CombineCocoa

class ReportVC: UIViewController {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var chartContainerView: UIView!
    
    @IBOutlet weak var firstChartView: UIView!
    @IBOutlet var secondChartView: UIView!
    @IBOutlet var thirdChartView: UIView!
    @IBOutlet var fourthChartView: UIView!
    @IBOutlet var fifthChartView: UIView!
    
    @IBOutlet weak var firstChartHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondChartheightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdChartheightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fifthChartHeightContraintt: NSLayoutConstraint!
    @IBOutlet weak var fourthChartheightConstraint: NSLayoutConstraint!
    
    @IBOutlet var firstChartImage: UIImageView!
    @IBOutlet var secondChartImage: UIImageView!
    @IBOutlet var thirdChartImage: UIImageView!
    @IBOutlet var fourthChartImage: UIImageView!
    @IBOutlet var fifthChartImage: UIImageView!
    
    @IBOutlet var firstMoodRankImage: UIImageView!
    @IBOutlet var secondMoodRankImage: UIImageView!
    @IBOutlet var thirdMoodRankImage: UIImageView!
    @IBOutlet var fourthMoodRankImage: UIImageView!
    @IBOutlet var fifthMoodRankImage: UIImageView!
    
    @IBOutlet var firstMoodRankLabel: UILabel!
    @IBOutlet var secondMoodRankLabel: UILabel!
    @IBOutlet var thirdMoodRankLabel: UILabel!
    @IBOutlet var fourthMoodRankLabel: UILabel!
    @IBOutlet var fifthMoodRankLabel: UILabel!
    
    @IBOutlet var firstMoodRankView: UIView!
    @IBOutlet var secondMoodRankView: UIView!
    @IBOutlet var thirdMoodRankView: UIView!
    @IBOutlet var fourthMoodRankView: UIView!
    @IBOutlet var fifthMoodRankView: UIView!
    
    @IBOutlet weak var noDataView: UIView!
    
    private var VM = ReportVM()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        setupUI()
        observe()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationChart()
    }
    
    private func bind() {
        VM.$thisMonthMoodData
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                //can't hide all cs xcode screaming
                print("ReportVC - thisMonthMoodData bind")
                setupChart(data)
            }
            .store(in: &cancellables)
    }
    
    private func observe() {
        VM.currentDateSubject.sink { [unowned self] date in
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
//            animationChart()
            
        }
        .store(in: &cancellables)
        
    }
    
    @IBAction func lastMonthTapped(_ sender: Any) {
        VM.currentDateSubject.send(VM.currentDateSubject.value.decreaseMonth(by: 1) ?? Date())
    }
    
    @IBAction func nextMonthTapped(_ sender: Any) {
        VM.currentDateSubject.send(VM.currentDateSubject.value.addMonth(by: 1) ?? Date())
    }
    
    private func setupChart(_ data: [(String, Int)]) {
        let chart = [firstChartImage, secondChartImage, thirdChartImage, fourthChartImage, fifthChartImage]
        let table = [firstMoodRankImage, secondMoodRankImage, thirdMoodRankImage, fourthMoodRankImage, fifthMoodRankImage]
        let label = [firstMoodRankLabel, secondMoodRankLabel, thirdMoodRankLabel, fourthMoodRankLabel, fifthMoodRankLabel]
        let view = [firstMoodRankView, secondMoodRankView, thirdMoodRankView, fourthMoodRankView, fifthMoodRankView]
        let chartView = [firstChartView, secondChartView, thirdChartView, fourthChartView, fifthChartView]
        
        if data.count == 0 {
            showNoData()
        } else {
            showThereIsData()
            chart.forEach({$0?.isHidden = true})
            view.forEach {$0?.isHidden = true}
            chartView.forEach{$0?.isHidden = true}
        }
        
        for i in data.enumerated() {
            if i.offset == 5 {break}
            else {
                chart[i.offset]?.image = UIImage(named: i.element.0)
                chart[i.offset]?.isHidden = false
                
                table[i.offset]?.image = UIImage(named: i.element.0)
                
                view[i.offset]?.isHidden = false
                label[i.offset]?.text = "\(i.element.1)"
                
                chartView[i.offset]?.isHidden = false
            }
        }
    }
    
    private func showNoData() {
        noDataView.isHidden = false
        chartContainerView.isHidden = true
    }
        
    private func showThereIsData() {
        noDataView.isHidden = true
        chartContainerView.isHidden = false
    }
    
    private func setupUI() {
        [chartContainerView, noDataView].forEach({
            $0.addShadow(
                offset: CGSize(width: 0, height: 0),
                color: UIColor(named: "black")!,
                radius: 1,
                opacity: 0.2)
            $0.addCornerRadius(radius: 16)
        })
        if !MainVM.Shared.checkSubscription() {
            GoogleMobsFactory.build(at: self)
        }
    }
}

//MARK: ANIMATION
extension ReportVC {
    private func animationChart() {
        UIView.animate(withDuration: 1.0) {
            self.firstChartHeightConstraint.constant = 100
            self.secondChartheightConstraint.constant = 85
            self.thirdChartheightConstraint.constant = 70
            self.fifthChartHeightContraintt.constant = 55
            self.fourthChartheightConstraint.constant = 40
            self.view.layoutIfNeeded()
        }
    }
}
