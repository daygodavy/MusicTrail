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
    private let artistImage = ArtistImageView(frame: .zero)
    
    private var nameLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .systemOrange
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.text = "Error"
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
        if let url = artist.imageUrl {
            self.artistImage.downloadArtistImage(url, artist: artist.name)
        }
        
        self.artist = artist
        self.nameLabel.text = artist.name
    }
    
    private func configure() {
        self.addSubview(artistImage)
        self.addSubview(nameLabel)
        
        artistImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            artistImage.topAnchor.constraint(equalTo: topAnchor),
            artistImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            artistImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            artistImage.heightAnchor.constraint(equalToConstant: 84),
            
            nameLabel.topAnchor.constraint(equalTo: artistImage.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
}
