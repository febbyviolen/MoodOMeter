//
//  StickerVC.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/8/23.
//

import UIKit
import Combine
import CombineCocoa

class StickerVC: UIViewController {
    
    @IBOutlet weak var buySubscriptionLabel: UILabel!
    @IBOutlet weak var buySubscriptionView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: PlainSegmentedControl!
    
    private var cancellables = Set<AnyCancellable>()
    private var selectedStickerObject = PassthroughSubject<String, Never>()
    var selectedStickerPublisher: AnyPublisher<String, Never> {
        return selectedStickerObject.eraseToAnyPublisher()
    }
    
    var writeDiaryVM: WriteDiaryVM?
    var moodSticker = Mood.allCases
    var lifeSticker = mainDaily.allCases
    
    var showIndex = 0
    
    override func viewDidLoad() {
        setupUI()
        bind()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    private func bind() {
        MainVM.Shared.$selectedDate.receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                dateLabel.text = data?.date.toString(format: "yyyy.mm.dd EEEE")
            }
            .store(in: &cancellables)
    }

    
    //MARK: SEGMENTED CONTROL ACTION
    //sticker option
    @IBAction func segmentedControlAction(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            showIndex = 0
            collectionView.reloadData()
        case 1:
            showIndex = 1
            collectionView.reloadData()
        default:
            break
        }
    }
    
    func setupUI(){
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray]
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
    }
}

extension StickerVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch showIndex {
        case 0:
            writeDiaryVM?.newAddedSticker = moodSticker[indexPath.item].imgName
            navigationController?.popViewController(animated: true)
        case 1:
            writeDiaryVM?.newAddedSticker = lifeSticker[indexPath.item].imgName
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch showIndex {
        case 0:
            return moodSticker.count
        case 1:
            return lifeSticker.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath) as! StickerVCCell
        
        buySubscriptionView.isHidden = true
        buySubscriptionLabel.isHidden = true
        switch showIndex {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath) as! StickerVCCell
            cell.stickerImg.image = UIImage(named: moodSticker[indexPath.item].imgName)
            return cell
        case 1:
            if UserDefaults.standard.string(forKey: "premiumPass") != "true"  {
                buySubscriptionView.isHidden = false
                buySubscriptionLabel.isHidden = false
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath) as! StickerVCCell
            cell.stickerImg.image = UIImage(named: lifeSticker[indexPath.item].imgName)
            return cell
        default:
            break
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the desired size for each cell
        let itemSpacing: CGFloat = 3 // Adjust the item spacing as needed
        let availableWidth = collectionView.bounds.width - itemSpacing
        let cellWidth = availableWidth / 4// Adjust the number of cells per row as needed
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0 // Adjust the line spacing as needed
    }
}
