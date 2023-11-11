//
//  WriteDiaryVC.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/7/23.
//

/*
 todo:
 - write to firebase -> VM
 - delete on firebase -> VM
 - plus button
 - back button check changes 
 */

import UIKit
import Combine
import CombineCocoa
import KTCenterFlowLayout

class WriteDiaryVC: UIViewController {
    
    @IBOutlet weak var diaryTextField: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addStickerButton: UIButton!
    
    private var VM = WriteDiaryVM()
    
    private var cancellables = Set<AnyCancellable>()
    var writtenDataSubject = PassthroughSubject<(data: DiaryModel?, date: Date), Never>()
    var addTodayButtonPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if addTodayButtonPressed {
            self.performSegue(withIdentifier: "showStickerVC", sender: self);
            addTodayButtonPressed = false
        }
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        bind()
        observe()
        setupCollectionView()
        keyboardToolBar()
        
        diaryTextField.delegate = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStickerVC" {
            if let VC = segue.destination as? StickerVC {
                VC.writeDiaryVM = VM
            }
        }
    }
    
    @objc func backButtonTapped() {
        print("WriteDiaryVC - asking if they want to save the diary ")
        VM.addNewStoryToData(diaryTextField.text, date: MainVM.Shared.selectedDate!.date.toString(format: "yyyy.MM.dd"))
        if VM.newDiary != MainVM.Shared.selectedDate?.data {
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.VM.saveToFirebase{
                    self.navigationController?.popViewController(animated: true)
                }
            }
            let alert = UIAlertFactory.buildYesNoAlert(
                title: "변경 사항 저장하시겠습니까?".localised,
                message: "",
                okAction: okAction,
                noAction: UIAlertAction(
                    title: "취소".localised,
                    style: .default) {_ in
                        self.navigationController?.popViewController(animated: true)})
            
            present(alert, animated: true)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func bind() {
        VM.$newDiary
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                print("WriteDiaryVC - newDiary bind called: \(data)")
                addStickerButton.isHidden = false
                collectionView.isHidden = false
                
                if data?.sticker.count == 0 || data == nil{
                    collectionView.isHidden = true
                } else if data?.sticker.count == 5 {
                    addStickerButton.isHidden = true
                } else {
                    collectionView.isHidden = false
                }
                
                collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        MainVM.Shared.$selectedDate
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                VM.newDiary = data?.data
                setupInitData(date: data!.date,
                              story: data?.data?.story)
            }
            .store(in: &cancellables)
        
    }
    
    private func observe() {
        diaryTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                self.checkDiaryTextUI(text)
            }
            .store(in: &cancellables)
        
        VM.$newAddedSticker
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] sticker in
                VM.addNewStickerToData(sticker,
                                       date: MainVM.Shared.selectedDate!.date.toString(format: "yyyy.MM.dd"))
            }
            .store(in: &cancellables)
    }
    
    //=== BUTTON ===
    @IBAction func addStickerButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showStickerVC", sender: self)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        //if there is no new item
        if VM.newDiary?.sticker.count == 0 || VM.newDiary == nil {
            if VM.newDiary?.story == "" || VM.newDiary?.story == "오늘은 어떤 하루였나요?".localised {
                Firebase.Shared.deleteDiary(date: MainVM.Shared.selectedDate!.date)
            }
        } else { //save to firebase
            VM.saveToFirebase{
                let alert = UIAlertFactory.buildOneAlert(title: "저장 완료했습니다".localised, message: "", okAction: UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    

    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        //delete on firebase
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            Firebase.Shared.deleteDiary(date: MainVM.Shared.selectedDate!.date)
            MainVM.Shared.selectedDate = (Date(), nil)
            self.navigationController?.popViewController(animated: true)
        }
        let alert = UIAlertFactory.buildYesNoAlert(
            title: "다이어리 삭제하시겠습니까?".localised,
            message: "삭제된 다이어리는 뒤찾을 수 없어요!".localised,
            okAction: okAction,
            noAction: UIAlertAction(title: "취소".localised, style: .default))
        present(alert, animated: true)
    }
    
    //=== UI ===
    private func  setupInitData(date: Date, story: String?) {
        dateLabel.text = date.toString(format: "yyyy.MM.dd EEEE")
        diaryTextField.text = story == "" || story == nil ? "오늘은 어떤 하루였나요?".localised : story
    }
    
    private func checkDiaryTextUI(_ text: String?) {
        if text == "오늘은 어떤 하루였나요?".localised {
            diaryTextField.textColor = .lightGray
        }
        else {
            diaryTextField.textColor = UIColor(named: "black")
        }
    }
    
    //=== TOOLBAR ===
    private func keyboardToolBar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        
        let addTimeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "clock"), style: .plain, target: self, action: #selector(addTimeStamp))
        addTimeButton.tintColor = UIColor(named: "black2")
        
        let doneButton = UIBarButtonItem(title: "완료".localised, style: .done, target: self, action: #selector(didTapDone))
        doneButton.tintColor = UIColor(named: "black2")
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbar.items = [addTimeButton, flexibleSpace, doneButton]
        toolbar.sizeToFit()
        diaryTextField.inputAccessoryView = toolbar
    }
    
    //=== BAR ITEM FUNC ===
    @objc 
    private func didTapDone(){
        diaryTextField.resignFirstResponder()
    }
    
    @objc
    private func addTimeStamp(){
        DateFormatter().timeStyle = .short
        diaryTextField.text += Date().toString(format: "hh:mm")
        
    }
}

extension WriteDiaryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        let layout = KTCenterFlowLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: DiaryCollectionViewCell.cellID)
        setupTapGestureRecognizer()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VM.newDiary?.sticker.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCell.cellID, for: indexPath) as! DiaryCollectionViewCell
        cell.configForWriteDiaryVC(img: VM.newDiary!.sticker[indexPath.row])
        
        cell.deleteStickerPublisher.receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                VM.newDiary?.sticker.remove(at: indexPath.row)
                print("tapped \(indexPath.row)")
            }
            .store(in: &cell.cancellables)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the desired size for each cell
        return CGSize(width: 50, height: 50)
    }
    
    private func resetCellStates() {
        for cell in collectionView.visibleCells {
            if let imageCell = cell as? DiaryCollectionViewCell {
                imageCell.resetState()
            }
        }
    }
    
    // Add tap gesture recognizer to the collection view
    private func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapSticker(_:)))
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    
    // Handle the tap gesture on the collection view
    @objc private func handleTapSticker(_ gestureRecognizer: UITapGestureRecognizer) {
        // Tapped outside of an image cell, reset the cell states
        resetCellStates()
        diaryTextField.resignFirstResponder()
    }
    
}

extension WriteDiaryVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "오늘은 어떤 하루였나요?".localised {textView.text = ""}
        resetCellStates()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {textView.text = "오늘은 어떤 하루였나요?".localised}
        else if textView.text != "오늘은 어떤 하루였나요?".localised && textView.text != "" {
            VM.addNewStoryToData(textView.text, date: MainVM.Shared.selectedDate!.date.toString(format: "yyyy.MM.dd"))
        }
        resetCellStates()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        resetCellStates()
    }
    
}
