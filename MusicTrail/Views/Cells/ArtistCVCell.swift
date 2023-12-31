//
//  ArtistCVCell.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/5/23.
//

import UIKit

class ArtistCVCell: UICollectionViewCell {
    
    // MARK: - Variables
    static let reuseID = "ArtistCVCell"
    private(set) var artist: MTArtist!
    
    // MARK: - UI Components
    private let artistImage = ArtworkImageView(frame: .zero, style: .square)
    
    private var nameLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .systemOrange
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.text = "Error"
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    // MARK: - Initializations
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(artist: MTArtist) {
        self.artistImage.downloadArtworkImage(artist.imageUrl)
        self.artist = artist
        self.nameLabel.text = artist.name
    }
    
    // MARK: - UI Setup
    private func configure() {
        artistImage.layer.borderWidth = 1
        artistImage.layer.borderColor = UIColor.systemGray5.cgColor
        artistImage.layer.cornerRadius = 5
        
        self.addSubview(artistImage)
        self.addSubview(nameLabel)
        
        let padding: CGFloat = 6
        
        NSLayoutConstraint.activate([
            artistImage.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            artistImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            artistImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            artistImage.heightAnchor.constraint(equalTo: artistImage.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: artistImage.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
