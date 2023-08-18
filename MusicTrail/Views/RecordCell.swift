//
//  RecordCell.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/17/23.
//

import UIKit

class RecordCell: UICollectionViewCell {
    
    static let identifier = "RecordCell"
    
    // MARK: - Variables
    private(set) var record: MTArtist!
    
    // MARK: - UI Components
    private let recordImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "questionmark")
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private let recordTitle: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .systemOrange
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.text = "Error"
        return titleLabel
    }()
    
//    private let recordArtistLabel
//    private let recordDateLabel?
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with record: MTArtist) {
        self.record = record
        // set the remaining labels here
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(recordImage)
        self.addSubview(recordTitle)
        
        recordImage.translatesAutoresizingMaskIntoConstraints = false
        recordTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recordImage.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            recordImage.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            recordImage.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            recordImage.heightAnchor.constraint(equalToConstant: 50),
            
            recordTitle.topAnchor.constraint(equalTo: recordImage.bottomAnchor, constant: 20),
            recordTitle.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            recordTitle.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            recordTitle.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
}
