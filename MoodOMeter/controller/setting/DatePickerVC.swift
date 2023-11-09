//
//  DatePickerViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/27.
//

import UIKit

class DatePickerVC: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var VM: SettingVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var time = VM.getAlarmSettedTime().toDate(format: "HH:mm")
        datePicker.date = time!
        setupUI()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func save(_ sender: Any) {
        var hour = Int(datePicker.date.toString(format: "HH")) ?? 0
        var minute = Int(datePicker.date.toString(format: "mm")) ?? 0
        VM.alarmTimeChanged = (hour, minute)
        self.dismiss(animated: false)
    }
    
    @objc private func dismissView(){
        self.dismiss(animated: false)
    }

    private func setupUI() {
        background.layer.cornerRadius = 10
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
    }
}
