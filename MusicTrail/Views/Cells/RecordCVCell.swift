//
//  RecordCVCell.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/17/23.
//

import UIKit

class RecordCVCell: UICollectionViewCell {
    
    static let reuseID = "RecordCVCell"
    
    // MARK: - Variables
    private(set) var record: MTRecord!
    
    // MARK: - UI Components
    // Record Image
    private let artworkImage = ArtworkImageView(frame: .zero)
    
    // Record name
    private let titleLabel = MTTitleLabel(textAlignment: .left, fontSize: 12, textColor: .systemOrange)
    
    // Artist name
    private let artistNameLabel = MTBodyLabel(textAlignment: .left, fontSize: 11, textColor: .systemGray)
    
    // Release date
    private let dateLabel = MTBodyLabel(textAlignment: .left, fontSize: 10, textColor: .systemGray)
    
    // Record details background
    private let detailsView: UIView = {
       let bgView = UIView()
        bgView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.75)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        return bgView
    }()
    
    
    // MARK: - Initializations
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(with record: MTRecord) {
        self.artworkImage.downloadArtworkImage(record.imageUrl)
        self.record = record
        self.titleLabel.text = record.title
        self.artistNameLabel.text = record.artistName
        self.dateLabel.text = DateUtil.releaseDateFormatter.string(for: record.releaseDate)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(artworkImage)
        self.addSubview(detailsView)
        detailsView.addSubview(titleLabel)
        detailsView.addSubview(artistNameLabel)
        detailsView.addSubview(dateLabel)
        let labelHeight: CGFloat = 12
        let padding: CGFloat = 2
        
        NSLayoutConstraint.activate([
            artworkImage.topAnchor.constraint(equalTo: self.topAnchor),
            artworkImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            artworkImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            artworkImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            detailsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            detailsView.heightAnchor.constraint(equalTo: artworkImage.heightAnchor, multiplier: 0.25),
            
            titleLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -padding),
            titleLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: padding),
            titleLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            artistNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            artistNameLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: padding),
            artistNameLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -padding),
            artistNameLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            dateLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -padding),
            dateLabel.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: -padding),
            dateLabel.heightAnchor.constraint(equalToConstant: labelHeight)
        ])
    }
    
}
