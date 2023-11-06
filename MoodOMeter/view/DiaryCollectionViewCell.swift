//
//  DiaryCollectionViewCell.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/6/23.
//

import UIKit

class DiaryCollectionViewCell: UICollectionViewCell {
    
    static let cellID = "DiaryCollectionViewCell"
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(img: String) {
        imageView.image = UIImage(named: img)
    }
    
    private func layout() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
    }
}
