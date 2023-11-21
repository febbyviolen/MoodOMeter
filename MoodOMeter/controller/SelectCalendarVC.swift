//
//  SelectCalendarViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/27.
//

import UIKit
import Combine
import CombineCocoa

class SelectCalendarVC: UIViewController {

    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var decLabel: UILabel!
    @IBOutlet weak var novLabel: UILabel!
    @IBOutlet weak var octLabel: UILabel!
    @IBOutlet weak var septLabel: UILabel!
    @IBOutlet weak var augLabel: UILabel!
    @IBOutlet weak var julyLabel: UILabel!
    @IBOutlet weak var juneLabel: UILabel!
    @IBOutlet weak var mayLabel: UILabel!
    @IBOutlet weak var aprLabel: UILabel!
    @IBOutlet weak var marLabel: UILabel!
    @IBOutlet weak var febLabel: UILabel!
    @IBOutlet weak var janLabel: UILabel!
    @IBOutlet weak var calendarBackgroundView: UIView!
    @IBOutlet var backgroundView: UIView!
    
    private var VM = MainVM.Shared
    private var cancellables = Set<AnyCancellable>()
    private let currentDateSubject = CurrentValueSubject<Date, Never>(Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupAction()
        bind()
    }
    
    private func bind() {
        currentDateSubject.sink { [unowned self] date in
            yearLabel.text = date.toString(format: "yyyy")
        }
        .store(in: &cancellables)
    }
    
    @IBAction func rightButton(_ sender: Any) {
        currentDateSubject.send(currentDateSubject.value.addYear(by: 1) ?? Date())
    }
    
    @IBAction func leftButton(_ sender: Any) {
        currentDateSubject.send(currentDateSubject.value.decreaseYear(by: 1) ?? Date())
    }

}

extension SelectCalendarVC {
    private func setupUI(){
        calendarBackgroundView.layer.cornerRadius = 10
        
        [janLabel, febLabel, marLabel, aprLabel, mayLabel, juneLabel, julyLabel, augLabel, septLabel, octLabel, novLabel, decLabel].forEach {
            $0?.addShadow(offset: CGSize(width: 0, height: 0),
                          color: UIColor(named: "black")!,
                          radius: 1,
                          opacity: 0.2)
            $0?.addCornerRadius(radius: 10)
            $0?.backgroundColor = UIColor(named: "whiteDefault")
            
        }
    }
    
    private func setupAction() {
        janLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate1)))
        febLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate2)))
        marLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate3)))
        aprLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate4)))
        mayLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate5)))
        juneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate6)))
        julyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate7)))
        augLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate8)))
        septLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate9)))
        octLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate10)))
        novLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate11)))
        decLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate12)))
    }
    
    private func changeSelectedDate(to date: String) {
        let date = date.toDate(format: "yyyy.MM.dd")!
        print("change selectedDate ",date)
        VM.selectedDate = (date, nil)
    }
    
    @objc private func selectDate1() {
        let date = yearLabel.text! + ".01.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate2() {
        let date = yearLabel.text! + ".02.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate3() {
        let date = yearLabel.text! + ".03.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate4() {
        let date = yearLabel.text! + ".04.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate5() {
        let date = yearLabel.text! + ".05.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate6() {
        let date = yearLabel.text! + ".06.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate7() {
        let date = yearLabel.text! + ".07.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate8() {
        let date = yearLabel.text! + ".08.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate9() {
        let date = yearLabel.text! + ".09.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate10() {
        let date = yearLabel.text! + ".10.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate11() {
        let date = yearLabel.text! + ".11.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
    
    @objc private func selectDate12() {
        let date = yearLabel.text! + ".12.15"
        changeSelectedDate(to: date)
        dismiss(animated: true)
    }
}
