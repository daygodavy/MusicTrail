//
//  ArtistCell.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/17/23.
//

import UIKit

class ArtistCell: UITableViewCell {

    static let identifier = "ArtistCell"
    
    // MARK: - Variables
    private(set) var artist: LibraryArtist!
    var placeholderImage = UIImage(systemName: "questionmark")
    
    // MARK: - UI Components
    private let artistImage = ArtistImageView(frame: .zero)
    
    private let nameLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .systemOrange
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.text = "Error"
        return titleLabel
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with artist: LibraryArtist) {
        if let url = artist.imageUrl {
            self.artistImage.downloadArtistImage(url)
        } else {
            self.artistImage.setDefault()
        }
        self.artist = artist
        self.nameLabel.text = artist.name
    }
    
    
    // TODO: - Prepare for reuse
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(artistImage)
        self.addSubview(nameLabel)
        
        artistImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            artistImage.topAnchor.constraint(equalTo: self.topAnchor),
            artistImage.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
//            artistImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            artistImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            artistImage.heightAnchor.constraint(equalToConstant: 84),
            artistImage.widthAnchor.constraint(equalToConstant: 84),
            
            nameLabel.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: artistImage.trailingAnchor, constant: 50),
            nameLabel.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor)
        ])
    }
    

}
