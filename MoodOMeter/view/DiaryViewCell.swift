//
//  DiaryViewCell.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/6/23.
//

import UIKit
import SnapKit
import KTCenterFlowLayout

class DiaryViewCell: UITableViewCell{
    
    static let cellID = "DiaryViewCell"
    @IBOutlet var background: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var separationUI: UIView!
    
    var item = [String]()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: DiaryCollectionViewCell.cellID)
//        collectionView.backgroundColor = .yellow
        
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var storyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 15)
//        label.backgroundColor = .blue
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            collectionView,
            storyLabel
        ])
        stackView.axis = .vertical
//        stackView.backgroundColor = .red
        return stackView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        
        background.addCornerRadius(radius: 16)
        background.addShadow (
            offset: CGSize(width: 0, height: 0),
            color: UIColor(named: "black")!,
            radius: 4,
            opacity: 0.1)
        
        layout()
    }
    
    private func layout(){
        background.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(background.snp.top).offset(10)
            make.bottom.equalTo(background.snp.bottom).offset(-10)
            make.leading.equalTo(separationUI.snp.trailing).offset(10)
            make.trailing.equalTo(background.snp.trailing).offset(-10)
        }
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(40).priority(.high)
        }
    }

    func configure(data: DiaryModel) {
        dateLabel.textColor = UIColor(named: "black")
        dateLabel?.text = data.date
        
        item = data.sticker
        
        storyLabel.textColor = UIColor(named: "black")
        storyLabel.text = data.story
        storyLabel.isHidden = data.story == "" ? true : false
        
        collectionView.isHidden = data.sticker.count == 0 ? true : false
        if !collectionView.isHidden {
            collectionView.layoutIfNeeded()
            collectionView.reloadData()}
    }
    
}

extension DiaryViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCell.cellID, for: indexPath) as! DiaryCollectionViewCell
        cell.configure(img: item[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the desired size for each cell
        return CGSize(width: 35, height: 40)
    }
}
