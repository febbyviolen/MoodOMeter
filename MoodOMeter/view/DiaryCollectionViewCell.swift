//
//  DiaryCollectionViewCell.swift
//  MoodOMeter
//
//  Created by Ebbyy on 11/6/23.
//

import UIKit
import Combine
import CombineCocoa

class DiaryCollectionViewCell: UICollectionViewCell {
    
    private var deleteStickerSubject = PassthroughSubject<Void, Never>()
    var deleteStickerPublisher: AnyPublisher<Void, Never> {
        deleteStickerSubject.eraseToAnyPublisher()
    }
    
    var cancellables = Set<AnyCancellable>()
    static let cellID = "DiaryCollectionViewCell"
    private var isWiggling = false
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Trash"), for: .normal)
        button.tintColor = UIColor(named: "red")
        button.setTitle("", for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        // Configure the delete button
        deleteButton.isHidden = true
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
        // Reset the cell state
       resetState()
    }
    
    private func layout() {
        [imageView, deleteButton].forEach(addSubview(_:))
        imageView.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(40)
        }
        deleteButton.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(img: String) {
        imageView.image = UIImage(named: img)
    }
    
    func configForWriteDiaryVC(img: String) {
        imageView.image = UIImage(named: img)
        imageView.alpha = 1.0
        
        // Add long press gesture recognizer to the cell
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPressGesture)
    }
    
    // Handle the long press gesture
    @objc 
    private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            // Show the delete button and overlay view
            deleteButton.isHidden = false
            imageView.alpha = 0.5
            
            // Perform the wiggle animation
            wiggleAnimation()
            isWiggling = true
        }
    }
    
    // Handle delete button tapped
    @objc
    private func deleteButtonTapped() {
        deleteStickerSubject.send()
    }
    
    // Perform the wiggle animation
    private func wiggleAnimation() {
        let rotationAngle = CGFloat.pi / 180.0 * 5.0
        
        let wiggleAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wiggleAnimation.values = [-rotationAngle, rotationAngle]
        wiggleAnimation.autoreverses = true
        wiggleAnimation.duration = 0.15
        wiggleAnimation.repeatCount = .infinity
        
        layer.add(wiggleAnimation, forKey: "wiggleAnimation")
    }
    
    // Stop the wiggle animation
    private func stopWiggleAnimation() {
        layer.removeAnimation(forKey: "wiggleAnimation")
    }
    
    func resetState() {
        if isWiggling {
            stopWiggleAnimation()
            deleteButton.isHidden = true
            imageView.alpha = 1.0
            isWiggling = false
        }
    }
}
